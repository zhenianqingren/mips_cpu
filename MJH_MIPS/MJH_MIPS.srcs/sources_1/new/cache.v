`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/24 16:37:44
// Design Name: 
// Module Name: cache
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
module cache(
    input wire clk, // ʱ���ź�
    input wire ce, // ����ʹ��
    input wire we, // ����дʹ��
    input wire[`DataAddrBus] addr, // �ô��ַ
    input wire[3:0] sel, //�ֽ�ѡ��
    input wire[`DataBus] data_i, //Ҫд�������
    output reg[`DataBus] data_o //Ҫ����������
);

    wire group;
    assign group = {addr[31:2],2'b00}% `CacheGroups;
    reg [`ByteWidth] cache_memory[0:`CacheGroups-1][0:`Association-1];
    // cacheһ��16�� ÿ��4�� ÿ��4���ֽ�

    reg[`BlocksLog2:0] signal[0:`CacheGroups-1][0:`Association-1];
    // ���λ����˿��Ƿ���� ��17bit�ǿ��� ����ȫ�����Ա��Ƿ�����Ӧ�Ŀ�


    always @ (*) begin
        if (ce == `ChipDisable) begin
            data_o <= `ZeroWord;
        end
        else if(we == `WriteDisable) begin
            if(signal[group][0][`BlocksLog2]&&signal[group][0][`BlocksLog2-1:0]==addr[`BlocksLog2+1:2])begin
                data_o<=cache_memory[group][0];
            end
                        if(signal[group][0][`BlocksLog2]&&signal[group][0][`BlocksLog2-1:0]==addr[`BlocksLog2+1:2])begin
                data_o<=cache_memory[group][0];
            end
            
        end
    end

endmodule
