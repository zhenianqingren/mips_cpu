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
// 根据得到的信息进行指令的执行
module ex(
    input wire rst,
    //送到执行阶段的信息
    input wire[`AluOpBus] aluop_i, //运算子类型
    input wire[`AluSelBus] alusel_i, //运算类型
    input wire[`RegBus] reg1_i, //源操作数1
    input wire[`RegBus] reg2_i, //源操作数2
    input wire[`RegAddrBus] wd_i, //要写入的目的寄存器地址
    input wire wreg_i, //是否有要写入的目的寄存器

    //HI、LO寄存器的值
    input wire[`RegBus] hi_i,
    input wire[`RegBus] lo_i,

    //回写阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
    input wire[`RegBus] wb_hi_i, //hi值
    input wire[`RegBus] wb_lo_i, //lo值
    input wire wb_whilo_i, //是否写入lo hi

    //访存阶段的指令是否要写HI、LO，用于检测HI、LO的数据相关
    input wire[`RegBus] mem_hi_i, //hi值
    input wire[`RegBus] mem_lo_i, //lo值
    input wire mem_whilo_i, //是否写入lo hi

    input wire[`DoubleRegBus] hilo_temp_i, //第一个执行周期得到的乘法结果
    input wire[1:0] cnt_i, //当前处于执行阶段的第几个周期

    //与除法模块相连
    input wire[`DoubleRegBus] div_result_i, //除法运算结果
    input wire div_ready_i, //除法运算是否结束

    input wire[`RegBus] link_address_i, //处于执行阶段的指令要保存的返回地址
    input wire is_delay_i, //当前要执行的指令是否是延迟指令

    input wire[`RegBus]  inst_i, //执行阶段正在执行的指令 计算访存地址
    //访存阶段的指令是否要写CP0，用来检测数据相关
    input wire mem_cp0_reg_we,
    input wire[4:0] mem_cp0_reg_write_addr,
    input wire[`RegBus] mem_cp0_reg_data,

    //回写阶段的指令是否要写CP0，用来检测数据相关
    input wire wb_cp0_reg_we,
    input wire[4:0] wb_cp0_reg_write_addr,
    input wire[`RegBus] wb_cp0_reg_data,

    //与CP0相连，读取其中CP0寄存器的值
    input wire[`RegBus] cp0_reg_data_i,

    // exception
    input wire[31:0] excepttype_i, //译码阶段收集到的异常信息
    input wire[`RegBus] current_inst_address_i, //译码阶段执行指令的地址


    output reg[`RegBus] hi_o, //执行阶段的指令要写入hi寄存器的值
    output reg[`RegBus] lo_o, //执行阶段的指令要写入lo寄存器的值
    output reg whilo_o, //执行阶段的指令是否要写hi lo寄存器


    output reg[`RegAddrBus] wd_o, //执行阶段的指令最终要写入的目的寄存器地址
    output reg wreg_o, //回写寄存器信号
    output reg[`RegBus] wdata_o, //写入目的寄存器的值

    output reg[`DoubleRegBus] hilo_temp_o, //第一个执行周期得到的乘法结果
    output reg[1:0] cnt_o, //下一个执行周期处于执行阶段的第几个周期

    output reg[`RegBus] div_opdata1_o, //被除数
    output reg[`RegBus] div_opdata2_o, //除数
    output reg div_start_o, //是否开始除法运算
    output reg signed_div_o, //是否是有符号除法

    // 访存
    output wire[`AluOpBus] aluop_o, //运算子类型
    output wire[`RegBus] mem_addr_o, //存储器地址
    output wire[`RegBus] reg2_o, //存储指令要存储的数据 或者lwl lwr要加载的目的寄存器的原始值
    output reg stallreq,

    output reg[4:0] cp0_reg_read_addr_o, //执行时要读取的cp0中寄存器的值

    //向下一流水级传递，用于写CP0中的寄存器
    output reg cp0_reg_we_o, //cp0寄存器写使能
    output reg[4:0] cp0_reg_write_addr_o, //要向cp0哪个寄存器写入
    output reg[`RegBus] cp0_reg_data_o, //写入的值

    //exception
    output wire[31:0] excepttype_o, //译码阶段收集到的异常信息
    output wire is_in_delayslot_o, //执行阶段的指令是否是分支指令的下一条(延迟槽)
    output wire[`RegBus] current_inst_address_o //当前执行指令的地址

);

    assign aluop_o=aluop_i; //传递到访存阶段
    assign mem_addr_o=reg1_i+{{16{inst_i[15]}},inst_i[15:0]}; //访存地址
    assign reg2_o=reg2_i;

    // 保存逻辑运算的结果
    reg[`RegBus] logicout;
    // 保存移位运算结果
    reg[`RegBus] shiftres;
    reg[`RegBus] moveres; // 移动操作的结果
    reg[`RegBus] arithmeticres; //保存算术运算结果
    reg[`DoubleRegBus] mulres; //保存乘法结果 宽度64bit
    reg[`RegBus] HI; //hi寄存器的最新值
    reg[`RegBus] LO; //lo寄存器的最新值

    wire[`RegBus] reg2_i_mux; //保存输入的第二个操作数的补码
    wire[`RegBus] reg1_i_not; //保存输入的第一个操作数的反码
    wire[`RegBus] result_sum; //保存加法结果
    wire ov_sum; //保存溢出情况
    wire reg1_eq_reg2; //第一个操作数是否等于第二个操作数
    wire reg1_lt_reg2; //第一个操作数是否小于第二个操作数
    wire[`RegBus] opdata1_mult; //被乘数
    wire[`RegBus] opdata2_mult; //乘数
    wire[`DoubleRegBus] hilo_temp; //临时保存乘法结果

    reg[`DoubleRegBus] hilo_temp1;
    reg stallreq_for_madd_msub;

    reg stallreq_for_div; //是否由于除法运算而导致流水线暂停
//    reg trapassert; //是否有自陷异常
    reg ovassert; //是否有溢出异常
    assign excepttype_o = {excepttype_i[31:12],ovassert,/*trapassert*/1'b0,excepttype_i[9:8],8'h00};
    //外部中断+id(syscall eret)+自陷与溢出+译码阶段信息
    assign is_in_delayslot_o = is_delay_i;
    assign current_inst_address_o = current_inst_address_i;

    //计算变量值
    //减法或者有符号比较 自陷 reg2_i_mux等于第二个操作数的补码 反之等于第二个操作数
    assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP) || (aluop_i == `EXE_SUBU_OP) ||( aluop_i == `EXE_SLT_OP)/*|| (aluop_i == `EXE_TLT_OP) ||
    (aluop_i == `EXE_TLTI_OP) || (aluop_i == `EXE_TGE_OP) ||
    (aluop_i == `EXE_TGEI_OP)*/)
    ? (~reg2_i)+1 : reg2_i;
    // 减去一个数等于加上这个数的相反数 加法 减法 比较 溢出运算
    assign result_sum = reg1_i + reg2_i_mux;
    // 是否溢出 正数之和为负数001 负数之和为正数110
    assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) ||
    ((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));
    // 操作数1是否小于操作数2
    assign reg1_lt_reg2 = ((aluop_i == `EXE_SLT_OP)/*|| (aluop_i == `EXE_TLT_OP) ||
    (aluop_i == `EXE_TLTI_OP) || (aluop_i == `EXE_TGE_OP) ||
    (aluop_i == `EXE_TGEI_OP)*/) ?
    ((reg1_i[31] && !reg2_i[31]) ||
    (!reg1_i[31] && !reg2_i[31] && result_sum[31])||
    (reg1_i[31] && reg2_i[31] && result_sum[31]))
    :	(reg1_i < reg2_i);
    // 取得操作数1的反码 
    assign reg1_i_not = ~reg1_i;

    //依据结果判断是否发生自陷
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



    // 算术运算  加法&&减法
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

    // 算术运算 乘法 
    // 取得乘法运算被乘数 如果是有符号乘法并且被乘数是负数 那么取补码
    assign opdata1_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP)||
    (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) && (reg1_i[31] == 1'b1))?
    (~reg1_i + 1) : reg1_i;

    // 对于被乘数 亦有同样的道理
    assign opdata2_mult = (((aluop_i == `EXE_MUL_OP) || (aluop_i == `EXE_MULT_OP)||
    (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP)) && (reg2_i[31] == 1'b1)) ?
    (~reg2_i + 1) : reg2_i;

    // 乘法结果
    assign hilo_temp = opdata1_mult * opdata2_mult;
    // 修正最终结果 
    always @ (*) begin
        if(rst == `RstEnable) begin
            mulres <= {`ZeroWord,`ZeroWord};
        end
        else if ((aluop_i == `EXE_MULT_OP) || (aluop_i == `EXE_MUL_OP)||
        (aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MSUB_OP))begin //有符号相乘
            if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin //异号
                mulres <= ~hilo_temp + 1;
            end
            else begin //同号
                mulres <= hilo_temp;
            end
        end
        else begin // 无符号相乘
            mulres <= hilo_temp;
        end
    end

    // 累乘加 MADD MADDU MSUB MSUBU
    always @ (*) begin
        if(rst == `RstEnable) begin
            hilo_temp_o <= {`ZeroWord,`ZeroWord};
            cnt_o <= 2'b00;
            stallreq_for_madd_msub <= `NoStop;
        end
        else begin
            case (aluop_i)
                `EXE_MADD_OP,`EXE_MADDU_OP:begin
                    if(cnt_i == 2'b00) begin //乘累加第一个周期
                        hilo_temp_o <= mulres;
                        cnt_o <= 2'b01;
                        stallreq_for_madd_msub <= `Stop;
                        hilo_temp1 <= {`ZeroWord,`ZeroWord};
                    end
                    else if(cnt_i == 2'b01) begin //乘累加第二个周期
                        hilo_temp_o <= {`ZeroWord,`ZeroWord};
                        cnt_o <= 2'b00; //回到00
                        hilo_temp1 <= hilo_temp_i + {HI,LO};
                        stallreq_for_madd_msub <= `NoStop;
                    end
                end
                `EXE_MSUB_OP,`EXE_MSUBU_OP:begin
                    if(cnt_i == 2'b00) begin // 乘累减第一个周期
                        hilo_temp_o <=  ~mulres + 1;
                        cnt_o <= 2'b01;
                        stallreq_for_madd_msub <= `Stop;
                    end
                    else if(cnt_i == 2'b01)begin // 乘累减第二个周期
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




    // 获取lo hi值 解决数据冲突问题 执行时流水线中的译码与回写
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

    //MFHI、MFLO、MOVN、MOVZ MFC0指令
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


    // 进行逻辑运算
    always @ (*) begin
        if(rst == `RstEnable) begin
            logicout <= `ZeroWord;
        end
        else begin

            case (aluop_i)
                `EXE_OR_OP: begin //或运算
                    logicout <= reg1_i | reg2_i;
                end
                `EXE_AND_OP:begin //与运算
                    logicout <= reg1_i & reg2_i;
                end
                `EXE_NOR_OP:begin //或非运算
                    logicout <= ~(reg1_i |reg2_i);
                end
                `EXE_XOR_OP:begin // 异或运算
                    logicout <= reg1_i ^ reg2_i;
                end
                default: begin
                    logicout <= `ZeroWord;
                end
            endcase

        end //if
    end //always

    // 进行移位运算
    always @ (*) begin
        if(rst == `RstEnable) begin
            shiftres <= `ZeroWord;
        end
        else begin

            case (aluop_i)
                `EXE_SLL_OP:begin //逻辑左移
                    shiftres <= reg2_i << reg1_i[4:0] ;
                end
                `EXE_SRL_OP:begin //逻辑右移
                    shiftres <= reg2_i >> reg1_i[4:0];
                end
                `EXE_SRA_OP:begin //算术右移
                    shiftres <= ({32{reg2_i[31]}} << (6'd32-{1'b0, reg1_i[4:0]}))
                    | reg2_i >> reg1_i[4:0];
                end
                default:begin
                    shiftres <= `ZeroWord;
                end
            endcase

        end //if
    end //always


    // 进行除法运算
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
                `EXE_DIV_OP: begin // 有符号除法
                    if(div_ready_i == `DivResultNotReady) begin
                        div_opdata1_o <= reg1_i; //被除数
                        div_opdata2_o <= reg2_i; //除数
                        div_start_o <= `DivStart; //开始除法运算
                        signed_div_o <= 1'b1; //有符号运算
                        stallreq_for_div <= `Stop; //请求流水线暂停
                    end
                    else if(div_ready_i == `DivResultReady) begin //除法运算结束
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
                `EXE_DIVU_OP: begin //无符号除法
                    if(div_ready_i == `DivResultNotReady) begin //开始无符号除法运算
                        div_opdata1_o <= reg1_i;
                        div_opdata2_o <= reg2_i;
                        div_start_o <= `DivStart;
                        signed_div_o <= 1'b0;
                        stallreq_for_div <= `Stop;
                    end
                    else if(div_ready_i == `DivResultReady) begin //运算完成
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

// 此处*是关键 一旦没有stall的请求 那么它总是0
    always @ (*) begin
        stallreq = stallreq_for_madd_msub || stallreq_for_div;
    end //流水线暂停




    // 依据alusel_i 选择一个结果作为最终运算结果
    always @ (*) begin
        wd_o <= wd_i;
        if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) ||
        (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin
            wreg_o <= `WriteDisable;
            ovassert <= 1'b1; //发生
        end
        else begin
            wreg_o <= wreg_i;
            ovassert <= 1'b0; //未发生
        end
        case ( alusel_i )
            `EXE_RES_LOGIC:begin //逻辑运算结果
                wdata_o <= logicout;
            end
            `EXE_RES_SHIFT:begin //移位运算结果
                wdata_o <= shiftres;
            end
            `EXE_RES_MOVE:begin //移动运算结果
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
        else if((aluop_i == `EXE_MADD_OP) || (aluop_i == `EXE_MADDU_OP)) begin //最终要写入hi lo寄存器 而不是通用寄存器堆中
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
            hi_o <= div_result_i[31:0]; //余数
            lo_o <= div_result_i[63:32]; //商
        end
        else begin
            whilo_o <= `WriteDisable;
            hi_o <= `ZeroWord;
            lo_o <= `ZeroWord;
        end
    end
endmodule
