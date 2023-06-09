`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/14 16:21:48
// Design Name: 
// Module Name: inst_rom
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

module InsRom(
    input wire ce, //使能信号
    input wire[`InstAddrBus] addr, //要读取的指令地址
    output reg[`InstBus] inst //读取的指令
);
    reg[`InstBus]  inst_mem[0:63];

// 此处给出的绝对地址 拷贝此工程后要根据实际位置修改
    initial $readmemb ( "C:/MyApp/MIPSCPU/MIPSCORE/mipsc/inst_rom.data", inst_mem );

    always @ (*) begin
        if (ce == `ChipDisable) begin
            inst <= `ZeroWord;
//            inst_mem[0]=32'b00110100000001010000000001001000;
//            inst_mem[1]=32'b00110100000010000000000000101000;
//            inst_mem[2]=32'b00000001000000000000000000001000;
//            inst_mem[3]=32'b00110100000000010000000000000001;
//            inst_mem[4]=32'b10101100000000010000000000000000;
//            inst_mem[5]=32'b00110100000000100000000000000001;
//            inst_mem[6]=32'b10101100000000100000000000000000;
//            inst_mem[7]=32'b00110100000000110000000000000010;
//            inst_mem[8]=32'b10101100000000110000000000000000;
//            inst_mem[9]=32'b01000010000000000000000000011000;
//            inst_mem[10]=32'b00110100000010011111111100000001;
//            inst_mem[11]=32'b01000000100010010110000000000000;
//            inst_mem[12]=32'b00110100000000010000000000000001;
//            inst_mem[13]=32'b10101100000000010000000000000000;
//            inst_mem[14]=32'b00110100000000100000000000000001;
//            inst_mem[15]=32'b10101100000000100000000000000000;
//            inst_mem[16]=32'b00110100000000110000000000000010;
//            inst_mem[17]=32'b10101100000000110000000000000000;
//            inst_mem[18]=32'b00000000000000100000100000100101;
//            inst_mem[19]=32'b00000000000000110001000000100101;
//            inst_mem[20]=32'b00000000001000100001100000100000;
//            inst_mem[21]=32'b10101100000000110000000000000000;
//            inst_mem[22]=32'b00000000101000000000000000001000;
//            inst_mem[23]=32'b00000000000000000000000000001111;
//            inst_mem[24]=32'b00000000000000000000000000001111;
//            inst_mem[25]=32'b00000000000000000000000000001111;
//            inst_mem[26]=32'b00000000000000000000000000001111;   烧录时取消此段注释
        end
        else begin
            inst <= inst_mem[addr[31:2]]; //给出的地址是按字节寻址 给出0x8 则对应 inst_mem[2] 因此给出的地址要右移两位
        end
    end
endmodule
