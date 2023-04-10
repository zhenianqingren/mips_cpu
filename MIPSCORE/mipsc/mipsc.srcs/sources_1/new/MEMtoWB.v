`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/14 16:06:13
// Design Name: 
// Module Name: mem_wb
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
// 将访存阶段的运算结果 在下一个时钟传递到回写阶段
module MEMtoWB(
    input wire clk,
    input wire rst,


    //来自访存阶段的信息	
    input wire[`RegAddrBus] mem_wd, //目的寄存器地址
    input wire mem_wreg, //回写寄存器信号
    input wire[`RegBus] mem_wdata, //要写入目的寄存器的值

    input wire[`RegBus] mem_hi, //hi寄存器值
    input wire[`RegBus] mem_lo, //lo寄存器值
    input wire mem_whilo, //lo hi写使能信号

    input wire[5:0] stall, //暂停流水线信号
    input wire mem_LLbit_we, //访存阶段的指令是否要写LLbit寄存器
    input wire mem_LLbit_value, //访存阶段要写入LLbit寄存器的值

    // cp0
    input wire mem_cp0_reg_we,
    input wire[4:0] mem_cp0_reg_write_addr,
    input wire[`RegBus] mem_cp0_reg_data,

    //exception
    input wire flush,


    //送到回写阶段的信息
    output reg[`RegAddrBus] wb_wd, //目的寄存器地址
    output reg wb_wreg, //回写寄存器信号
    output reg[`RegBus] wb_wdata, //回写寄存器值

    output reg[`RegBus] wb_hi,
    output reg[`RegBus] wb_lo,
    output reg wb_whilo,

    output reg wb_LLbit_we, //回写阶段是否要写入LLbit寄存器
    output reg wb_LLbit_value, //回写阶段要写入LLbit寄存器的值


    //
    output reg wb_cp0_reg_we,
    output reg[4:0] wb_cp0_reg_write_addr,
    output reg[`RegBus] wb_cp0_reg_data
);
    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            wb_wd <= `NOPRegAddr;
            wb_wreg <= `WriteDisable;
            wb_wdata <= `ZeroWord;
            wb_hi <= `ZeroWord;
            wb_lo <= `ZeroWord;
            wb_whilo <= `WriteDisable;
            wb_LLbit_we <= 1'b0;
            wb_LLbit_value <= 1'b0;
            wb_cp0_reg_we <= `WriteDisable;
            wb_cp0_reg_write_addr <= 5'b00000;
            wb_cp0_reg_data <= `ZeroWord;
        end
        //流水线清除 放弃对通用寄存器 HI LO LLbit以及CP0中寄存器的修改
        else if(flush == 1'b1 ) begin
            wb_wd <= `NOPRegAddr;
            wb_wreg <= `WriteDisable;
            wb_wdata <= `ZeroWord;
            wb_hi <= `ZeroWord;
            wb_lo <= `ZeroWord;
            wb_whilo <= `WriteDisable;
            wb_LLbit_we <= 1'b0;
            wb_LLbit_value <= 1'b0;
            wb_cp0_reg_we <= `WriteDisable;
            wb_cp0_reg_write_addr <= 5'b00000;
            wb_cp0_reg_data <= `ZeroWord;
        end
        // 如果访存阶段停止但回写阶段不停 插入空指令 即把0写入零号寄存器
        else if(stall[4] == `Stop && stall[5] == `NoStop) begin
            wb_wd <= `NOPRegAddr;
            wb_wreg <= `WriteDisable;
            wb_wdata <= `ZeroWord;
            wb_hi <= `ZeroWord;
            wb_lo <= `ZeroWord;
            wb_whilo <= `WriteDisable;
            wb_LLbit_we <= 1'b0;
            wb_LLbit_value <= 1'b0;
            wb_cp0_reg_we <= `WriteDisable;
            wb_cp0_reg_write_addr <= 5'b00000;
            wb_cp0_reg_data <= `ZeroWord;
        end
        else if(stall[4] == `NoStop) begin
            wb_wd <= mem_wd;
            wb_wreg <= mem_wreg;
            wb_wdata <= mem_wdata;
            wb_hi <= mem_hi;
            wb_lo <= mem_lo;
            wb_whilo <= mem_whilo;
            wb_LLbit_we <= mem_LLbit_we;
            wb_LLbit_value <= mem_LLbit_value;
            wb_cp0_reg_we <= mem_cp0_reg_we;
            wb_cp0_reg_write_addr <= mem_cp0_reg_write_addr;
            wb_cp0_reg_data <= mem_cp0_reg_data;
        end //if
    end //always
endmodule
