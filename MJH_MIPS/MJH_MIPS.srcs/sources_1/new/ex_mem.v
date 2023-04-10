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
// ��ִ������ȡ�õĽ������һ��ʱ�����ڴ��ݵ��ô�׶�
module ex_mem(
    input	wire clk,
    input wire rst,


    //����ִ�н׶ε���Ϣ	
    input wire[`RegAddrBus] ex_wd, //Ŀ�ļĴ�����ַ
    input wire ex_wreg, //��д�Ĵ����ź�
    input wire[`RegBus] ex_wdata, //Ҫд��Ŀ�ļĴ�����ֵ
    input wire[`RegBus] ex_hi, // ����ִ�н׶ε�hi����ֵ
    input wire[`RegBus] ex_lo, //����ִ�н׶ε�lo����ֵ
    input wire ex_whilo, //lo hi��дʹ���ź�

    input wire[5:0] stall, //��ͣ�����ź�
    input wire[`DoubleRegBus] hilo_i, //����ĳ˷����
    input wire[1:0] cnt_i, //��һ��ʱ��������ִ�н׶εĵڼ�������
    // �ô�
    input wire[`AluOpBus] ex_aluop, //ִ�н׶�ָ�������������
    input wire[`RegBus] ex_mem_addr, //�����Ĵ洢����ַ
    input wire[`RegBus] ex_reg2, //д��洢����ֵ����lwl lwr����ԭʼ�Ĵ�����ֵ

    // ��ex���ݸ�mem
    input wire ex_cp0_reg_we,
    input wire[4:0] ex_cp0_reg_write_addr,
    input wire[`RegBus] ex_cp0_reg_data,

    // exception
    input wire flush, //��ˮ������ź�
    input wire[31:0] ex_excepttype, //���롢ִ�н׶��ռ������쳣��Ϣ
    input wire ex_is_in_delayslot, //�Ƿ����ӳ�ָ��(��ָ֧�����һ��)
    input wire[`RegBus] ex_current_inst_address, //ִ�н׶�ָ��ĵ�ַ

    //�͵��ô�׶ε���Ϣ
    output reg[`RegAddrBus] mem_wd, //Ŀ�ļĴ�����ַ
    output reg mem_wreg, //��д�Ĵ����ź�
    output reg[`RegBus] mem_wdata, //д��Ŀ�ļĴ�����ֵ

    output reg[`RegBus] mem_hi,
    output reg[`RegBus] mem_lo,
    output reg mem_whilo,

    output reg[`DoubleRegBus] hilo_o, //����ĳ˷����
    output reg[1:0] cnt_o, //��ǰʱ�������ǵڼ�������

    //�ô�
    output reg[`AluOpBus] mem_aluop,
    output reg[`RegBus] mem_mem_addr,
    output reg[`RegBus] mem_reg2,

    //
    output reg mem_cp0_reg_we,
    output reg[4:0] mem_cp0_reg_write_addr,
    output reg[`RegBus] mem_cp0_reg_data,

    //exception
    output reg[31:0] mem_excepttype, //�쳣��Ϣ
    output reg mem_is_in_delayslot, //�ӳ���Ϣ
    output reg[`RegBus] mem_current_inst_address //ָ���ַ
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
        //�����ˮ��
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

        // ���ִ�н׶���ͣ���ô�׶β���ͣ�����NOP��ָ��
        else if(stall[3] == `Stop && stall[4] == `NoStop) begin
            mem_wd <= `NOPRegAddr;
            mem_wreg <= `WriteDisable;
            mem_wdata <= `ZeroWord;
            mem_hi <= `ZeroWord;
            mem_lo <= `ZeroWord;
            mem_whilo <= `WriteDisable;

            //���ۼ�
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
