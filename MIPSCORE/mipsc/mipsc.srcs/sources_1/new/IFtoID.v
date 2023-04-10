`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/09 22:44:59
// Design Name: 
// Module Name: if_id
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
//IF/ID ��ʱ����ȡ�õ�ָ���ַ�Լ�ָ�� ������һ��ʱ�����ڴ��ݵ�����׶�
module IFtoID(
    input wire clk,
    input wire rst,
    input wire[`InstAddrBus] if_pc, //ȡָ�׶�ȡ�õ�ָ���ַ
    input wire[`InstBus] if_inst, //ȡָ�׶�ȡ�õ�ָ��

    input wire[5:0] stall, //��ͣ�ź�
    input wire flush, //��ˮ������ź�

    output reg[`InstAddrBus] id_pc, //����׶�ָ���Ӧ�ĵ�ַ
    output reg[`InstBus] id_inst //����׶ε�ָ��
);
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end
        else if(flush == 1'b1 ) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end
        // ȡָ�׶���ͣ����׶β���ͣ �����ָ������
        else if(stall[1] == `Stop && stall[2] == `NoStop) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end
        else if(stall[1] == `NoStop) begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule
