`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/06 20:16:47
// Design Name: 
// Module Name: div_tb
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


module div_tb();
    reg clk;
    reg rst;

    reg signed_div_i; //是否有符号除法
    reg[31:0] opdata1_i; //被除数
    reg[31:0] opdata2_i; //除数
    reg start_i; //是否开始除法运算
    reg annul_i; //是否取消除法运算

    wire[63:0] result_o; //运算结果
    wire ready_o; // 是否结束

    initial begin
        clk=0;
        rst=1;
        opdata1_i=32'b00000000000000000000000000001011;
        opdata2_i=32'b00000000000000000000000000000110;
        start_i=1'b1;
        annul_i=1'b0;
        signed_div_i=1'b1;
        #5 clk=1;
        #5 clk=0; rst=0;
        forever #5 clk=~clk;
    end


    div div(
        .clk(clk),
        .rst(rst),
        .signed_div_i(signed_div_i),
        .opdata1_i(opdata1_i),
        .opdata2_i(opdata2_i),
        .start_i(start_i),
        .annul_i(annul_i),
        .result_o(result_o),
        .ready_o(ready_o)
    );
endmodule
