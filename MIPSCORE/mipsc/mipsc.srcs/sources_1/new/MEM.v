`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/14 16:00:47
// Design Name: 
// Module Name: mem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "macro.v"
// 读写存储器 传递运算结果
module MEM(
    input wire rst,

    //来自执行阶段的信息	
    input wire[`RegAddrBus] wd_i, //目的寄存器地址
    input wire wreg_i, //回写寄存器信号
    input wire[`RegBus] wdata_i, //访存阶段要写入的目的寄存器的值

    input wire[`RegBus] hi_i, //hi寄存器值
    input wire[`RegBus] lo_i, //lo寄存器值
    input wire whilo_i, //lo hi写使能信号

    input wire[`AluOpBus] aluop_i, //运算子类型
    input wire[`RegBus] mem_addr_i, //存储器地址
    input wire[`RegBus] reg2_i, //存储到存储器的操作数或者lwl lwr原始寄存器值

    //来自memory的信息
    input wire[`RegBus] mem_data_i, //存入到寄存器的值

    //协处理器CP0的写信号
    input wire cp0_reg_we_i,
    input wire[4:0] cp0_reg_write_addr_i,
    input wire[`RegBus] cp0_reg_data_i,
    // exception
    input wire[31:0] excepttype_i,
    input wire is_in_delayslot_i,
    input wire[`RegBus] current_inst_address_i,
    //CP0的各个寄存器的值，但不一定是最新的值，要防止回写阶段指令写CP0
    input wire[`RegBus] cp0_status_i, //status寄存器
    input wire[`RegBus] cp0_cause_i, //cause寄存器
    input wire[`RegBus] cp0_epc_i, //epc寄存器
    //回写阶段的指令是否要写CP0，用来检测数据相关
    input wire wb_cp0_reg_we, //写使能
    input wire[4:0] wb_cp0_reg_write_addr, //写地址
    input wire[`RegBus]  wb_cp0_reg_data, //要写的值


    //送到回写阶段的信息
    output reg[`RegAddrBus] wd_o, //最终要写入的目的寄存器地址
    output reg wreg_o, //回写寄存器信号
    output reg[`RegBus] wdata_o, //要写入目的寄存器的值

    output reg[`RegBus] hi_o,
    output reg[`RegBus] lo_o,
    output reg whilo_o,

    //送到memory
    output reg[`RegBus] mem_addr_o, //访存地址
    output wire mem_we_o, //写使能信号
    output reg[3:0] mem_sel_o, //字节选择 1个字节 半字 字
    output reg[`RegBus] mem_data_o, //写入到存储器的值
    output reg mem_ce_o, //数据存储器使能信号

    //LLbit_i是LLbit寄存器的值
    input wire LLbit_i,
    //但不一定是最新值，回写阶段可能要写LLbit，所以还要进一步判断，数据前推于是有了下面两个端口
    input wire wb_LLbit_we_i,
    input wire wb_LLbit_value_i,

    output reg LLbit_we_o, //访存阶段指令是否要写LLbit寄存器的值
    output reg LLbit_value_o, //访存阶段要写入的LLbit寄存器的值

    //
    output reg cp0_reg_we_o,
    output reg[4:0] cp0_reg_write_addr_o,
    output reg[`RegBus] cp0_reg_data_o,

    //exception
    output reg[31:0] excepttype_o, //最终的异常类型
    output wire[`RegBus] cp0_epc_o, //cp0中epc寄存器的最新值
    output wire is_in_delayslot_o, //延迟指令
    output wire[`RegBus] current_inst_address_o //访存阶段指令的地址
);

    reg LLbit; //保存LLbit的最新值
    reg[`RegBus] cp0_status; //status最新值
    reg[`RegBus] cp0_cause; //cause最新值
    reg[`RegBus] cp0_epc; //epc最新值

    assign is_in_delayslot_o = is_in_delayslot_i;
    assign current_inst_address_o = current_inst_address_i;
    assign cp0_epc_o = cp0_epc;

    // 数据前推获得status寄存器值
    always @ (*) begin
        if(rst == `RstEnable) begin
            cp0_status <= `ZeroWord;
        end
        else if((wb_cp0_reg_we == `WriteEnable) &&
        (wb_cp0_reg_write_addr == `CP0_REG_STATUS ))begin
            cp0_status <= wb_cp0_reg_data;
        end
        else begin
            cp0_status <= cp0_status_i;
        end
    end
    //数据前推获得epc寄存器值
    always @ (*) begin
        if(rst == `RstEnable) begin
            cp0_epc <= `ZeroWord;
        end else if((wb_cp0_reg_we == `WriteEnable) &&
        (wb_cp0_reg_write_addr == `CP0_REG_EPC ))begin
            cp0_epc <= wb_cp0_reg_data;
        end else begin
            cp0_epc <= cp0_epc_i;
        end
    end
    //数据前推获得cause寄存器值
    always @ (*) begin
        if(rst == `RstEnable) begin
            cp0_cause <= `ZeroWord;
        end
        //只有IP[1:0] IV WP字段可写
        else if((wb_cp0_reg_we == `WriteEnable) &&
        (wb_cp0_reg_write_addr == `CP0_REG_CAUSE ))begin
            cp0_cause[9:8] <= wb_cp0_reg_data[9:8];
            cp0_cause[22] <= wb_cp0_reg_data[22];
            cp0_cause[23] <= wb_cp0_reg_data[23];
        end else begin
            cp0_cause <= cp0_cause_i;
        end
    end
    //给出最终异常类型
    always @ (*) begin
        if(rst == `RstEnable) begin
            excepttype_o <= `ZeroWord;
        end
        else begin
            excepttype_o <= `ZeroWord;
            if(current_inst_address_i != `ZeroWord) begin
                //中断使能[0]&&此时未发生其他interrupt&&外部中断发生并且没有被全部屏蔽
                if(((cp0_cause[15:8] & (cp0_status[15:8])) != 8'h00) && (cp0_status[1] == 1'b0) &&
                (cp0_status[0] == 1'b1)) begin
                    excepttype_o <= 32'h00000001; //interrupt 外部中断
                end
                else if(excepttype_i[8] == 1'b1) begin
                    excepttype_o <= 32'h00000008; //syscall 系统调用异常
                end
                else if(excepttype_i[9] == 1'b1) begin
                    excepttype_o <= 32'h0000000a; //inst_invalid 非法指令
                end
                else if(excepttype_i[10] ==1'b1) begin
                    excepttype_o <= 32'h0000000d; //trap 自陷
                end
                else if(excepttype_i[11] == 1'b1) begin //ov 溢出
                    excepttype_o <= 32'h0000000c;
                end
                else if(excepttype_i[12] == 1'b1) begin //返回指令 eret 异常处理完毕后使用
                    excepttype_o <= 32'h0000000e;
                end
            end
        end
    end


    always @ (*) begin
        if(rst == `RstEnable) begin
            LLbit <= 1'b0;
        end
        else begin
            if(wb_LLbit_we_i == 1'b1) begin
                LLbit <= wb_LLbit_value_i;
            end
            else begin
                LLbit <= LLbit_i;
            end
        end
    end

    wire[`RegBus] zero32;
    reg mem_we; //ram的读写信号

    assign mem_we_o = mem_we & (~(|excepttype_o)) ;
    assign zero32 = `ZeroWord;

    always @ (*) begin
        if(rst == `RstEnable || is_in_delayslot_i==1) begin
            wd_o <= `NOPRegAddr;
            wreg_o <= `WriteDisable;
            wdata_o <= `ZeroWord;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            whilo_o <= `WriteDisable;
            mem_addr_o <= `ZeroWord;
            mem_we <= `WriteDisable;
            mem_sel_o <= 4'b0000;
            mem_data_o <= `ZeroWord;
            mem_ce_o <= `ChipDisable;
            LLbit_we_o <= 1'b0;
            LLbit_value_o <= 1'b0;
            cp0_reg_we_o <= `WriteDisable;
            cp0_reg_write_addr_o <= 5'b00000;
            cp0_reg_data_o <= `ZeroWord;
        end
        else begin
            wd_o <= wd_i;
            wreg_o <= wreg_i;
            wdata_o <= wdata_i;
            hi_o <= hi_i;
            lo_o <= lo_i;
            whilo_o <= whilo_i;
            mem_we <= `WriteDisable;
            mem_addr_o <= `ZeroWord;
            mem_sel_o <= 4'b1111;
            mem_ce_o <= `ChipDisable;
            LLbit_we_o <= 1'b0;
            LLbit_value_o <= 1'b0;
            cp0_reg_we_o <= cp0_reg_we_i;
            cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
            cp0_reg_data_o <= cp0_reg_data_i;
            mem_data_o<=`ZeroWord;
            case (aluop_i)
                `EXE_LB_OP: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteDisable;
                    mem_ce_o <= `ChipEnable;
                    case (mem_addr_i[1:0]) //一个存储单元是32bit 对于非对齐的字节取数据需要了解是哪一个字节
                        2'b00: begin
                            wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
                            mem_sel_o <= 4'b1000;
                        end
                        2'b01: begin
                            wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
                            mem_sel_o <= 4'b0100;
                        end
                        2'b10: begin
                            wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
                            mem_sel_o <= 4'b0010;
                        end
                        2'b11: begin
                            wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
                            mem_sel_o <= 4'b0001;
                        end
                        default: begin
                            wdata_o <= `ZeroWord;
                        end
                    endcase
                end
                `EXE_LBU_OP: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteDisable;
                    mem_ce_o <= `ChipEnable;
                    case (mem_addr_i[1:0])
                        2'b00: begin
                            wdata_o <= {{24{1'b0}},mem_data_i[31:24]};
                            mem_sel_o <= 4'b1000;
                        end
                        2'b01: begin
                            wdata_o <= {{24{1'b0}},mem_data_i[23:16]};
                            mem_sel_o <= 4'b0100;
                        end
                        2'b10: begin
                            wdata_o <= {{24{1'b0}},mem_data_i[15:8]};
                            mem_sel_o <= 4'b0010;
                        end
                        2'b11: begin
                            wdata_o <= {{24{1'b0}},mem_data_i[7:0]};
                            mem_sel_o <= 4'b0001;
                        end
                        default: begin
                            wdata_o <= `ZeroWord;
                        end
                    endcase
                end
//                `EXE_LH_OP: begin
//                    mem_addr_o <= mem_addr_i;
//                    mem_we <= `WriteDisable;
//                    mem_ce_o <= `ChipEnable;
//                    case (mem_addr_i[1:0]) //对于半字而言 一个内存单元只有两种情况00->31:16 10->15:0
//                        2'b00: begin
//                            wdata_o <= {{16{mem_data_i[31]}},mem_data_i[31:16]};
//                            mem_sel_o <= 4'b1100;
//                        end
//                        2'b10: begin
//                            wdata_o <= {{16{mem_data_i[15]}},mem_data_i[15:0]};
//                            mem_sel_o <= 4'b0011;
//                        end
//                        default: begin
//                            wdata_o <= `ZeroWord;
//                        end
//                    endcase
//                end
//                `EXE_LHU_OP: begin
//                    mem_addr_o <= mem_addr_i;
//                    mem_we <= `WriteDisable;
//                    mem_ce_o <= `ChipEnable;
//                    case (mem_addr_i[1:0])
//                        2'b00: begin
//                            wdata_o <= {{16{1'b0}},mem_data_i[31:16]};
//                            mem_sel_o <= 4'b1100;
//                        end
//                        2'b10: begin
//                            wdata_o <= {{16{1'b0}},mem_data_i[15:0]};
//                            mem_sel_o <= 4'b0011;
//                        end
//                        default: begin
//                            wdata_o <= `ZeroWord;
//                        end
//                    endcase
//                end
                `EXE_LW_OP: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteDisable;
                    wdata_o <= mem_data_i;
                    mem_sel_o <= 4'b1111;
                    mem_ce_o <= `ChipEnable;
                end
//                `EXE_LWL_OP: begin //最低4-n个字节保存在高位
//                    mem_addr_o <= {mem_addr_i[31:2], 2'b00};
//                    mem_we <= `WriteDisable;
//                    mem_sel_o <= 4'b1111;
//                    mem_ce_o <= `ChipEnable;
//                    case (mem_addr_i[1:0])
//                        2'b00: begin
//                            wdata_o <= mem_data_i[31:0];
//                        end
//                        2'b01: begin
//                            wdata_o <= {mem_data_i[23:0],reg2_i[7:0]};
//                        end
//                        2'b10: begin
//                            wdata_o <= {mem_data_i[15:0],reg2_i[15:0]};
//                        end
//                        2'b11: begin
//                            wdata_o <= {mem_data_i[7:0],reg2_i[23:0]};
//                        end
//                        default: begin
//                            wdata_o <= `ZeroWord;
//                        end
//                    endcase
//                end
//                `EXE_LWR_OP: begin //最高n+1个字节保存在低位
//                    mem_addr_o <= {mem_addr_i[31:2], 2'b00};
//                    mem_we <= `WriteDisable;
//                    mem_sel_o <= 4'b1111;
//                    mem_ce_o <= `ChipEnable;
//                    case (mem_addr_i[1:0])
//                        2'b00: begin
//                            wdata_o <= {reg2_i[31:8],mem_data_i[31:24]};
//                        end
//                        2'b01: begin
//                            wdata_o <= {reg2_i[31:16],mem_data_i[31:16]};
//                        end
//                        2'b10: begin
//                            wdata_o <= {reg2_i[31:24],mem_data_i[31:8]};
//                        end
//                        2'b11: begin
//                            wdata_o <= mem_data_i;
//                        end
//                        default: begin
//                            wdata_o <= `ZeroWord;
//                        end
//                    endcase
//                end
                `EXE_SB_OP: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteEnable;
                    mem_data_o <= {reg2_i[7:0],reg2_i[7:0],reg2_i[7:0],reg2_i[7:0]};
                    mem_ce_o <= `ChipEnable;
                    case (mem_addr_i[1:0]) //存储到一个内存单元存储字的哪一个字节
                        2'b00: begin
                            mem_sel_o <= 4'b1000;
                        end
                        2'b01: begin
                            mem_sel_o <= 4'b0100;
                        end
                        2'b10: begin
                            mem_sel_o <= 4'b0010;
                        end
                        2'b11: begin
                            mem_sel_o <= 4'b0001;
                        end
                        default: begin
                            mem_sel_o <= 4'b0000;
                        end
                    endcase
                end
//                `EXE_SH_OP: begin
//                    mem_addr_o <= mem_addr_i;
//                    mem_we <= `WriteEnable;
//                    mem_data_o <= {reg2_i[15:0],reg2_i[15:0]};
//                    mem_ce_o <= `ChipEnable;
//                    case (mem_addr_i[1:0])
//                        2'b00: begin
//                            mem_sel_o <= 4'b1100;
//                        end
//                        2'b10: begin
//                            mem_sel_o <= 4'b0011;
//                        end
//                        default: begin
//                            mem_sel_o <= 4'b0000;
//                        end
//                    endcase
//                end
                `EXE_SW_OP: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteEnable;
                    mem_data_o <= reg2_i;
                    mem_sel_o <= 4'b1111;
                    mem_ce_o <= `ChipEnable;
                end
//                `EXE_SWL_OP: begin //最高4-n个字节存储到mem_addr_align的低位 高位变为0
//                    mem_addr_o <= {mem_addr_i[31:2], 2'b00};
//                    mem_we <= `WriteEnable;
//                    mem_ce_o <= `ChipEnable;
//                    case (mem_addr_i[1:0])
//                        2'b00: begin
//                            mem_sel_o <= 4'b1111;
//                            mem_data_o <= reg2_i;
//                        end
//                        2'b01: begin
//                            mem_sel_o <= 4'b0111;
//                            mem_data_o <= {zero32[7:0],reg2_i[31:8]};
//                        end
//                        2'b10: begin
//                            mem_sel_o <= 4'b0011;
//                            mem_data_o <= {zero32[15:0],reg2_i[31:16]};
//                        end
//                        2'b11: begin
//                            mem_sel_o <= 4'b0001;
//                            mem_data_o <= {zero32[23:0],reg2_i[31:24]};
//                        end
//                        default: begin
//                            mem_sel_o <= 4'b0000;
//                        end
//                    endcase
//                end
//                `EXE_SWR_OP: begin //最低n+1个字节存放在内存单元mem_addr_align的高处
//                    mem_addr_o <= {mem_addr_i[31:2], 2'b00};
//                    mem_we <= `WriteEnable;
//                    mem_ce_o <= `ChipEnable;
//                    case (mem_addr_i[1:0])
//                        2'b00:	begin
//                            mem_sel_o <= 4'b1000;
//                            mem_data_o <= {reg2_i[7:0],zero32[23:0]};
//                        end
//                        2'b01:	begin
//                            mem_sel_o <= 4'b1100;
//                            mem_data_o <= {reg2_i[15:0],zero32[15:0]};
//                        end
//                        2'b10:	begin
//                            mem_sel_o <= 4'b1110;
//                            mem_data_o <= {reg2_i[23:0],zero32[7:0]};
//                        end
//                        2'b11:	begin
//                            mem_sel_o <= 4'b1111;
//                            mem_data_o <= reg2_i[31:0];
//                        end
//                        default:	begin
//                            mem_sel_o <= 4'b0000;
//                        end
//                    endcase
//                end
                `EXE_LL_OP: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteDisable;
                    LLbit_we_o <= 1'b1;
                    LLbit_value_o <= 1'b1;
                    mem_ce_o <= `ChipEnable;
                    case (mem_addr_i[1:0]) //符号位扩展 大端
                        2'b00: begin
                            wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
                            mem_sel_o <= 4'b1000;
                        end
                        2'b01: begin
                            wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
                            mem_sel_o <= 4'b0100;
                        end
                        2'b10: begin
                            wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
                            mem_sel_o <= 4'b0010;
                        end
                        2'b11: begin
                            wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
                            mem_sel_o <= 4'b0001;
                        end
                        default: begin
                            wdata_o <= `ZeroWord;
                        end
                    endcase
                end
                `EXE_SC_OP: begin
                    if(LLbit == 1'b1) begin
                        LLbit_we_o <= 1'b1;
                        LLbit_value_o <= 1'b0;
                        mem_addr_o <= mem_addr_i;
                        mem_we <= `WriteEnable;
                        mem_data_o <= reg2_i;
                        wdata_o <= 32'b00000000000000000000000000000001;
                        mem_sel_o <= 4'b1111;
                        mem_ce_o <= `ChipEnable;
                    end
                    else begin
                        wdata_o <= 32'b00000000000000000000000000000000;
                    end
                end

                default: begin
                    //什么也不做
                end
            endcase


        end //if
    end //always





endmodule
