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
// ���ô�׶ε������� ����һ��ʱ�Ӵ��ݵ���д�׶�
module MEMtoWB(
    input wire clk,
    input wire rst,


    //���Էô�׶ε���Ϣ	
    input wire[`RegAddrBus] mem_wd, //Ŀ�ļĴ�����ַ
    input wire mem_wreg, //��д�Ĵ����ź�
    input wire[`RegBus] mem_wdata, //Ҫд��Ŀ�ļĴ�����ֵ

    input wire[`RegBus] mem_hi, //hi�Ĵ���ֵ
    input wire[`RegBus] mem_lo, //lo�Ĵ���ֵ
    input wire mem_whilo, //lo hiдʹ���ź�

    input wire[5:0] stall, //��ͣ��ˮ���ź�
    input wire mem_LLbit_we, //�ô�׶ε�ָ���Ƿ�ҪдLLbit�Ĵ���
    input wire mem_LLbit_value, //�ô�׶�Ҫд��LLbit�Ĵ�����ֵ

    // cp0
    input wire mem_cp0_reg_we,
    input wire[4:0] mem_cp0_reg_write_addr,
    input wire[`RegBus] mem_cp0_reg_data,

    //exception
    input wire flush,


    //�͵���д�׶ε���Ϣ
    output reg[`RegAddrBus] wb_wd, //Ŀ�ļĴ�����ַ
    output reg wb_wreg, //��д�Ĵ����ź�
    output reg[`RegBus] wb_wdata, //��д�Ĵ���ֵ

    output reg[`RegBus] wb_hi,
    output reg[`RegBus] wb_lo,
    output reg wb_whilo,

    output reg wb_LLbit_we, //��д�׶��Ƿ�Ҫд��LLbit�Ĵ���
    output reg wb_LLbit_value, //��д�׶�Ҫд��LLbit�Ĵ�����ֵ


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
        //��ˮ����� ������ͨ�üĴ��� HI LO LLbit�Լ�CP0�мĴ������޸�
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
        // ����ô�׶�ֹͣ����д�׶β�ͣ �����ָ�� ����0д����żĴ���
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
