`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/09 22:44:59
// Design Name: 
// Module Name: if_id
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
//IF/ID 暂时保存取得的指令地址以及指令 并在下一个时钟周期传递到译码阶段
module IFtoID(
    input wire clk,
    input wire rst,
    input wire[`InstAddrBus] if_pc, //取指阶段取得的指令地址
    input wire[`InstBus] if_inst, //取指阶段取得的指令

    input wire[5:0] stall, //暂停信号
    input wire flush, //流水线清除信号

    output reg[`InstAddrBus] id_pc, //译码阶段指令对应的地址
    output reg[`InstBus] id_inst //译码阶段的指令
);
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end
        else if(flush == 1'b1 ) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end
        // 取指阶段暂停译码阶段不暂停 插入空指令周期
        else if(stall[1] == `Stop && stall[2] == `NoStop) begin
            id_pc <= `ZeroWord;
            id_inst <= `ZeroWord;
        end
        else if(stall[1] == `NoStop) begin
            id_pc <= if_pc;
            id_inst <= if_inst;
        end
    end

endmodule
