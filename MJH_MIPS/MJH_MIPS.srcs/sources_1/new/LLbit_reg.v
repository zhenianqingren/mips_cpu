`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/23 15:25:38
// Design Name: 
// Module Name: LLbit_reg
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

module LLbit_reg(
    input wire clk,
    input wire rst,
    input wire flush, //是否有异常发生
    //写端口
    input wire LLbit_i, //要写到LLbit寄存器的值
    input wire we, //写使能信号
    //读端口1
    output reg LLbit_o //当前LLbit的值
);
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            LLbit_o <= 1'b0;
        end
        else if((flush == 1'b1)) begin
            LLbit_o <= 1'b0;
        end
        else if((we == `WriteEnable)) begin
            LLbit_o <= LLbit_i;
        end
    end

endmodule
