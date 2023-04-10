`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/22 15:27:33
// Design Name: 
// Module Name: data_ram
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

module DatRam(
    input wire clk, //时钟信号
    input wire ce, //数据存储器使能
    input wire we, //数据存储器写使能
    input wire[`DataAddrBus] addr, //访存地址
    input wire[3:0] sel, //字节选择
    input wire[`DataBus] data_i, //要写入的数据
    output reg[`DataBus] data_o //要读出的数据
);
    // 128KB ram 每个ram的存储字为4byte 32bit
    reg[`ByteWidth]  data_mem[0:63];


// 此处给出的绝对地址 拷贝此工程后要根据实际位置修改
    initial $readmemb ( "C:/MyApp/MIPSCPU/MIPSCORE/mipsc/data_ram.data", data_mem);

    always @ (posedge clk) begin
        if(we == `WriteEnable) begin //大端格式 data_mem3高字节
            if (sel[3] == 1'b1) begin
                data_mem[addr[31:2]][31:24] <= data_i[31:24];
            end
            if (sel[2] == 1'b1) begin
                data_mem[addr[31:2]][23:16] <= data_i[23:16];
            end
            if (sel[1] == 1'b1) begin
                data_mem[addr[31:2]][15:8] <= data_i[15:8];
            end
            if (sel[0] == 1'b1) begin
                data_mem[addr[31:2]][7:0] <= data_i[7:0];
            end
        end
    end

    always @ (*) begin
        if (ce == `ChipDisable) begin
            data_o <= `ZeroWord;
        end 
        else if(we == `WriteDisable) begin
            data_o <= data_mem[addr[31:2]];
        end 
        else begin
            data_o <= `ZeroWord;
        end
    end
endmodule
