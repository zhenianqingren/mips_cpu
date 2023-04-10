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
    input wire clk, // 时钟信号
    input wire ce, // 缓存使能
    input wire we, // 缓存写使能
    input wire[`DataAddrBus] addr, // 访存地址
    input wire[3:0] sel, //字节选择
    input wire[`DataBus] data_i, //要写入的数据
    output reg[`DataBus] data_o //要读出的数据
);

    wire group;
    assign group = {addr[31:2],2'b00}% `CacheGroups;
    reg [`ByteWidth] cache_memory[0:`CacheGroups-1][0:`Association-1];
    // cache一共16组 每组4行 每行4个字节

    reg[`BlocksLog2:0] signal[0:`CacheGroups-1][0:`Association-1];
    // 最高位代表此块是否空闲 低17bit是块标记 用于全相联对比是否是相应的块


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
