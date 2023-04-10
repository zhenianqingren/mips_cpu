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
//������˷����ʱ hi�����32bit lo�����32bit
//������������ʱ hi�������� lo������
module HiLo(
    input wire clk,
    input wire rst,

    //д�˿�
    input wire we, //hi lo�Ĵ���дʹ���ź�
    input wire[`RegBus] hi_i, //д��hi�Ĵ�����ֵ
    input wire[`RegBus] lo_i, //д��lo�Ĵ�����ֵ

    //���˿�1
    output reg[`RegBus] hi_o, //hi�Ĵ�����ֵ
    output reg[`RegBus] lo_o //lo�Ĵ�����ֵ
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
