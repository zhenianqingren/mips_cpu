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
    input wire flush, //�Ƿ����쳣����
    //д�˿�
    input wire LLbit_i, //Ҫд��LLbit�Ĵ�����ֵ
    input wire we, //дʹ���ź�
    //���˿�1
    output reg LLbit_o //��ǰLLbit��ֵ
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
