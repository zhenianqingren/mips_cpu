`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/14 15:29:32
// Design Name: 
// Module Name: ex
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
// ���ݵõ�����Ϣ����ָ���ִ��
module ex(
    input wire rst,
    //�͵�ִ�н׶ε���Ϣ
    input wire[`AluOpBus] aluop_i, //����������
    input wire[`AluSelBus] alusel_i, //��������
    input wire[`RegBus] reg1_i, //Դ������1
    input wire[`RegBus] reg2_i, //Դ������2
    input wire[`RegAddrBus] wd_i, //Ҫд���Ŀ�ļĴ�����ַ
    input wire wreg_i, //�Ƿ���Ҫд���Ŀ�ļĴ���

    //HI��LO�Ĵ�����ֵ
    input wire[`RegBus] hi_i,
    input wire[`RegBus] lo_i,

    //��д�׶ε�ָ���Ƿ�ҪдHI��LO�����ڼ��HI��LO���������
    input wire[`RegBus] wb_hi_i, //hiֵ
    input wire[`RegBus] wb_lo_i, //loֵ
    input wire wb_whilo_i, //�Ƿ�д��lo hi

    //�ô�׶ε�ָ���Ƿ�ҪдHI��LO�����ڼ��HI��LO���������
    input wire[`RegBus] mem_hi_i, //hiֵ
    input wire[`RegBus] mem_lo_i, //loֵ
    input wire mem_whilo_i, //�Ƿ�д��lo hi

    input wire[`DoubleRegBus] hilo_temp_i, //��һ��ִ�����ڵõ��ĳ˷����
    input wire[1:0] cnt_i, //��ǰ����ִ�н׶εĵڼ�������

    //�����ģ������
    input wire[`DoubleRegBus] div_result_i, //����������
    input wire div_ready_i, //���������Ƿ����

    input wire[`RegBus] link_address_i, //����ִ�н׶ε�ָ��Ҫ����ķ��ص�ַ
    input wire is_delay_i, //��ǰҪִ�е�ָ���Ƿ����ӳ�ָ��

    input wire[`RegBus]  inst_i, //ִ�н׶�����ִ�е�ָ�� ����ô��ַ
    //�ô�׶ε�ָ���Ƿ�ҪдCP0����������������
    input wire mem_cp0_reg_we,
    input wire[4:0] mem_cp0_reg_write_addr,
    input wire[`RegBus] mem_cp0_reg_data,

    //��д�׶ε�ָ���Ƿ�ҪдCP0����������������
    input wire wb_cp0_reg_we,
    input wire[4:0] wb_cp0_reg_write_addr,
    input wire[`RegBus] wb_cp0_reg_data,

    //��CP0��������ȡ����CP0�Ĵ�����ֵ
    input wire[`RegBus] cp0_reg_data_i,

    // exception
    input wire[31:0] excepttype_i, //����׶��ռ������쳣��Ϣ
    input wire[`RegBus] current_inst_address_i, //����׶�ִ��ָ��ĵ�ַ


    output reg[`RegBus] hi_o, //ִ�н׶ε�ָ��Ҫд��hi�Ĵ�����ֵ
    output reg[`RegBus] lo_o, //ִ�н׶ε�ָ��Ҫд��lo�Ĵ�����ֵ
    output reg whilo_o, //ִ�н׶ε�ָ���Ƿ�Ҫдhi lo�Ĵ���


    output reg[`RegAddrBus] wd_o, //ִ�н׶ε�ָ������Ҫд���Ŀ�ļĴ�����ַ
    output reg wreg_o, //��д�Ĵ����ź�
    output reg[`RegBus] wdata_o, //д��Ŀ�ļĴ�����ֵ

    output reg[`DoubleRegBus] hilo_temp_o, //��һ��ִ�����ڵõ��ĳ˷����
    output reg[1:0] cnt_o, //��һ��ִ�����ڴ���ִ�н׶εĵڼ�������

    output reg[`RegBus] div_opdata1_o, //������
    output reg[`RegBus] div_opdata2_o, //����
    output reg div_start_o, //�Ƿ�ʼ��������
    output reg signed_div_o, //�Ƿ����з��ų���

    // �ô�
    output wire[`AluOpBus] aluop_o, //����������
    output wire[`RegBus] mem_addr_o, //�洢����ַ
    output wire[`RegBus] reg2_o, //�洢ָ��Ҫ�洢������ ����lwl lwrҪ���ص�Ŀ�ļĴ�����ԭʼֵ
    output reg stallreq,

    output reg[4:0] cp0_reg_read_addr_o, //ִ��ʱҪ��ȡ��cp0�мĴ�����ֵ

    //����һ��ˮ�����ݣ�����дCP0�еļĴ���
    output reg cp0_reg_we_o, //cp0�Ĵ���дʹ��
    output reg[4:0] cp0_reg_write_addr_o, //Ҫ��cp0�ĸ��Ĵ���д��
    output reg[`RegBus] cp0_reg_data_o, //д���ֵ

    //exception
    output wire[31:0] excepttype_o, //����׶��ռ������쳣��Ϣ
    output wire is_in_delayslot_o, //ִ�н׶ε�ָ���Ƿ��Ƿ�ָ֧�����һ��(�ӳٲ�)
    output wire[`RegBus] current_inst_address_o //��ǰִ��ָ��ĵ�ַ

);

    assign aluop_o=aluop_i; //���ݵ��ô�׶�
    assign mem_addr_o=reg1_i+{{16{inst_i[15]}},inst_i[15:0]}; //�ô��ַ
    assign reg2_o=reg2_i;

    // �����߼�����Ľ��
    reg[`RegBus] logicout;
    // ������λ������
    reg[`RegBus] shiftres;
    reg[`RegBus] moveres; // �ƶ������Ľ��
    reg[`RegBus] arithmeticres; //��������������
    reg[`DoubleRegBus] mulres; //����˷���� ���64bit
    reg[`RegBus] HI; //hi�Ĵ���������ֵ
    reg[`RegBus] LO; //lo�Ĵ���������ֵ

    wire[`RegBus] reg2_i_mux; //��������ĵڶ����������Ĳ���
    wire[`RegBus] reg1_i_not; //��������ĵ�һ���������ķ���
    wire[`RegBus] result_sum; //����ӷ����
    wire ov_sum; //����������
    wire reg1_eq_reg2; //��һ���������Ƿ���ڵڶ���������
    wire reg1_lt_reg2; //��һ���������Ƿ�С�ڵڶ���������
    wire[`RegBus] opdata1_mult; //������
    wire[`RegBus] opdata2_mult; //����
    wire[`DoubleRegBus] hilo_temp; //��ʱ����˷����

    reg[`DoubleRegBus] hilo_temp1;
    reg stallreq_for_madd_msub;

    reg stallreq_for_div; //�Ƿ����ڳ��������������ˮ����ͣ
