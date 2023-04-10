`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/14 15:22:35
// Design Name: 
// Module Name: id_ex
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
// 将译码阶段取得的结果在下一个时钟周期传入到执行阶段
module id_ex(
    input	wire clk,
    input wire rst,


    //从译码阶段传递的信息
    input wire[`AluOpBus] id_aluop, //译码得出的运算子类型
    input wire[`AluSelBus] id_alusel, //译码得出的运算类型
    input wire[`RegBus] id_reg1, //源操作数1
    input wire[`RegBus] id_reg2, //源操作数2
    input wire[`RegAddrBus] id_wd, //目的寄存器地址
    input wire id_wreg, //是否有要写入的目的寄存器
    input wire[5:0] stall, //暂停信号

    input wire[`RegBus] id_link_address, //译码阶段的指令要保存的返回地址
    input wire id_is_delay, //当前处于译码阶段的指令是否延迟
    input wire next_inst_delay_i, //下一条进入译码阶段的指令是否延迟

    input wire[`RegBus] id_inst, //来自id模块的信号 访存用

    // 异常处理
    input wire flush, //流水线清除信号
    input wire[`RegBus] id_current_inst_address, //译码阶段指令的地址
    input wire[31:0] id_excepttype, //译码阶段收集到的异常信息


    //传递到执行阶段的信息
    output reg[`AluOpBus] ex_aluop, //运算子类型
    output reg[`AluSelBus] ex_alusel, //运算类型
    output reg[`RegBus] ex_reg1, //源操作数1
    output reg[`RegBus] ex_reg2, //源操作数2
    output reg[`RegAddrBus] ex_wd, //目的寄存器地址
    output reg ex_wreg, //是否写入目的寄存器

    output reg[`RegBus] ex_link_address, //执行阶段的指令要保存的返回地址
    output reg ex_is_delay, //当前要执行的指令是否延迟 后传
    output reg is_delay_o, //当前处于译码阶段的指令是否延迟 前传
    output reg[`RegBus] ex_inst, //传递到ex 访存用

    //exception
    output reg[31:0] ex_excepttype,
    output reg[`RegBus] ex_current_inst_address

);
    always @ (posedge clk) begin
        if (rst == `RstEnable) begin
            ex_aluop <= `EXE_NOP_OP;
            ex_alusel <= `EXE_RES_NOP;
            ex_reg1 <= `ZeroWord;
            ex_reg2 <= `ZeroWord;
            ex_wd <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
            ex_link_address <= `ZeroWord;
            ex_is_delay <= `NotInDelaySlot;
            is_delay_o <= `NotInDelaySlot;
            ex_inst<=`ZeroWord;
            ex_excepttype <= `ZeroWord;
            ex_current_inst_address <= `ZeroWord;
        end
        //流水线清除
        else if(flush == 1'b1 ) begin
            ex_aluop <= `EXE_NOP_OP;
            ex_alusel <= `EXE_RES_NOP;
            ex_reg1 <= `ZeroWord;
            ex_reg2 <= `ZeroWord;
            ex_wd <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
            ex_excepttype <= `ZeroWord;
            ex_link_address <= `ZeroWord;
            ex_inst <= `ZeroWord;
            ex_is_delay <= `NotInDelaySlot;
            ex_current_inst_address <= `ZeroWord;
            is_delay_o <= `NotInDelaySlot;
        end
        // 如果译码阶段暂停但是执行阶段不暂停 插入空指令
        else if(stall[2] == `Stop && stall[3] == `NoStop) begin
            ex_aluop <= `EXE_NOP_OP;
            ex_alusel <= `EXE_RES_NOP;
            ex_reg1 <= `ZeroWord;
            ex_reg2 <= `ZeroWord;
            ex_wd <= `NOPRegAddr;
            ex_wreg <= `WriteDisable;
            ex_link_address <= `ZeroWord;
            ex_is_delay <= `NotInDelaySlot;
            ex_inst<=`ZeroWord;
            ex_excepttype <= `ZeroWord;
            ex_current_inst_address <= `ZeroWord;
        end
        else if(stall[2] == `NoStop) begin
            ex_aluop <= id_aluop;
            ex_alusel <= id_alusel;
            ex_reg1 <= id_reg1;
            ex_reg2 <= id_reg2;
            ex_wd <= id_wd;
            ex_wreg <= id_wreg;
            ex_link_address <= id_link_address;
            ex_is_delay <= id_is_delay;
            is_delay_o <= next_inst_delay_i;
            ex_inst<=id_inst;
            ex_excepttype <= id_excepttype;
            ex_current_inst_address <= id_current_inst_address;
        end
        // 如果执行阶段由于算术运算持续多个周期则流水线暂停 输出值不变 
    end
endmodule
