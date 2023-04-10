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

    input wire signed_div_i, //�Ƿ��з��ų���
    input wire[31:0] opdata1_i, //������
    input wire[31:0] opdata2_i, //����
    input wire start_i, //�Ƿ�ʼ��������
    input wire annul_i, //�Ƿ�ȡ����������

    output reg[63:0] result_o, //������
    output reg ready_o // �Ƿ����
);

    reg[5:0] cnt; //����������е��˵ڼ�������

    reg[1:0] state; //״̬DivFree DivOn DivByZero DivEnd
    reg[31:0] temp_op1; //������ת��Ϊ����ֵԭ��
    reg[31:0] temp_op2; //����ת��Ϊ����ֵԭ��
    reg[31:0] quotient; //��
    reg[63:0] remainder; //����
    wire[32:0]div_temp; //�ж����� 33bit������ж�
    assign div_temp=(~{0,temp_op2}+1)+remainder[63:32];
    //remainder��32bit�Ǵ�������

    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            state <= `DivFree;
            ready_o <= `DivResultNotReady;
            result_o <= {`ZeroWord,`ZeroWord};
        end
        else begin
            case (state)
                `DivFree:begin //DivFree״̬
                    if(start_i == `DivStart && annul_i == 1'b0) begin
                        if(opdata2_i == `ZeroWord) begin
                            state <= `DivByZero;
                        end
                        else begin
                            state <= `DivOn;//������������
                            cnt <= 6'b000000;//�жϳ����Ƿ���� ����ǰ�ǵڼ�������
                            quotient<=32'b00000000000000000000000000000000;//�̵ĳ�ʼ��
                            if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1 ) begin//�з�������
                                temp_op1 <= ~opdata1_i + 1;//������
                                //�״�ʵ����ֱ���ƶ��˱����������λ��remainder[32]
                                remainder<={31'b0000000000000000000000000000000,~opdata1_i[31:0]+1,1'b0};
                            end
                            else begin//�޷�������
                                temp_op1 <= opdata1_i;
                                remainder<={31'b0000000000000000000000000000000,opdata1_i[31:0],1'b0};
                            end
                            if(signed_div_i == 1'b1 && opdata2_i[31] == 1'b1 ) begin//�з������Ǹ���ȡ����ֵ
                                temp_op2 <= ~opdata2_i + 1;//����
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
                `DivByZero: begin //DivByZero״̬
                    remainder <= {`ZeroWord,`ZeroWord};
                    state <= `DivEnd;
                end
                `DivOn: begin //DivOn״̬
                    if(annul_i == 1'b0) begin
                    
                        if(cnt != 6'b011111) begin//û�е������һ������
                            if(div_temp[32] == 1'b1) begin//��������0
                                remainder<=(remainder<<1);//��������
                                quotient[31:0] <= {quotient[30:0] ,1'b0};//��0����
                            end
                            else begin//������1
                            // div[32]����� div[31]��ɱ���������Ƴ� ʵ�������ٴβ���һλʣ�µĴ�������
                                remainder[63:0] <= {div_temp[30:0],remainder[31:0],1'b0};
                                quotient[31:0]<={quotient[30:0],1'b1};//��1����
                            end
                            cnt <= cnt + 1;
                        end
                        else begin//�������һ������
                            if(div_temp[32]==1'b1) begin
                                quotient[31:0] <= {quotient[30:0],1'b0};//��������0 remainder���ղ������Ĳ��־�������
                            end
                            else begin
                                quotient[31:0]<={quotient[30:0],1'b1};//������1
                                //�����жϹ���������ͨ����������������ļ������� ���������� ���������Ľ����������������
                                remainder[63:32]<=div_temp[31:0]; //У������
                            end
                            state <= `DivEnd;
                            cnt <= 6'b000000;
                        end
                        
                    end
                    
                    else begin
                        state <= `DivFree;
                    end
                end
                `DivEnd:begin //DivEnd״̬
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
