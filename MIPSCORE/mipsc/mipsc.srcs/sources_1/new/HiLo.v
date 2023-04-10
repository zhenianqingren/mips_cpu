`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/18 17:07:52
// Design Name: 
// Module Name: hilo_reg
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
//当保存乘法结果时 hi保存高32bit lo保存低32bit
//当保存除法结果时 hi保存余数 lo保存商
module HiLo(
    input wire clk,
    input wire rst,

    //写端口
    input wire we, //hi lo寄存器写使能信号
    input wire[`RegBus] hi_i, //写入hi寄存器的值
    input wire[`RegBus] lo_i, //写入lo寄存器的值

    //读端口1
    output reg[`RegBus] hi_o, //hi寄存器的值
    output reg[`RegBus] lo_o //lo寄存器的值
);
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
        end
        else if((we == `WriteEnable)) begin
            hi_o <= hi_i;
            lo_o <= lo_i;
        end
    end



endmodule
