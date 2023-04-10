`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/01 14:36:17
// Design Name: 
// Module Name: PC
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
module PC(
    input wire clk, //��λ�ź�
    input wire rst, //ʱ���ź�

    input wire[5:0] stall, //��ͣ�ź�
    input wire branch_flag_i, // �Ƿ���ת��
    input wire[`RegBus] branch_target_address_i, // Ҫת�Ƶ�Ŀ���ַ

    input wire flush, //��ˮ������ź�
    input wire[`RegBus] new_pc, //�쳣����������ڵ�ַ

    output reg[`InstAddrBus] pc, //Ҫ��ȡ��ָ���ַ
    output reg ce //ָ��洢��ʹ���ź�
    );
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ce <= `ChipDisable;
        end else begin
            ce <= `ChipEnable;
        end
    end

    always @ (posedge clk) begin
        if (ce == `ChipDisable) begin
            pc <= 32'h00000000;
        end
        else begin
            if(flush == 1'b1) begin
                pc <= new_pc;
            end
            else if(stall[0]==`NoStop)begin
                if(branch_flag_i == `Branch) begin
                    pc <= branch_target_address_i;
                end
                else begin
                    pc <= pc + 4'h4;
                end
            end
        end
    end

endmodule
