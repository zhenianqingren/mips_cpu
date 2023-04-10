`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/09 22:51:01
// Design Name: 
// Module Name: regfile
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
// 32��32λͨ�������Ĵ��� ����ͬʱ���������Ĵ����Ķ�������һ���Ĵ�����д����
module REGISTERS(
    input	wire clk,
    input wire rst,

    //д�˿�
    input wire we, //дʹ���ź�
    input wire[`RegAddrBus] waddr, //д��ĵ�ַ
    input wire[`RegBus] wdata, //��д�������

    //���˿�1
    input wire re1, //��ʹ���ź�1
    input wire[`RegAddrBus] raddr1, //��һ�����Ĵ����˿�Ҫ��ȡ�ĵ�ַ
    output reg[`RegBus] rdata1, //��һ�����Ĵ����˿ڶ�ȡ������

    //���˿�2
    input wire re2, //��ʹ���ź�2
    input wire[`RegAddrBus] raddr2, //�ڶ������Ĵ����˿�Ҫ��ȡ�ĵ�ַ
    output reg[`RegBus] rdata2 //�ڶ������Ĵ����˿ڶ�ȡ������
);
    reg[`RegBus]  regs[0:`RegNum-1]; //32���Ĵ���

    initial begin
        regs[0]=32'b00000000000000000000000000000000;
        regs[1]=32'b00000000000000000000000000000001;
        regs[2]=32'b00000000000000000000000000000010;
        regs[3]=32'b00000000000000000000000000000011;
        regs[4]=32'b00000000000000000000000000000100;
        regs[5]=32'b00000000000000000000000000000101;
        regs[6]=32'b00000000000000000000000000000110;
        regs[7]=32'b00000000000000000000000000000111;
        regs[8]=32'b00000000000000000000000000001000;
        regs[9]=32'b00000000000000000000000000001001;
        regs[10]=32'b00000000000000000000000000001010;
        regs[11]=32'b00000000000000000000000000001011;
        regs[12]=32'b00000000000000000000000000001100;
        regs[13]=32'b00000000000000000000000000001101;
        regs[14]=32'b00000000000000000000000000001110;
        regs[15]=32'b00000000000000000000000000001111;
        regs[16]=32'b00000000000000000000000000010000;
        regs[17]=32'b00000000000000000000000000010001;
        regs[18]=32'b00000000000000000000000000010010;
        regs[19]=32'b00000000000000000000000000010011;
        regs[20]=32'b00000000000000000000000000010100;
        regs[21]=32'b00000000000000000000000000010101;
        regs[22]=32'b00000000000000000000000000010110;
        regs[23]=32'b00000000000000000000000000010111;
        regs[24]=32'b00000000000000000000000000011000;
        regs[25]=32'b00000000000000000000000000011001;
        regs[26]=32'b00000000000000000000000000011010;
        regs[27]=32'b00000000000000000000000000011011;
        regs[28]=32'b00000000000000000000000000011100;
        regs[29]=32'b00000000000000000000000000011101;
        regs[30]=32'b00000000000000000000000000011110;
        regs[31]=32'b00000000000000000000000000011111;
    end

    //д����
    always @ (posedge clk) begin
        if (rst == `RstDisable) begin
            if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
                regs[waddr] <= wdata;
            end
        end
    end

    //���˿�1���� MIPS32�ܹ��涨�Ĵ���0��ֵֻ��Ϊ0
    always @ (*) begin
        if(rst == `RstEnable) begin
            rdata1 <= `ZeroWord;
        end
        else if(raddr1 == `RegNumLog2'h0) begin
            rdata1 <= `ZeroWord;
        end
        else if((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin
            rdata1 <= wdata; //������������ָ����������
        end
        else if(re1 == `ReadEnable) begin
            rdata1 <= regs[raddr1];
        end
        else begin
            rdata1 <= `ZeroWord;
        end
    end

    //���˿�2����
    always @ (*) begin
        if(rst == `RstEnable) begin
            rdata2 <= `ZeroWord;
        end
        else if(raddr2 == `RegNumLog2'h0) begin
            rdata2 <= `ZeroWord;
        end
        else if((raddr2 == waddr) && (we == `WriteEnable)& & (re2 == `ReadEnable)) begin
            rdata2 <= wdata;
        end
        else if(re2 == `ReadEnable) begin
            rdata2 <= regs[raddr2]; //������������ָ����������
        end //������׶�Ҫȡ�õļĴ���ֵǡ���ǵ�����4��ָ���д�׶εļĴ�����ֵ
        else begin
            rdata2 <= `ZeroWord;
        end
    end
endmodule
