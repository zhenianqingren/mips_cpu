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
    input wire clk, //复位信号
    input wire rst, //时钟信号

    input wire[5:0] stall, //暂停信号
    input wire branch_flag_i, // 是否发生转移
    input wire[`RegBus] branch_target_address_i, // 要转移的目标地址

    input wire flush, //流水线清除信号
    input wire[`RegBus] new_pc, //异常处理例程入口地址

    output reg[`InstAddrBus] pc, //要读取的指令地址
    output reg ce //指令存储器使能信号
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