//    reg trapassert; //�Ƿ��������쳣
    reg ovassert; //�Ƿ�������쳣
    assign excepttype_o = {excepttype_i[31:12],ovassert,/*trapassert*/1'b0,excepttype_i[9:8],8'h00};
    //�ⲿ�ж�+id(syscall eret)+���������+����׶���Ϣ
    assign is_in_delayslot_o = is_delay_i;
    assign current_inst_address_o = current_inst_address_i;

    //�������ֵ
    //���������з��űȽ� ���� reg2_i_mux���ڵڶ����������Ĳ��� ��֮���ڵڶ���������
    assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) ||( aluop_i == `EXE_SLT_OP)/*|| (aluop_i == `EXE_TLT_OP) ||
    (aluop_i == `EXE_TLTI_OP) || (aluop_i == `EXE_TGE_OP) ||
    (aluop_i == `EXE_TGEI_OP)*/)
    ? (~reg2_i)+1 : reg2_i;
    // ��ȥһ�������ڼ�����������෴�� �ӷ� ���� �Ƚ� �������
    assign result_sum = reg1_i + reg2_i_mux;
    // �Ƿ���� ����֮��Ϊ����001 ����֮��Ϊ����110
    assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) ||
    ((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));
    // ������1�Ƿ�С�ڲ�����2
    assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP)/*|| (aluop_i == `EXE_TLT_OP) ||
    (aluop_i == `EXE_TLTI_OP) || (aluop_i == `EXE_TGE_OP) ||
    (aluop_i == `EXE_TGEI_OP)*/) ?
    ((reg1_i[31] && !reg2_i[31]) ||
    (!reg1_i[31] && !reg2_i[31] && result_sum[31])||
    (reg1_i[31] && reg2_i[31] && result_sum[31]))
    :	(reg1_i < reg2_i);
    // ȡ�ò�����1�ķ��� 
    assign reg1_i_not = ~reg1_i;

    //���ݽ���ж��Ƿ�������
//    always @ (*) begin
//        if(rst == `RstEnable) begin
//            trapassert <= `TrapNotAssert;
//        end
//        else begin
//            trapassert <= `TrapNotAssert;
//            case (aluop_i)
//                `EXE_TEQ_OP, `EXE_TEQI_OP:begin
//                    if( reg1_i == reg2_i ) begin
//                        trapassert <= `TrapAssert;
//                    end
//                end
//                `EXE_TGE_OP, `EXE_TGEI_OP, `EXE_TGEIU_OP, `EXE_TGEU_OP:begin
//                    if( ~reg1_lt_reg2 ) begin
//                        trapassert <= `TrapAssert;
//                    end
//                end
//                `EXE_TLT_OP, `EXE_TLTI_OP, `EXE_TLTIU_OP, `EXE_TLTU_OP:begin
//                    if( reg1_lt_reg2 ) begin
//                        trapassert <= `TrapAssert;
//                    end
//                end
//                `EXE_TNE_OP, `EXE_TNEI_OP:begin
//                    if( reg1_i != reg2_i ) begin
//                        trapassert <= `TrapAssert;
//                    end
//                end
//                default:begin
//                    trapassert <= `TrapNotAssert;
//                end
//            endcase
//        end
//    end



    // ��������  �ӷ�&&����
    always @ (*) begin
        if(rst == `RstEnable) begin
            arithmeticres <= `ZeroWord;
        end
        else begin
            case (aluop_i)
                `EXE_SLT_OP, `EXE_SLTU_OP:begin
                    arithmeticres <= reg1_lt_reg2 ;
                end
                `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP:begin
                    arithmeticres <= result_sum;
                end
                `EXE_SUB_OP, `EXE_SUBU_OP:begin
                    arithmeticres <= result_sum;
                end
//                `EXE_CLZ_OP:begin
//                    arithmeticres <= reg1_i[31] ? 0 : reg1_i[30] ? 1 : reg1_i[29] ? 2 :
//                    reg1_i[28] ? 3 : reg1_i[27] ? 4 : reg1_i[26] ? 5 :
//                    reg1_i[25] ? 6 : reg1_i[24] ? 7 : reg1_i[23] ? 8 :
//                    reg1_i[22] ? 9 : reg1_i[21] ? 10 : reg1_i[20] ? 11 :
//                    reg1_i[19] ? 12 : reg1_i[18] ? 13 : reg1_i[17] ? 14 :
//                    reg1_i[16] ? 15 : reg1_i[15] ? 16 : reg1_i[14] ? 17 :
//                    reg1_i[13] ? 18 : reg1_i[12] ? 19 : reg1_i[11] ? 20 :
//                    reg1_i[10] ? 21 : reg1_i[9] ? 22 : reg1_i[8] ? 23 :
//                    reg1_i[7] ? 24 : reg1_i[6] ? 25 : reg1_i[5] ? 26 :
//                    reg1_i[4] ? 27 : reg1_i[3] ? 28 : reg1_i[2] ? 29 :
//                    reg1_i[1] ? 30 : reg1_i[0] ? 31 : 32 ;
//                end
//                `EXE_CLO_OP:begin
//                    arithmeticres <= (reg1_i_not[31] ? 0 : reg1_i_not[30] ? 1 : reg1_i_not[29] ? 2 :
//                    reg1_i_not[28] ? 3 : reg1_i_not[27] ? 4 : reg1_i_not[26] ? 5 :
//                    reg1_i_not[25] ? 6 : reg1_i_not[24] ? 7 : reg1_i_not[23] ? 8 :
//                    reg1_i_not[22] ? 9 : reg1_i_not[21] ? 10 : reg1_i_not[20] ? 11 :
//                    reg1_i_not[19] ? 12 : reg1_i_not[18] ? 13 : reg1_i_not[17] ? 14 :
//                    reg1_i_not[16] ? 15 : reg1_i_not[15] ? 16 : reg1_i_not[14] ? 17 :
//                    reg1_i_not[13] ? 18 : reg1_i_not[12] ? 19 : reg1_i_not[11] ? 20 :
//                    reg1_i_not[10] ? 21 : reg1_i_not[9] ? 22 : reg1_i_not[8] ? 23 :
//                    reg1_i_not[7] ? 24 : reg1_i_not[6] ? 25 : reg1_i_not[5] ? 26 :
//                    reg1_i_not[4] ? 27 : reg1_i_not[3] ? 28 : reg1_i_not[2] ? 29 :
//                    reg1_i_not[1] ? 30 : reg1_i_not[0] ? 31 : 32) ;
//                end
                default:begin
                    arithmeticres <= `ZeroWord;
                end
            endcase
        end
    end

    // �������� �˷� 
    // ȡ�ó˷����㱻���� ������з��ų˷����ұ������Ǹ��� ��ôȡ����
    assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP)||
    (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) && (reg1_i[31] == 1'b1))?
    (~reg1_i + 1) : reg1_i;

    // ���ڱ����� ����ͬ���ĵ���
    assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP)||
    (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) && (reg2_i[31] == 1'b1)) ?
    (~reg2_i + 1) : reg2_i;

    // �˷����
    assign hilo_temp = opdata1_mult * opdata2_mult;
    // �������ս�� 
    always @ (*) begin
        if(rst == `RstEnable) begin
            mulres <= {`ZeroWord,`ZeroWord};
        end
        else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP)||
        (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP))begin //�з������
            if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin //���
                mulres <= ~hilo_temp + 1;
            end
            else begin //ͬ��
                mulres <= hilo_temp;
            end
        end
        else begin // �޷������
            mulres <= hilo_temp;
        end
    end

    // �۳˼� MADD MADDU MSUB MSUBU
    always @ (*) begin
        if(rst == `RstEnable) begin
            hilo_temp_o <= {`ZeroWord,`ZeroWord};
            cnt_o <= 2'b00;
            stallreq_for_madd_msub <= `NoStop;
        end
        else begin
            case (aluop_i)
                `EXE_MADD_OP,`EXE_MADDU_OP:begin
                    if(cnt_i == 2'b00) begin //���ۼӵ�һ������
                        hilo_temp_o <= mulres;
                        cnt_o <= 2'b01;
                        stallreq_for_madd_msub <= `Stop;
                        hilo_temp1 <= {`ZeroWord,`ZeroWord};
                    end
                    else if(cnt_i == 2'b01) begin //���ۼӵڶ�������
                        hilo_temp_o <= {`ZeroWord,`ZeroWord};
                        cnt_o <= 2'b00; //�ص�00
                        hilo_temp1 <= hilo_temp_i + {HI,LO};
                        stallreq_for_madd_msub <= `NoStop;
                    end
                end
                `EXE_MSUB_OP,`EXE_MSUBU_OP:begin
                    if(cnt_i == 2'b00) begin // ���ۼ���һ������
                        hilo_temp_o <=  ~mulres + 1;
                        cnt_o <= 2'b01;
                        stallreq_for_madd_msub <= `Stop;
                    end
                    else if(cnt_i == 2'b01)begin // ���ۼ��ڶ�������
                        hilo_temp_o <= {`ZeroWord,`ZeroWord};
                        cnt_o <= 2'b00;
                        hilo_temp1 <= hilo_temp_i + {HI,LO};
                        stallreq_for_madd_msub <= `NoStop;
                    end
                end
                default:begin
                    hilo_temp_o <= {`ZeroWord,`ZeroWord};
                    cnt_o <= 2'b00;
                    stallreq_for_madd_msub <= `NoStop;
                end
            endcase
        end
    end




    // ��ȡlo hiֵ ������ݳ�ͻ���� ִ��ʱ��ˮ���е��������д
    always @ (*) begin
        if(rst == `RstEnable) begin
            {HI,LO} <= {`ZeroWord,`ZeroWord};
        end
        else if(mem_whilo_i == `WriteEnable) begin
            {HI,LO} <= {mem_hi_i,mem_lo_i};
        end
        else if(wb_whilo_i == `WriteEnable) begin
            {HI,LO} <= {wb_hi_i,wb_lo_i};
        end
        else begin
            {HI,LO} <= {hi_i,lo_i};
        end
    end

    //MFHI��MFLO��MOVN��MOVZ MFC0ָ��
    always @ (*) begin
        if(rst == `RstEnable) begin
            moveres <= `ZeroWord;
            cp0_reg_read_addr_o=5'b00000;
        end
        else begin
            moveres <= `ZeroWord;

            case (aluop_i)
                `EXE_MFHI_OP:begin
                    moveres <= HI;
                end
                `EXE_MFLO_OP:begin
                    moveres <= LO;
                end
                `EXE_MOVZ_OP:begin
                    moveres <= reg1_i;
                end
                `EXE_MOVN_OP:begin
                    moveres <= reg1_i;
                end
                `EXE_MFC0_OP:begin
                    cp0_reg_read_addr_o <= inst_i[15:11];
                    moveres <= cp0_reg_data_i;
                    if( mem_cp0_reg_we == `WriteEnable &&
                    mem_cp0_reg_write_addr == inst_i[15:11] ) begin
                        moveres <= mem_cp0_reg_data;
                    end
                    else if( wb_cp0_reg_we == `WriteEnable &&
                    wb_cp0_reg_write_addr == inst_i[15:11] ) begin
                        moveres <= wb_cp0_reg_data;
                    end
                end
                default:begin
                end
            endcase

        end
    end


    // �����߼�����
    always @ (*) begin
        if(rst == `RstEnable) begin
            logicout <= `ZeroWord;
        end
        else begin

            case (aluop_i)
                `EXE_OR_OP: begin //������
                    logicout <= reg1_i | reg2_i;
                end
                `EXE_AND_OP:begin //������
                    logicout <= reg1_i & reg2_i;
                end
                `EXE_NOR_OP:begin //�������
                    logicout <= ~(reg1_i |reg2_i);
                end
                `EXE_XOR_OP:begin // �������
                    logicout <= reg1_i ^ reg2_i;
                end
                default: begin
                    logicout <= `ZeroWord;
                end
            endcase

        end //if
    end //always

    // ������λ����
    always @ (*) begin
        if(rst == `RstEnable) begin
            shiftres <= `ZeroWord;
        end
        else begin

            case (aluop_i)
                `EXE_SLL_OP:begin //�߼�����
                    shiftres <= reg2_i << reg1_i[4:0] ;
                end
                `EXE_SRL_OP:begin //�߼�����
                    shiftres <= reg2_i >> reg1_i[4:0];
                end
                `EXE_SRA_OP:begin //��������
                    shiftres <= ({32{reg2_i[31]}} << (6'd32-{1'b0, reg1_i[4:0]}))
                    | reg2_i >> reg1_i[4:0];
                end
                default:begin
                    shiftres <= `ZeroWord;
                end
            endcase

        end //if
    end //always


    // ���г�������
    always @ (*) begin
        if(rst == `RstEnable) begin
            stallreq_for_div <= `NoStop;
            div_opdata1_o <= `ZeroWord;
            div_opdata2_o <= `ZeroWord;
            div_start_o <= `DivStop;
            signed_div_o <= 1'b0;
        end
        else begin

            stallreq_for_div <= `NoStop;
            div_opdata1_o <= `ZeroWord;
            div_opdata2_o <= `ZeroWord;
            div_start_o <= `DivStop;
            signed_div_o <= 1'b0;
            case (aluop_i)
                `EXE_DIV_OP: begin // �з��ų���
                    if(div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o <= reg1_i; //������
                        div_opdata2_o <= reg2_i; //����
                        div_start_o <= `DivStart; //��ʼ��������
                        signed_div_o <= 1'b1; //�з�������
                        stallreq_for_div <= `Stop; //������ˮ����ͣ
                    end
                    else if(div_ready_i == `DivResultReady) begin //�����������
                        div_opdata1_o <= reg1_i;
                        div_opdata2_o <= reg2_i;
                        div_start_o <= `DivStop;
                        signed_div_o <= 1'b1;
                        stallreq_for_div <= `NoStop;
                    end
                    else begin
                        div_opdata1_o <= `ZeroWord;
                        div_opdata2_o <= `ZeroWord;
                        div_start_o <= `DivStop;
                        signed_div_o <= 1'b0;
                        stallreq_for_div <= `NoStop;
                    end
                end
                `EXE_DIVU_OP: begin //�޷��ų���
                    if(div_ready_i == `DivResultNotReady) begin //��ʼ�޷��ų�������
                        div_opdata1_o <= reg1_i;
                        div_opdata2_o <= reg2_i;
                        div_start_o <= `DivStart;
                        signed_div_o <= 1'b0;
                        stallreq_for_div <= `Stop;
                    end
                    else if(div_ready_i == `DivResultReady) begin //�������
                        div_opdata1_o <= reg1_i;
                        div_opdata2_o <= reg2_i;
                        div_start_o <= `DivStop;
                        signed_div_o <= 1'b0;
                        stallreq_for_div <= `NoStop;
                    end
                    else begin
                        div_opdata1_o <= `ZeroWord;
                        div_opdata2_o <= `ZeroWord;
                        div_start_o <= `DivStop;
                        signed_div_o <= 1'b0;
                        stallreq_for_div <= `NoStop;
                    end
                end
                default: begin
                end
            endcase

        end
    end

// �˴�*�ǹؼ� һ��û��stall������ ��ô������0
    always @ (*) begin
        stallreq = stallreq_for_madd_msub || stallreq_for_div;
    end //��ˮ����ͣ




    // ����alusel_i ѡ��һ�������Ϊ����������
    always @ (*) begin
        wd_o <= wd_i;
        if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) ||
        (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
            wreg_o <= `WriteDisable;
            ovassert <= 1'b1; //����
        end
        else begin
            wreg_o <= wreg_i;
            ovassert <= 1'b0; //δ����
        end
        case ( alusel_i )
            `EXE_RES_LOGIC:begin //�߼�������
                wdata_o <= logicout;
            end
            `EXE_RES_SHIFT:begin //��λ������
                wdata_o <= shiftres;
            end
            `EXE_RES_MOVE:begin //�ƶ�������
                wdata_o <= moveres;
            end
            `EXE_RES_ARITHMETIC:begin
                wdata_o <= arithmeticres;
            end
            `EXE_RES_MUL:begin
                wdata_o <= mulres[31:0];
            end
//            `EXE_RES_JUMP_BRANCH:begin
//                wdata_o <= link_address_i;
//            end
            default: begin
                wdata_o <= `ZeroWord;
            end
        endcase
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            cp0_reg_write_addr_o <= 5'b00000;
            cp0_reg_we_o <= `WriteDisable;
            cp0_reg_data_o <= `ZeroWord;
        end
        else if(aluop_i == `EXE_MTC0_OP) begin
            cp0_reg_write_addr_o <= inst_i[15:11];
            cp0_reg_we_o <= `WriteEnable;
            cp0_reg_data_o <= reg1_i;
        end
        else begin
            cp0_reg_write_addr_o <= 5'b00000;
            cp0_reg_we_o <= `WriteDisable;
            cp0_reg_data_o <= `ZeroWord;
        end
    end



    // MTHI MTLO
    always @ (*) begin
        if(rst == `RstEnable) begin
            whilo_o <= `WriteDisable;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
        end
        else if((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MULTU_OP)) begin
            whilo_o <= `WriteEnable;
            hi_o <= mulres[63:32];
            lo_o <= mulres[31:0];
        end
        else if((aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MADDU_OP)) begin //����Ҫд��hi lo�Ĵ��� ������ͨ�üĴ�������
            whilo_o <= `WriteEnable;
            hi_o <= hilo_temp1[63:32];
            lo_o <= hilo_temp1[31:0];
        end
        else if((aluop_i == `EXE_MSUB_OP) || (aluop_i == `EXE_MSUBU_OP)) begin
            whilo_o <= `WriteEnable;
            hi_o <= hilo_temp1[63:32];
            lo_o <= hilo_temp1[31:0];
        end
        else if(aluop_i == `EXE_MTHI_OP) begin
            whilo_o <= `WriteEnable;
            hi_o <= reg1_i;
            lo_o <= LO;
        end
        else if(aluop_i == `EXE_MTLO_OP) begin
            whilo_o <= `WriteEnable;
            hi_o <= HI;
            lo_o <= reg1_i;
        end
        else if((aluop_i == `EXE_DIV_OP) || (aluop_i == `EXE_DIVU_OP)) begin
            whilo_o <= `WriteEnable;
            hi_o <= div_result_i[31:0]; //����
            lo_o <= div_result_i[63:32]; //��
        end
        else begin
            whilo_o <= `WriteDisable;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
        end
    end
endmodule
