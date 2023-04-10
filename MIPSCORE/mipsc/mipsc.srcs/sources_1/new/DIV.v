`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/02 16:43:27
// Design Name: 
// Module Name: div
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

module DIV(
    input wire clk,
    input wire rst,

    input wire signed_div_i, //是否有符号除法
    input wire[31:0] opdata1_i, //被除数
    input wire[31:0] opdata2_i, //除数
    input wire start_i, //是否开始除法运算
    input wire annul_i, //是否取消除法运算

    output reg[63:0] result_o, //运算结果
    output reg ready_o // 是否结束
);

    reg[5:0] cnt; //除法运算进行到了第几个周期

    reg[1:0] state; //状态DivFree DivOn DivByZero DivEnd
    reg[31:0] temp_op1; //被除数转换为绝对值原码
    reg[31:0] temp_op2; //除数转换为绝对值原码
    reg[31:0] quotient; //商
    reg[63:0] remainder; //余数
    wire[32:0]div_temp; //判断余数 33bit防溢出判断
    assign div_temp=(~{0,temp_op2}+1)+remainder[63:32];
    //remainder高32bit是待除的数

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            state <= `DivFree;
            ready_o <= `DivResultNotReady;
            result_o <= {`ZeroWord,`ZeroWord};
        end
        else begin
            case (state)
                `DivFree:begin //DivFree状态
                    if(start_i == `DivStart && annul_i == 1'b0) begin
                        if(opdata2_i == `ZeroWord) begin
                            state <= `DivByZero;
                        end
                        else begin
                            state <= `DivOn;//开启除法运算
                            cnt <= 6'b000000;//判断除法是否结束 即当前是第几个周期
                            quotient<=32'b00000000000000000000000000000000;//商的初始化
                            if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1 ) begin//有符号运算
                                temp_op1 <= ~opdata1_i + 1;//被除数
                                //首次实际上直接移动了被除数的最高位到remainder[32]
                                remainder<={31'b0000000000000000000000000000000,~opdata1_i[31:0]+1,1'b0};
                            end
                            else begin//无符号运算
                                temp_op1 <= opdata1_i;
                                remainder<={31'b0000000000000000000000000000000,opdata1_i[31:0],1'b0};
                            end
                            if(signed_div_i == 1'b1 && opdata2_i[31] == 1'b1 ) begin//有符号且是负数取绝对值
                                temp_op2 <= ~opdata2_i + 1;//除数
                            end
                            else begin
                                temp_op2 <= opdata2_i;
                            end
                        end
                    end
                    else begin
                        ready_o <= `DivResultNotReady;
                        result_o <= {`ZeroWord,`ZeroWord};
                    end
                end
                `DivByZero: begin //DivByZero状态
                    remainder <= {`ZeroWord,`ZeroWord};
                    state <= `DivEnd;
                end
                `DivOn: begin //DivOn状态
                    if(annul_i == 1'b0) begin
                    
                        if(cnt != 6'b011111) begin//没有到达最后一个周期
                            if(div_temp[32] == 1'b1) begin//不够除商0
                                remainder<=(remainder<<1);//继续左移
                                quotient[31:0] <= {quotient[30:0] ,1'b0};//商0左移
                            end
                            else begin//够除商1
                            // div[32]判溢出 div[31]完成本轮运算后被移出 实际上又再次补了一位剩下的待除部分
                                remainder[63:0] <= {div_temp[30:0],remainder[31:0],1'b0};
                                quotient[31:0]<={quotient[30:0],1'b1};//商1右移
                            end
                            cnt <= cnt + 1;
                        end
                        else begin//到达最后一个周期
                            if(div_temp[32]==1'b1) begin
                                quotient[31:0] <= {quotient[30:0],1'b0};//不够除商0 remainder最终不够除的部分就是余数
                            end
                            else begin
                                quotient[31:0]<={quotient[30:0],1'b1};//够除商1
                                //这里判断够不够除是通过待除部分与除数的减法运算 因此如果够除 减法运算后的结果才是真正的余数
                                remainder[63:32]<=div_temp[31:0]; //校正余数
                            end
                            state <= `DivEnd;
                            cnt <= 6'b000000;
                        end
                        
                    end
                    
                    else begin
                        state <= `DivFree;
                    end
                end
                `DivEnd:begin //DivEnd状态
                    if(opdata1_i[31]^opdata2_i[31]==1'b1&&signed_div_i==1'b1)begin
                        result_o[63:32]<=~quotient+1;
                    end
                    else begin
                        result_o[63:32]<=quotient;
                    end
                    if(opdata1_i[31]==1'b0||signed_div_i==1'b0)begin
                        result_o[31:0]<=remainder[63:32];
                    end
                    else begin
                        result_o[31:0]<=~remainder[63:32]+1;
                    end
                    ready_o <= `DivResultReady;
                    if(start_i == `DivStop) begin
                        state <= `DivFree;
                        ready_o <= `DivResultNotReady;
                        result_o <= {`ZeroWord,`ZeroWord};
                    end
                end
            endcase
        end
    end


endmodule
