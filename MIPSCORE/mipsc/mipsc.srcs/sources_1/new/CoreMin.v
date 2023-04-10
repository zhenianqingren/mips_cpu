`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/14 17:25:38
// Design Name: 
// Module Name: core_min_sosp
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
module CoreMin(
    input wire clk,
//    input wire rst_n
    
    input wire rst_n


    
//    input sw0,
//    output [15:0]led,
//    output[3:0] an,
//    output[7:0] seg_code 学校开发板对应外设，如若测试请将约束文件改为fpga.xdc 可在工程文件夹下找到 注意改型号

//    input [7:0]sw,
//    output [7:0]led,  虚拟平台对应外设，如若测试请将约束文件改为FPGAOL.xdc 目前约束文件就是 注意改型号
//    output [3:0]d,
//    output [2:0]an
);
    //连接指令存储器
    wire[`InstAddrBus] inst_addr;
    wire[`InstBus] inst;
    wire rom_ce;

    // 连接访存
    wire mem_we_i;
    wire[`RegBus] mem_addr_i;
    wire[`RegBus] mem_data_i;
    wire[`RegBus] mem_data_o;
    wire[3:0] mem_sel_i;
    wire mem_ce_i;

    wire[5:0] int;
    wire timer_int;
    reg ov=0;
    assign int = {4'b0000,ov,1'b0};

//        reg [21:0] cnt_r;
//        wire clk_r;
//        assign clk_r=(cnt_r==1);  不跑仿真波形时请取消注释 

//        reg[7:0] _seg_code;                        
//        assign an = rst_n==0?4'b0010:4'b0001;      
//        assign seg_code = rst_n==0?8'hff:_seg_code; 在fpga开发板运行时请取消注释
        
//        reg[3:0]_d;
//        assign an = rst_n==1?3'b001:3'b010;
//        assign d = rst_n==1?4'hf:_d;
//        wire clk_w;
//        reg [24:0] cnt_w;
//        reg [26:0] start;       不跑仿真波形时请取消注释 
//        reg rst_w;
//        assign clk_w=(cnt_w==1);
        
//        assign led = (sw[0]==1)?8'b11111111:8'b00000000;  虚拟平台led  

//        assign led = (sw0==1)?16'b1111111111111111:16'b0000000000000000;  开发板led


        //     自动时钟
//        always@(posedge clk)begin
//            if(rst_n==1)begin
//                rst_w<=1;
//                cnt_w<=0;
//                start<=0;            不跑仿真波形时取消注释
//            end
//            else begin
//                cnt_w<=cnt_w+1;
//                start<=start+1;
//                if(start==27'b111111111111111111111111111) rst_w<=0;
//            end
//        end


//        always@(posedge clk)begin
//            if(rst_n==1)cnt_r<=0;
//            else begin
//                if(cnt_r>=9_9999) cnt_r<=0;          不跑仿真波形时取消注释 
//                else cnt_r<=cnt_r+1;
//            end
//        end

    always@(mem_data_i)begin
        if(mem_data_i<10) ov<=0;
        else ov<=1;
    end

//        parameter _0 = 8'hc0,_1 = 8'hf9,_2 = 8'ha4,_3 = 8'hb0,
//        _4 = 8'h99,_5 = 8'h92,_6 = 8'h82,_7 = 8'hf8,
//        _8 = 8'h80,_9 = 8'h90;

//        always@(posedge clk_r)begin
//            if(mem_data_i[3:0]!=0)begin          在fpga开发板测试请取消注释
//                case(mem_data_i[3:0])
//                    4'd0:_seg_code <= ~_0;
//                    4'd1:_seg_code <= ~_1;
//                    4'd2:_seg_code <= ~_2;
//                    4'd3:_seg_code <= ~_3;
//                    4'd4:_seg_code <= ~_4;
//                    4'd5:_seg_code <= ~_5;
//                    4'd6:_seg_code <= ~_6;
//                    4'd7:_seg_code <= ~_7;
//                    4'd8:_seg_code <= ~_8;
//                    4'd9:_seg_code <= ~_9;
//                    default:
//                    _seg_code <= 8'hff;
//                endcase
//            end
//        end

//        always@(posedge clk_r)begin
//            if(mem_data_i[3:0]!=0)  _d<=mem_data_i[3:0];       在fpga平台测试请取消注释
//        end



    Core Core_(
//                .clk(clk_w), 非仿真波形时钟
//                .rst(rst_w),  非仿真波形复位键

        .clk(clk),
        .rst(rst_n),

        .rom_addr_o(inst_addr),
        .rom_data_i(inst),
        .rom_ce_o(rom_ce),

        .ram_we_o(mem_we_i),
        .ram_addr_o(mem_addr_i),
        .ram_sel_o(mem_sel_i),
        .ram_data_o(mem_data_i),
        .ram_data_i(mem_data_o),
        .ram_ce_o(mem_ce_i),

        .int_i(int),
        .timer_int_o(timer_int)
    );

    InsRom InsRom_(
        .addr(inst_addr),
        .inst(inst),
        .ce(rom_ce)
    );

    DatRam DatRam_(
//                .clk(clk_w),  非仿真波形时钟
        .clk(clk),//仿真波形时钟
        .we(mem_we_i),
        .addr(mem_addr_i),
        .sel(mem_sel_i),
        .data_i(mem_data_i),
        .data_o(mem_data_o),
        .ce(mem_ce_i)
    );
endmodule
