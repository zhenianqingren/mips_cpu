`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/14 16:00:47
// Design Name: 
// Module Name: mem
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
// ��д�洢�� ����������
module MEM(
    input wire rst,

    //����ִ�н׶ε���Ϣ	
    input wire[`RegAddrBus] wd_i, //Ŀ�ļĴ�����ַ
    input wire wreg_i, //��д�Ĵ����ź�
    input wire[`RegBus] wdata_i, //�ô�׶�Ҫд���Ŀ�ļĴ�����ֵ

    input wire[`RegBus] hi_i, //hi�Ĵ���ֵ
    input wire[`RegBus] lo_i, //lo�Ĵ���ֵ
    input wire whilo_i, //lo hiдʹ���ź�

    input wire[`AluOpBus] aluop_i, //����������
    input wire[`RegBus] mem_addr_i, //�洢����ַ
    input wire[`RegBus] reg2_i, //�洢���洢���Ĳ���������lwl lwrԭʼ�Ĵ���ֵ

    //����memory����Ϣ
    input wire[`RegBus] mem_data_i, //���뵽�Ĵ�����ֵ

    //Э������CP0��д�ź�
    input wire cp0_reg_we_i,
    input wire[4:0] cp0_reg_write_addr_i,
    input wire[`RegBus] cp0_reg_data_i,
    // exception
    input wire[31:0] excepttype_i,
    input wire is_in_delayslot_i,
    input wire[`RegBus] current_inst_address_i,
    //CP0�ĸ����Ĵ�����ֵ������һ�������µ�ֵ��Ҫ��ֹ��д�׶�ָ��дCP0
    input wire[`RegBus] cp0_status_i, //status�Ĵ���
    input wire[`RegBus] cp0_cause_i, //cause�Ĵ���
    input wire[`RegBus] cp0_epc_i, //epc�Ĵ���
    //��д�׶ε�ָ���Ƿ�ҪдCP0����������������
    input wire wb_cp0_reg_we, //дʹ��
    input wire[4:0] wb_cp0_reg_write_addr, //д��ַ
    input wire[`RegBus]  wb_cp0_reg_data, //Ҫд��ֵ


    //�͵���д�׶ε���Ϣ
    output reg[`RegAddrBus] wd_o, //����Ҫд���Ŀ�ļĴ�����ַ
    output reg wreg_o, //��д�Ĵ����ź�
    output reg[`RegBus] wdata_o, //Ҫд��Ŀ�ļĴ�����ֵ

    output reg[`RegBus] hi_o,
    output reg[`RegBus] lo_o,
    output reg whilo_o,

    //�͵�memory
    output reg[`RegBus] mem_addr_o, //�ô��ַ
    output wire mem_we_o, //дʹ���ź�
    output reg[3:0] mem_sel_o, //�ֽ�ѡ�� 1���ֽ� ���� ��
    output reg[`RegBus] mem_data_o, //д�뵽�洢����ֵ
    output reg mem_ce_o, //���ݴ洢��ʹ���ź�

    //LLbit_i��LLbit�Ĵ�����ֵ
    input wire LLbit_i,
    //����һ��������ֵ����д�׶ο���ҪдLLbit�����Ի�Ҫ��һ���жϣ�����ǰ�������������������˿�
    input wire wb_LLbit_we_i,
    input wire wb_LLbit_value_i,

    output reg LLbit_we_o, //�ô�׶�ָ���Ƿ�ҪдLLbit�Ĵ�����ֵ
    output reg LLbit_value_o, //�ô�׶�Ҫд���LLbit�Ĵ�����ֵ

    //
    output reg cp0_reg_we_o,
    output reg[4:0] cp0_reg_write_addr_o,
    output reg[`RegBus] cp0_reg_data_o,

    //exception
    output reg[31:0] excepttype_o, //���յ��쳣����
    output wire[`RegBus] cp0_epc_o, //cp0��epc�Ĵ���������ֵ
    output wire is_in_delayslot_o, //�ӳ�ָ��
    output wire[`RegBus] current_inst_address_o //�ô�׶�ָ��ĵ�ַ
);

    reg LLbit; //����LLbit������ֵ
    reg[`RegBus] cp0_status; //status����ֵ
    reg[`RegBus] cp0_cause; //cause����ֵ
    reg[`RegBus] cp0_epc; //epc����ֵ

    assign is_in_delayslot_o = is_in_delayslot_i;
    assign current_inst_address_o = current_inst_address_i;
    assign cp0_epc_o = cp0_epc;

    // ����ǰ�ƻ��status�Ĵ���ֵ
    always @ (*) begin
        if(rst == `RstEnable) begin
            cp0_status <= `ZeroWord;
        end
        else if((wb_cp0_reg_we == `WriteEnable) &&
        (wb_cp0_reg_write_addr == `CP0_REG_STATUS ))begin
            cp0_status <= wb_cp0_reg_data;
        end
        else begin
            cp0_status <= cp0_status_i;
        end
    end
    //����ǰ�ƻ��epc�Ĵ���ֵ
    always @ (*) begin
        if(rst == `RstEnable) begin
            cp0_epc <= `ZeroWord;
        end else if((wb_cp0_reg_we == `WriteEnable) &&
        (wb_cp0_reg_write_addr == `CP0_REG_EPC ))begin
            cp0_epc <= wb_cp0_reg_data;
        end else begin
            cp0_epc <= cp0_epc_i;
        end
    end
    //����ǰ�ƻ��cause�Ĵ���ֵ
    always @ (*) begin
        if(rst == `RstEnable) begin
            cp0_cause <= `ZeroWord;
        end
        //ֻ��IP[1:0] IV WP�ֶο�д
        else if((wb_cp0_reg_we == `WriteEnable) &&
        (wb_cp0_reg_write_addr == `CP0_REG_CAUSE ))begin
            cp0_cause[9:8] <= wb_cp0_reg_data[9:8];
            cp0_cause[22] <= wb_cp0_reg_data[22];
            cp0_cause[23] <= wb_cp0_reg_data[23];
        end else begin
            cp0_cause <= cp0_cause_i;
        end
    end
    //���������쳣����
    always @ (*) begin
        if(rst == `RstEnable) begin
            excepttype_o <= `ZeroWord;
        end
        else begin
            excepttype_o <= `ZeroWord;
            if(current_inst_address_i != `ZeroWord) begin
                //�ж�ʹ��[0]&&��ʱδ��������interrupt&&�ⲿ�жϷ�������û�б�ȫ������
                if(((cp0_cause[15:8] & (cp0_status[15:8])) != 8'h00) && (cp0_status[1] == 1'b0) &&
                (cp0_status[0] == 1'b1)) begin
                    excepttype_o <= 32'h00000001; //interrupt �ⲿ�ж�
                end
                else if(excepttype_i[8] == 1'b1) begin
                    excepttype_o <= 32'h00000008; //syscall ϵͳ�����쳣
                end
                else if(excepttype_i[9] == 1'b1) begin
                    excepttype_o <= 32'h0000000a; //inst_invalid �Ƿ�ָ��
                end
                else if(excepttype_i[10] ==1'b1) begin
                    excepttype_o <= 32'h0000000d; //trap ����
                end
                else if(excepttype_i[11] == 1'b1) begin //ov ���
                    excepttype_o <= 32'h0000000c;
                end
                else if(excepttype_i[12] == 1'b1) begin //����ָ�� eret �쳣������Ϻ�ʹ��
                    excepttype_o <= 32'h0000000e;
                end
            end
        end
    end


    always @ (*) begin
        if(rst == `RstEnable) begin
            LLbit <= 1'b0;
        end
        else begin
            if(wb_LLbit_we_i == 1'b1) begin
                LLbit <= wb_LLbit_value_i;
            end
            else begin
                LLbit <= LLbit_i;
            end
        end
    end

    wire[`RegBus] zero32;
    reg mem_we; //ram�Ķ�д�ź�

    assign mem_we_o = mem_we & (~(|excepttype_o)) ;
    assign zero32 = `ZeroWord;

    always @ (*) begin
        if(rst == `RstEnable || is_in_delayslot_i==1) begin
            wd_o <= `NOPRegAddr;
            wreg_o <= `WriteDisable;
            wdata_o <= `ZeroWord;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
            whilo_o <= `WriteDisable;
            mem_addr_o <= `ZeroWord;
            mem_we <= `WriteDisable;
            mem_sel_o <= 4'b0000;
            mem_data_o <= `ZeroWord;
            mem_ce_o <= `ChipDisable;
            LLbit_we_o <= 1'b0;
            LLbit_value_o <= 1'b0;
            cp0_reg_we_o <= `WriteDisable;
            cp0_reg_write_addr_o <= 5'b00000;
            cp0_reg_data_o <= `ZeroWord;
        end
        else begin
            wd_o <= wd_i;
            wreg_o <= wreg_i;
            wdata_o <= wdata_i;
            hi_o <= hi_i;
            lo_o <= lo_i;
            whilo_o <= whilo_i;
            mem_we <= `WriteDisable;
            mem_addr_o <= `ZeroWord;
            mem_sel_o <= 4'b1111;
            mem_ce_o <= `ChipDisable;
            LLbit_we_o <= 1'b0;
            LLbit_value_o <= 1'b0;
            cp0_reg_we_o <= cp0_reg_we_i;
            cp0_reg_write_addr_o <= cp0_reg_write_addr_i;
            cp0_reg_data_o <= cp0_reg_data_i;
            mem_data_o<=`ZeroWord;
            case (aluop_i)
                `EXE_LB_OP: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteDisable;
                    mem_ce_o <= `ChipEnable;
                    case (mem_addr_i[1:0]) //һ���洢��Ԫ��32bit ���ڷǶ�����ֽ�ȡ������Ҫ�˽�����һ���ֽ�
                        2'b00: begin
                            wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
                            mem_sel_o <= 4'b1000;
                        end
                        2'b01: begin
                            wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
                            mem_sel_o <= 4'b0100;
                        end
                        2'b10: begin
                            wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
                            mem_sel_o <= 4'b0010;
                        end
                        2'b11: begin
                            wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
                            mem_sel_o <= 4'b0001;
                        end
                        default: begin
                            wdata_o <= `ZeroWord;
                        end
                    endcase
                end
                `EXE_LBU_OP: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteDisable;
                    mem_ce_o <= `ChipEnable;
                    case (mem_addr_i[1:0])
                        2'b00: begin
                            wdata_o <= {{24{1'b0}},mem_data_i[31:24]};
                            mem_sel_o <= 4'b1000;
                        end
                        2'b01: begin
                            wdata_o <= {{24{1'b0}},mem_data_i[23:16]};
                            mem_sel_o <= 4'b0100;
                        end
                        2'b10: begin
                            wdata_o <= {{24{1'b0}},mem_data_i[15:8]};
                            mem_sel_o <= 4'b0010;
                        end
                        2'b11: begin
                            wdata_o <= {{24{1'b0}},mem_data_i[7:0]};
                            mem_sel_o <= 4'b0001;
                        end
                        default: begin
                            wdata_o <= `ZeroWord;
                        end
                    endcase
                end
//                `EXE_LH_OP: begin
//                    mem_addr_o <= mem_addr_i;
//                    mem_we <= `WriteDisable;
//                    mem_ce_o <= `ChipEnable;
//                    case (mem_addr_i[1:0]) //���ڰ��ֶ��� һ���ڴ浥Ԫֻ���������00->31:16 10->15:0
//                        2'b00: begin
//                            wdata_o <= {{16{mem_data_i[31]}},mem_data_i[31:16]};
//                            mem_sel_o <= 4'b1100;
//                        end
//                        2'b10: begin
//                            wdata_o <= {{16{mem_data_i[15]}},mem_data_i[15:0]};
//                            mem_sel_o <= 4'b0011;
//                        end
//                        default: begin
//                            wdata_o <= `ZeroWord;
//                        end
//                    endcase
//                end
//                `EXE_LHU_OP: begin
//                    mem_addr_o <= mem_addr_i;
//                    mem_we <= `WriteDisable;
//                    mem_ce_o <= `ChipEnable;
//                    case (mem_addr_i[1:0])
//                        2'b00: begin
//                            wdata_o <= {{16{1'b0}},mem_data_i[31:16]};
//                            mem_sel_o <= 4'b1100;
//                        end
//                        2'b10: begin
//                            wdata_o <= {{16{1'b0}},mem_data_i[15:0]};
//                            mem_sel_o <= 4'b0011;
//                        end
//                        default: begin
//                            wdata_o <= `ZeroWord;
//                        end
//                    endcase
//                end
                `EXE_LW_OP: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteDisable;
                    wdata_o <= mem_data_i;
                    mem_sel_o <= 4'b1111;
                    mem_ce_o <= `ChipEnable;
                end
//                `EXE_LWL_OP: begin //���4-n���ֽڱ����ڸ�λ
//                    mem_addr_o <= {mem_addr_i[31:2], 2'b00};
//                    mem_we <= `WriteDisable;
//                    mem_sel_o <= 4'b1111;
//                    mem_ce_o <= `ChipEnable;
//                    case (mem_addr_i[1:0])
//                        2'b00: begin
//                            wdata_o <= mem_data_i[31:0];
//                        end
//                        2'b01: begin
//                            wdata_o <= {mem_data_i[23:0],reg2_i[7:0]};
//                        end
//                        2'b10: begin
//                            wdata_o <= {mem_data_i[15:0],reg2_i[15:0]};
//                        end
//                        2'b11: begin
//                            wdata_o <= {mem_data_i[7:0],reg2_i[23:0]};
//                        end
//                        default: begin
//                            wdata_o <= `ZeroWord;
//                        end
//                    endcase
//                end
//                `EXE_LWR_OP: begin //���n+1���ֽڱ����ڵ�λ
//                    mem_addr_o <= {mem_addr_i[31:2], 2'b00};
//                    mem_we <= `WriteDisable;
//                    mem_sel_o <= 4'b1111;
//                    mem_ce_o <= `ChipEnable;
//                    case (mem_addr_i[1:0])
//                        2'b00: begin
//                            wdata_o <= {reg2_i[31:8],mem_data_i[31:24]};
//                        end
//                        2'b01: begin
//                            wdata_o <= {reg2_i[31:16],mem_data_i[31:16]};
//                        end
//                        2'b10: begin
//                            wdata_o <= {reg2_i[31:24],mem_data_i[31:8]};
//                        end
//                        2'b11: begin
//                            wdata_o <= mem_data_i;
//                        end
//                        default: begin
//                            wdata_o <= `ZeroWord;
//                        end
//                    endcase
//                end
                `EXE_SB_OP: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteEnable;
                    mem_data_o <= {reg2_i[7:0],reg2_i[7:0],reg2_i[7:0],reg2_i[7:0]};
                    mem_ce_o <= `ChipEnable;
                    case (mem_addr_i[1:0]) //�洢��һ���ڴ浥Ԫ�洢�ֵ���һ���ֽ�
                        2'b00: begin
                            mem_sel_o <= 4'b1000;
                        end
                        2'b01: begin
                            mem_sel_o <= 4'b0100;
                        end
                        2'b10: begin
                            mem_sel_o <= 4'b0010;
                        end
                        2'b11: begin
                            mem_sel_o <= 4'b0001;
                        end
                        default: begin
                            mem_sel_o <= 4'b0000;
                        end
                    endcase
                end
//                `EXE_SH_OP: begin
//                    mem_addr_o <= mem_addr_i;
//                    mem_we <= `WriteEnable;
//                    mem_data_o <= {reg2_i[15:0],reg2_i[15:0]};
//                    mem_ce_o <= `ChipEnable;
//                    case (mem_addr_i[1:0])
//                        2'b00: begin
//                            mem_sel_o <= 4'b1100;
//                        end
//                        2'b10: begin
//                            mem_sel_o <= 4'b0011;
//                        end
//                        default: begin
//                            mem_sel_o <= 4'b0000;
//                        end
//                    endcase
//                end
                `EXE_SW_OP: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteEnable;
                    mem_data_o <= reg2_i;
                    mem_sel_o <= 4'b1111;
                    mem_ce_o <= `ChipEnable;
                end
//                `EXE_SWL_OP: begin //���4-n���ֽڴ洢��mem_addr_align�ĵ�λ ��λ��Ϊ0
//                    mem_addr_o <= {mem_addr_i[31:2], 2'b00};
//                    mem_we <= `WriteEnable;
//                    mem_ce_o <= `ChipEnable;
//                    case (mem_addr_i[1:0])
//                        2'b00: begin
//                            mem_sel_o <= 4'b1111;
//                            mem_data_o <= reg2_i;
//                        end
//                        2'b01: begin
//                            mem_sel_o <= 4'b0111;
//                            mem_data_o <= {zero32[7:0],reg2_i[31:8]};
//                        end
//                        2'b10: begin
//                            mem_sel_o <= 4'b0011;
//                            mem_data_o <= {zero32[15:0],reg2_i[31:16]};
//                        end
//                        2'b11: begin
//                            mem_sel_o <= 4'b0001;
//                            mem_data_o <= {zero32[23:0],reg2_i[31:24]};
//                        end
//                        default: begin
//                            mem_sel_o <= 4'b0000;
//                        end
//                    endcase
//                end
//                `EXE_SWR_OP: begin //���n+1���ֽڴ�����ڴ浥Ԫmem_addr_align�ĸߴ�
//                    mem_addr_o <= {mem_addr_i[31:2], 2'b00};
//                    mem_we <= `WriteEnable;
//                    mem_ce_o <= `ChipEnable;
//                    case (mem_addr_i[1:0])
//                        2'b00:	begin
//                            mem_sel_o <= 4'b1000;
//                            mem_data_o <= {reg2_i[7:0],zero32[23:0]};
//                        end
//                        2'b01:	begin
//                            mem_sel_o <= 4'b1100;
//                            mem_data_o <= {reg2_i[15:0],zero32[15:0]};
//                        end
//                        2'b10:	begin
//                            mem_sel_o <= 4'b1110;
//                            mem_data_o <= {reg2_i[23:0],zero32[7:0]};
//                        end
//                        2'b11:	begin
//                            mem_sel_o <= 4'b1111;
//                            mem_data_o <= reg2_i[31:0];
//                        end
//                        default:	begin
//                            mem_sel_o <= 4'b0000;
//                        end
//                    endcase
//                end
                `EXE_LL_OP: begin
                    mem_addr_o <= mem_addr_i;
                    mem_we <= `WriteDisable;
                    LLbit_we_o <= 1'b1;
                    LLbit_value_o <= 1'b1;
                    mem_ce_o <= `ChipEnable;
                    case (mem_addr_i[1:0]) //����λ��չ ���
                        2'b00: begin
                            wdata_o <= {{24{mem_data_i[31]}},mem_data_i[31:24]};
                            mem_sel_o <= 4'b1000;
                        end
                        2'b01: begin
                            wdata_o <= {{24{mem_data_i[23]}},mem_data_i[23:16]};
                            mem_sel_o <= 4'b0100;
                        end
                        2'b10: begin
                            wdata_o <= {{24{mem_data_i[15]}},mem_data_i[15:8]};
                            mem_sel_o <= 4'b0010;
                        end
                        2'b11: begin
                            wdata_o <= {{24{mem_data_i[7]}},mem_data_i[7:0]};
                            mem_sel_o <= 4'b0001;
                        end
                        default: begin
                            wdata_o <= `ZeroWord;
                        end
                    endcase
                end
                `EXE_SC_OP: begin
                    if(LLbit == 1'b1) begin
                        LLbit_we_o <= 1'b1;
                        LLbit_value_o <= 1'b0;
                        mem_addr_o <= mem_addr_i;
                        mem_we <= `WriteEnable;
                        mem_data_o <= reg2_i;
                        wdata_o <= 32'b00000000000000000000000000000001;
                        mem_sel_o <= 4'b1111;
                        mem_ce_o <= `ChipEnable;
                    end
                    else begin
                        wdata_o <= 32'b00000000000000000000000000000000;
                    end
                end

                default: begin
                    //ʲôҲ����
                end
            endcase


        end //if
    end //always





endmodule
