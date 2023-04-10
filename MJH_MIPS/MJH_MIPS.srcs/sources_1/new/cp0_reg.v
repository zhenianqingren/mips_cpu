`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/24 19:16:10
// Design Name: 
// Module Name: cp0_reg
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

module cp0_reg(

    input wire clk,
    input wire rst,

    input wire   we_i, //是否要写CP0中的寄存器
    input wire[4:0] waddr_i, // 要写的CP0中的寄存器的地址
    input wire[4:0] raddr_i, //要读取的CP0寄存器的地址
    input wire[`RegBus] data_i, //要写入CP0中寄存器的数据

    input wire[5:0] int_i, //6个外部硬件中断输入

    input wire[31:0] excepttype_i, //异常类型
    input wire[`RegBus] current_inst_addr_i, //发生异常的指令地址
    input wire is_in_delayslot_i, //是否是延迟指令

    output reg[`RegBus] data_o, //读出的CP0中某个寄存器的值
    output reg[`RegBus] count_o, //count_o count寄存器的值
    output reg[`RegBus] compare_o, //compare寄存器的值
    output reg[`RegBus] status_o, //status寄存器的值
    output reg[`RegBus] cause_o, //cause寄存器的值
    output reg[`RegBus] epc_o, //EPC寄存器的值
    output reg[`RegBus] config_o, //config寄存器的值
    output reg[`RegBus] prid_o, //prid寄存器的值

    output reg timer_int_o //是否有定时中断的产生
);

    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            count_o <= `ZeroWord;
            compare_o <= `ZeroWord;
            //status寄存器的CU为0001，表示协处理器CP0存在
            status_o <= 32'b00010000000000000000000000000000;
            cause_o <= `ZeroWord;
            epc_o <= `ZeroWord;
            //config寄存器的BE为1，表示Big-Endian；MT为00，表示没有MMU
            config_o <= 32'b00000000000000001000000000000000;
            //制作者是L，对应的是0x48，类型是0x1，基本类型，版本号是1.0
            prid_o <= 32'b00000000010011000000000100000010;
            timer_int_o <= `InterruptNotAssert;
        end
        else begin
            count_o <= count_o + 1 ;
            cause_o[15:10] <= int_i;
            timer_int_o<=1'b0;
            if(compare_o != `ZeroWord && count_o == compare_o) begin
                timer_int_o <= `InterruptAssert;
            end

            if(we_i == `WriteEnable) begin
                case (waddr_i)
                    `CP0_REG_COUNT:begin
                        count_o <= data_i;
                    end
                    `CP0_REG_COMPARE:begin
                        compare_o <= data_i;
                        timer_int_o <= `InterruptNotAssert;
                    end
                    `CP0_REG_STATUS:begin
                        status_o <= data_i;
                    end
                    `CP0_REG_EPC:begin
                        epc_o <= data_i;
                    end
                    `CP0_REG_CAUSE:	begin
                        //cause寄存器只有IP[1:0]、IV、WP字段是可写的
                        cause_o[9:8] <= data_i[9:8];
                        cause_o[23] <= data_i[23];
                        cause_o[22] <= data_i[22];
                    end
                endcase //case addr_i
            end

            case (excepttype_i)
                32'h00000001:begin //外部中断
                    if(is_in_delayslot_i == `InDelaySlot ) begin
                        epc_o <= current_inst_addr_i - 4 ;
                        cause_o[31] <= 1'b1; //cause寄存器的BD字段
                    end
                    else begin
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                    end
                    status_o[1] <= 1'b1; //status寄存器设置为1 禁止中断
                    cause_o[6:2] <= 5'b00000; //中断异常
                end

                32'h00000008:begin //syscall
                    if(status_o[1] == 1'b0) begin
                        if(is_in_delayslot_i == `InDelaySlot ) begin
                            epc_o <= current_inst_addr_i - 4 ;
                            cause_o[31] <= 1'b1;
                        end
                        else begin
                            epc_o <= current_inst_addr_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01000; //Sys
                end
                32'h0000000a:begin
                    if(status_o[1] == 1'b0) begin
                        if(is_in_delayslot_i == `InDelaySlot ) begin
                            epc_o <= current_inst_addr_i - 4 ;
                            cause_o[31] <= 1'b1;
                        end
                        else begin
                            epc_o <= current_inst_addr_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01010; //未定义指令
                end
                32'h0000000d:begin
                    if(status_o[1] == 1'b0) begin
                        if(is_in_delayslot_i == `InDelaySlot ) begin
                            epc_o <= current_inst_addr_i - 4 ;
                            cause_o[31] <= 1'b1;
                        end
                        else begin
                            epc_o <= current_inst_addr_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01101; //自陷
                end
                32'h0000000c:begin //溢出
                    if(status_o[1] == 1'b0) begin
                        if(is_in_delayslot_i == `InDelaySlot ) begin
                            epc_o <= current_inst_addr_i - 4 ;
                            cause_o[31] <= 1'b1;
                        end else begin
                            epc_o <= current_inst_addr_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01100;
                end
                32'h0000000e:begin //eret
                    status_o[1] <= 1'b0;
                end
                default:begin
                end
            endcase

        end //if
    end //always

    always @ (*) begin
        if(rst == `RstEnable) begin
            data_o <= `ZeroWord;
        end
        else begin
            case (raddr_i)
                `CP0_REG_COUNT:begin
                    data_o <= count_o ;
                end
                `CP0_REG_COMPARE:begin
                    data_o <= compare_o ;
                end
                `CP0_REG_STATUS:begin
                    data_o <= status_o ;
                end
                `CP0_REG_CAUSE:begin
                    data_o <= cause_o ;
                end
                `CP0_REG_EPC:begin
                    data_o <= epc_o ;
                end
                `CP0_REG_PrId:begin
                    data_o <= prid_o ;
                end
                `CP0_REG_CONFIG:begin
                    data_o <= config_o ;
                end
                default:begin
                end
            endcase //case addr_i			
        end //if

    end //always


endmodule
