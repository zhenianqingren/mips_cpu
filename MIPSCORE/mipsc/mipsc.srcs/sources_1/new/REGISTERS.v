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
// 32个32位通用整数寄存器 可以同时进行两个寄存器的读操作和一个寄存器的写操作
module REGISTERS(
    input	wire clk,
    input wire rst,

    //写端口
    input wire we, //写使能信号
    input wire[`RegAddrBus] waddr, //写入的地址
    input wire[`RegBus] wdata, //待写入的数据

    //读端口1
    input wire re1, //读使能信号1
    input wire[`RegAddrBus] raddr1, //第一个读寄存器端口要读取的地址
    output reg[`RegBus] rdata1, //第一个读寄存器端口读取的数据

    //读端口2
    input wire re2, //读使能信号2
    input wire[`RegAddrBus] raddr2, //第二个读寄存器端口要读取的地址
    output reg[`RegBus] rdata2 //第二个读寄存器端口读取的数据
);
    reg[`RegBus]  regs[0:`RegNum-1]; //32个寄存器

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

    //写操作
    always @ (posedge clk) begin
        if (rst == `RstDisable) begin
            if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
                regs[waddr] <= wdata;
            end
        end
    end

    //读端口1操作 MIPS32架构规定寄存器0的值只能为0
    always @ (*) begin
        if(rst == `RstEnable) begin
            rdata1 <= `ZeroWord;
        end
        else if(raddr1 == `RegNumLog2'h0) begin
            rdata1 <= `ZeroWord;
        end
        else if((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin
            rdata1 <= wdata; //解决了相隔两条指令的数据相关
        end
        else if(re1 == `ReadEnable) begin
            rdata1 <= regs[raddr1];
        end
        else begin
            rdata1 <= `ZeroWord;
        end
    end

    //读端口2操作
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
            rdata2 <= regs[raddr2]; //解决了相隔两条指令的数据相关
        end //即译码阶段要取得的寄存器值恰好是倒数第4条指令回写阶段的寄存器的值
        else begin
            rdata2 <= `ZeroWord;
        end
    end
endmodule
