`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/25 16:18:43
// Design Name: 
// Module Name: ctrl
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


module Ctrl(
    input wire rst, //复位信号
    input wire stallreq_from_id, //译码阶段是否请求流水线暂停


    input wire[31:0] excepttype_i, //最终异常类型
    input wire[`RegBus] cp0_epc_i, //epc寄存器最新值
    //来自执行阶段的暂停请求
    input wire stallreq_from_ex, // 执行阶段是否请求流水线暂停
    output reg[5:0] stall, //暂停流水线控制信号

    output reg[`RegBus] new_pc, //新pc
    output reg flush //清除信号
);
    // stall[0] pc取值是否不变 1:保持不变
    // stall[1]  取值阶段是否暂停 1:暂停
    // stall[2] 译码阶段是否暂停 1
    // stall[3] 执行阶段是否暂停 1
    // stall[4] 访存阶段是否暂停 1
    // stall[5] 回写阶段是否暂停 1
    always @ (*) begin
        if(rst == `RstEnable) begin
            stall <= 6'b000000;
            flush <= 1'b0;
            new_pc <= `ZeroWord;
        end
        else if(excepttype_i != `ZeroWord) begin
            flush <= 1'b1;
            stall <= 6'b000000;
            case (excepttype_i)
                32'h00000001:begin //interrupt
                    new_pc <= 32'h0000000c;
                end
                32'h00000008:begin //syscall
                    new_pc <= 32'h00000020;
                end
                32'h0000000a:begin //inst_invalid
                    new_pc <= 32'h00000020;
                end
                32'h0000000d:begin //trap
                    new_pc <= 32'h00000020;
                end
                32'h0000000c:begin //ov
                    new_pc <= 32'h00000020;
                end
                32'h0000000e:begin //eret
                    new_pc <= cp0_epc_i;
                end
                default: begin
                end
            endcase
        end
        else if(stallreq_from_ex == `Stop) begin
            stall <= 6'b001111;
        end
        else if(stallreq_from_id == `Stop) begin
            stall <= 6'b000111;
        end
        else begin
            stall <= 6'b000000;
            flush <= 1'b0;
            new_pc <= `ZeroWord;
        end //if
    end //always

endmodule
