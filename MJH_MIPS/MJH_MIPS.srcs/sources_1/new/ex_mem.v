`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/14 15:37:20
// Design Name: 
// Module Name: ex_mem
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
// 将执行周期取得的结果在下一个时钟周期传递到访存阶段
module ex_mem(
    input	wire clk,
    input wire rst,


    //来自执行阶段的信息	
    input wire[`RegAddrBus] ex_wd, //目的寄存器地址
    input wire ex_wreg, //回写寄存器信号
    input wire[`RegBus] ex_wdata, //要写入目的寄存器的值
    input wire[`RegBus] ex_hi, // 来自执行阶段的hi的新值
    input wire[`RegBus] ex_lo, //来自执行阶段的lo的新值
    input wire ex_whilo, //lo hi的写使能信号

    input wire[5:0] stall, //暂停控制信号
    input wire[`DoubleRegBus] hilo_i, //保存的乘法结果
    input wire[1:0] cnt_i, //下一个时钟周期是执行阶段的第几个周期
    // 访存
    input wire[`AluOpBus] ex_aluop, //执行阶段指令的运算子类型
    input wire[`RegBus] ex_mem_addr, //操作的存储器地址
    input wire[`RegBus] ex_reg2, //写入存储器的值或者lwl lwr所需原始寄存器的值

    // 从ex传递给mem
    input wire ex_cp0_reg_we,
    input wire[4:0] ex_cp0_reg_write_addr,
    input wire[`RegBus] ex_cp0_reg_data,

    // exception
    input wire flush, //流水线清除信号
    input wire[31:0] ex_excepttype, //译码、执行阶段收集到的异常信息
    input wire ex_is_in_delayslot, //是否是延迟指令(分支指令的下一条)
    input wire[`RegBus] ex_current_inst_address, //执行阶段指令的地址

    //送到访存阶段的信息
    output reg[`RegAddrBus] mem_wd, //目的寄存器地址
    output reg mem_wreg, //回写寄存器信号
    output reg[`RegBus] mem_wdata, //写入目的寄存器的值

    output reg[`RegBus] mem_hi,
    output reg[`RegBus] mem_lo,
    output reg mem_whilo,

    output reg[`DoubleRegBus] hilo_o, //保存的乘法结果
    output reg[1:0] cnt_o, //当前时钟周期是第几个周期

    //访存
    output reg[`AluOpBus] mem_aluop,
    output reg[`RegBus] mem_mem_addr,
    output reg[`RegBus] mem_reg2,

    //
    output reg mem_cp0_reg_we,
    output reg[4:0] mem_cp0_reg_write_addr,
    output reg[`RegBus] mem_cp0_reg_data,

    //exception
    output reg[31:0] mem_excepttype, //异常信息
    output reg mem_is_in_delayslot, //延迟信息
    output reg[`RegBus] mem_current_inst_address //指令地址
);
    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            mem_wd <= `NOPRegAddr;
            mem_wreg <= `WriteDisable;
            mem_wdata <= `ZeroWord;
            mem_hi <= `ZeroWord;
            mem_lo <= `ZeroWord;
            mem_whilo <= `WriteDisable;
            hilo_o <= {`ZeroWord, `ZeroWord};
            cnt_o <= 2'b00;
            mem_aluop <= `EXE_NOP_OP;
            mem_mem_addr <= `ZeroWord;
            mem_reg2 <= `ZeroWord;
            mem_cp0_reg_we <= `WriteDisable;
            mem_cp0_reg_write_addr <= 5'b00000;
            mem_cp0_reg_data <= `ZeroWord;
            mem_excepttype <= `ZeroWord;
            mem_is_in_delayslot <= `NotInDelaySlot;
            mem_current_inst_address <= `ZeroWord;
        end
        //清除流水线
        else if(flush == 1'b1 ) begin
            mem_wd <= `NOPRegAddr;
            mem_wreg <= `WriteDisable;
            mem_wdata <= `ZeroWord;
            mem_hi <= `ZeroWord;
            mem_lo <= `ZeroWord;
            mem_whilo <= `WriteDisable;
            mem_aluop <= `EXE_NOP_OP;
            mem_mem_addr <= `ZeroWord;
            mem_reg2 <= `ZeroWord;
            mem_cp0_reg_we <= `WriteDisable;
            mem_cp0_reg_write_addr <= 5'b00000;
            mem_cp0_reg_data <= `ZeroWord;
            mem_excepttype <= `ZeroWord;
            mem_is_in_delayslot <= `NotInDelaySlot;
            mem_current_inst_address <= `ZeroWord;
            hilo_o <= {`ZeroWord, `ZeroWord};
            cnt_o <= 2'b00;
        end

        // 如果执行阶段暂停而访存阶段不暂停则插入NOP空指令
        else if(stall[3] == `Stop && stall[4] == `NoStop) begin
            mem_wd <= `NOPRegAddr;
            mem_wreg <= `WriteDisable;
            mem_wdata <= `ZeroWord;
            mem_hi <= `ZeroWord;
            mem_lo <= `ZeroWord;
            mem_whilo <= `WriteDisable;

            //乘累加
            hilo_o <= hilo_i;
            cnt_o<=cnt_i;

            mem_aluop <= `EXE_NOP_OP;
            mem_mem_addr <= `ZeroWord;
            mem_reg2 <= `ZeroWord;
            mem_cp0_reg_we <= `WriteDisable;
            mem_cp0_reg_write_addr <= 5'b00000;
            mem_cp0_reg_data <= `ZeroWord;

            mem_excepttype <= `ZeroWord;
            mem_is_in_delayslot <= `NotInDelaySlot;
            mem_current_inst_address <= `ZeroWord;
        end
        else if(stall[3] == `NoStop) begin
            mem_wd <= ex_wd;
            mem_wreg <= ex_wreg;
            mem_wdata <= ex_wdata;
            mem_hi <= ex_hi;
            mem_lo <= ex_lo;
            mem_whilo <= ex_whilo;
            hilo_o <= {`ZeroWord, `ZeroWord};
            cnt_o<=cnt_i;
            mem_aluop <= ex_aluop;
            mem_mem_addr <= ex_mem_addr;
            mem_reg2 <= ex_reg2;
            mem_cp0_reg_we <= ex_cp0_reg_we;
            mem_cp0_reg_write_addr <= ex_cp0_reg_write_addr;
            mem_cp0_reg_data <= ex_cp0_reg_data;
            mem_excepttype <= ex_excepttype;
            mem_is_in_delayslot <= ex_is_in_delayslot;
            mem_current_inst_address <= ex_current_inst_address;
        end
        else begin
            hilo_o <= hilo_i;
            cnt_o<=cnt_i;
        end //if
    end //always
endmodule
