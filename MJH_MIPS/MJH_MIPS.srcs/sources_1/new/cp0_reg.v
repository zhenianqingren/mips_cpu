`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/24 19:16:10
// Design Name: 
// Module Name: cp0_reg
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

module cp0_reg(

    input wire clk,
    input wire rst,

    input wire   we_i, //�Ƿ�ҪдCP0�еļĴ���
    input wire[4:0] waddr_i, // Ҫд��CP0�еļĴ����ĵ�ַ
    input wire[4:0] raddr_i, //Ҫ��ȡ��CP0�Ĵ����ĵ�ַ
    input wire[`RegBus] data_i, //Ҫд��CP0�мĴ���������

    input wire[5:0] int_i, //6���ⲿӲ���ж�����

    input wire[31:0] excepttype_i, //�쳣����
    input wire[`RegBus] current_inst_addr_i, //�����쳣��ָ���ַ
    input wire is_in_delayslot_i, //�Ƿ����ӳ�ָ��

    output reg[`RegBus] data_o, //������CP0��ĳ���Ĵ�����ֵ
    output reg[`RegBus] count_o, //count_o count�Ĵ�����ֵ
    output reg[`RegBus] compare_o, //compare�Ĵ�����ֵ
    output reg[`RegBus] status_o, //status�Ĵ�����ֵ
    output reg[`RegBus] cause_o, //cause�Ĵ�����ֵ
    output reg[`RegBus] epc_o, //EPC�Ĵ�����ֵ
    output reg[`RegBus] config_o, //config�Ĵ�����ֵ
    output reg[`RegBus] prid_o, //prid�Ĵ�����ֵ

    output reg timer_int_o //�Ƿ��ж�ʱ�жϵĲ���
);

    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            count_o <= `ZeroWord;
            compare_o <= `ZeroWord;
            //status�Ĵ�����CUΪ0001����ʾЭ������CP0����
            status_o <= 32'b00010000000000000000000000000000;
            cause_o <= `ZeroWord;
            epc_o <= `ZeroWord;
            //config�Ĵ�����BEΪ1����ʾBig-Endian��MTΪ00����ʾû��MMU
            config_o <= 32'b00000000000000001000000000000000;
            //��������L����Ӧ����0x48��������0x1���������ͣ��汾����1.0
            prid_o <= 32'b00000000010011000000000100000010;
            timer_int_o <= `InterruptNotAssert;
        end
        else begin
            count_o <= count_o + 1 ;
            cause_o[15:10] <= int_i;
            timer_int_o<=1'b0;
            if(compare_o != `ZeroWord && count_o == compare_o) begin
                timer_int_o <= `InterruptAssert;
            end

            if(we_i == `WriteEnable) begin
                case (waddr_i)
                    `CP0_REG_COUNT:begin
                        count_o <= data_i;
                    end
                    `CP0_REG_COMPARE:begin
                        compare_o <= data_i;
                        timer_int_o <= `InterruptNotAssert;
                    end
                    `CP0_REG_STATUS:begin
                        status_o <= data_i;
                    end
                    `CP0_REG_EPC:begin
                        epc_o <= data_i;
                    end
                    `CP0_REG_CAUSE:	begin
                        //cause�Ĵ���ֻ��IP[1:0]��IV��WP�ֶ��ǿ�д��
                        cause_o[9:8] <= data_i[9:8];
                        cause_o[23] <= data_i[23];
                        cause_o[22] <= data_i[22];
                    end
                endcase //case addr_i
            end

            case (excepttype_i)
                32'h00000001:begin //�ⲿ�ж�
                    if(is_in_delayslot_i == `InDelaySlot ) begin
                        epc_o <= current_inst_addr_i - 4 ;
                        cause_o[31] <= 1'b1; //cause�Ĵ�����BD�ֶ�
                    end
                    else begin
                        epc_o <= current_inst_addr_i;
                        cause_o[31] <= 1'b0;
                    end
                    status_o[1] <= 1'b1; //status�Ĵ�������Ϊ1 ��ֹ�ж�
                    cause_o[6:2] <= 5'b00000; //�ж��쳣
                end

                32'h00000008:begin //syscall
                    if(status_o[1] == 1'b0) begin
                        if(is_in_delayslot_i == `InDelaySlot ) begin
                            epc_o <= current_inst_addr_i - 4 ;
                            cause_o[31] <= 1'b1;
                        end
                        else begin
                            epc_o <= current_inst_addr_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01000; //Sys
                end
                32'h0000000a:begin
                    if(status_o[1] == 1'b0) begin
                        if(is_in_delayslot_i == `InDelaySlot ) begin
                            epc_o <= current_inst_addr_i - 4 ;
                            cause_o[31] <= 1'b1;
                        end
                        else begin
                            epc_o <= current_inst_addr_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01010; //δ����ָ��
                end
                32'h0000000d:begin
                    if(status_o[1] == 1'b0) begin
                        if(is_in_delayslot_i == `InDelaySlot ) begin
                            epc_o <= current_inst_addr_i - 4 ;
                            cause_o[31] <= 1'b1;
                        end
                        else begin
                            epc_o <= current_inst_addr_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01101; //����
                end
                32'h0000000c:begin //���
                    if(status_o[1] == 1'b0) begin
                        if(is_in_delayslot_i == `InDelaySlot ) begin
                            epc_o <= current_inst_addr_i - 4 ;
                            cause_o[31] <= 1'b1;
                        end else begin
                            epc_o <= current_inst_addr_i;
                            cause_o[31] <= 1'b0;
                        end
                    end
                    status_o[1] <= 1'b1;
                    cause_o[6:2] <= 5'b01100;
                end
                32'h0000000e:begin //eret
                    status_o[1] <= 1'b0;
                end
                default:begin
                end
            endcase

        end //if
    end //always

    always @ (*) begin
        if(rst == `RstEnable) begin
            data_o <= `ZeroWord;
        end
        else begin
            case (raddr_i)
                `CP0_REG_COUNT:begin
                    data_o <= count_o ;
                end
                `CP0_REG_COMPARE:begin
                    data_o <= compare_o ;
                end
                `CP0_REG_STATUS:begin
                    data_o <= status_o ;
                end
                `CP0_REG_CAUSE:begin
                    data_o <= cause_o ;
                end
                `CP0_REG_EPC:begin
                    data_o <= epc_o ;
                end
                `CP0_REG_PrId:begin
                    data_o <= prid_o ;
                end
                `CP0_REG_CONFIG:begin
                    data_o <= config_o ;
                end
                default:begin
                end
            endcase //case addr_i			
        end //if

    end //always


endmodule
