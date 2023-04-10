`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/14 15:22:35
// Design Name: 
// Module Name: id_ex
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
// ������׶�ȡ�õĽ������һ��ʱ�����ڴ��뵽ִ�н׶�
module id_ex(
    input	wire clk,
    input wire rst,


    //������׶δ��ݵ���Ϣ
    input wire[`AluOpBus] id_aluop, //����ó�������������
    input wire[`AluSelBus] id_alusel, //����ó�����������
    input wire[`RegBus] id_reg1, //Դ������1
    input wire[`RegBus] id_reg2, //Դ������2
    input wire[`RegAddrBus] id_wd, //Ŀ�ļĴ�����ַ
    input wire id_wreg, //�Ƿ���Ҫд���Ŀ�ļĴ���
    input wire[5:0] stall, //��ͣ�ź�

    input wire[`RegBus] id_link_address, //����׶ε�ָ��Ҫ����ķ��ص�ַ
    input wire id_is_delay, //��ǰ��������׶ε�ָ���Ƿ��ӳ�
    input wire next_inst_delay_i, //��һ����������׶ε�ָ���Ƿ��ӳ�

    input wire[`RegBus] id_inst, //����idģ����ź� �ô���

    // �쳣����
    input wire flush, //��ˮ������ź�
    input wire[`RegBus] id_current_inst_address, //����׶�ָ��ĵ�ַ
    input wire[31:0] id_excepttype, //����׶��ռ������쳣��Ϣ


    //���ݵ�ִ�н׶ε���Ϣ
    output reg[`AluOpBus] ex_aluop, //����������
    output reg[`AluSelBus] ex_alusel, //��������
    output reg[`RegBus] ex_reg1, //Դ������1
    output reg[`RegBus] ex_reg2, //Դ������2
    output reg[`RegAddrBus] ex_wd, //Ŀ�ļĴ�����ַ
    output reg ex_wreg, //�Ƿ�д��Ŀ�ļĴ���

    output reg[`RegBus] ex_link_address, //ִ�н׶ε�ָ��Ҫ����ķ��ص�ַ
    output reg ex_is_delay, //��ǰҪִ�е�ָ���Ƿ��ӳ� ��
    output reg is_delay_o, //��ǰ��������׶ε�ָ���Ƿ��ӳ� ǰ��
    output reg[`RegBus] ex_inst, //���ݵ�ex �ô���

    //exception
    output reg[31:0] ex_excepttype,
    output reg[`RegBus] ex_current_inst_address

);
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ex_aluop <= `EXE_NOP_OP;
            ex_alusel <= `EXE_RES_NOP;
            ex_reg1 <= `ZeroWord;
            ex_reg2 <= `ZeroWord;
            ex_wd <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
            ex_link_address <= `ZeroWord;
            ex_is_delay <= `NotInDelaySlot;
            is_delay_o <= `NotInDelaySlot;
            ex_inst<=`ZeroWord;
            ex_excepttype <= `ZeroWord;
            ex_current_inst_address <= `ZeroWord;
        end
        //��ˮ�����
        else if(flush == 1'b1 ) begin
            ex_aluop <= `EXE_NOP_OP;
            ex_alusel <= `EXE_RES_NOP;
            ex_reg1 <= `ZeroWord;
            ex_reg2 <= `ZeroWord;
            ex_wd <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
            ex_excepttype <= `ZeroWord;
            ex_link_address <= `ZeroWord;
            ex_inst <= `ZeroWord;
            ex_is_delay <= `NotInDelaySlot;
            ex_current_inst_address <= `ZeroWord;
            is_delay_o <= `NotInDelaySlot;
        end
        // �������׶���ͣ����ִ�н׶β���ͣ �����ָ��
        else if(stall[2] == `Stop && stall[3] == `NoStop) begin
            ex_aluop <= `EXE_NOP_OP;
            ex_alusel <= `EXE_RES_NOP;
            ex_reg1 <= `ZeroWord;
            ex_reg2 <= `ZeroWord;
            ex_wd <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
            ex_link_address <= `ZeroWord;
            ex_is_delay <= `NotInDelaySlot;
            ex_inst<=`ZeroWord;
            ex_excepttype <= `ZeroWord;
            ex_current_inst_address <= `ZeroWord;
        end
        else if(stall[2] == `NoStop) begin
            ex_aluop <= id_aluop;
            ex_alusel <= id_alusel;
            ex_reg1 <= id_reg1;
            ex_reg2 <= id_reg2;
            ex_wd <= id_wd;
            ex_wreg <= id_wreg;
            ex_link_address <= id_link_address;
            ex_is_delay <= id_is_delay;
            is_delay_o <= next_inst_delay_i;
            ex_inst<=id_inst;
            ex_excepttype <= id_excepttype;
            ex_current_inst_address <= id_current_inst_address;
        end
        // ���ִ�н׶���������������������������ˮ����ͣ ���ֵ���� 
    end
endmodule
