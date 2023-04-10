`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/22 15:27:33
// Design Name: 
// Module Name: data_ram
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

module DatRam(
    input wire clk, //ʱ���ź�
    input wire ce, //���ݴ洢��ʹ��
    input wire we, //���ݴ洢��дʹ��
    input wire[`DataAddrBus] addr, //�ô��ַ
    input wire[3:0] sel, //�ֽ�ѡ��
    input wire[`DataBus] data_i, //Ҫд�������
    output reg[`DataBus] data_o //Ҫ����������
);
    // 128KB ram ÿ��ram�Ĵ洢��Ϊ4byte 32bit
    reg[`ByteWidth]  data_mem[0:63];


// �˴������ľ��Ե�ַ �����˹��̺�Ҫ����ʵ��λ���޸�
    initial $readmemb ( "C:/MyApp/MIPSCPU/MIPSCORE/mipsc/data_ram.data", data_mem);

    always @ (posedge clk) begin
        if(we == `WriteEnable) begin //��˸�ʽ data_mem3���ֽ�
            if (sel[3] == 1'b1) begin
                data_mem[addr[31:2]][31:24] <= data_i[31:24];
            end
            if (sel[2] == 1'b1) begin
                data_mem[addr[31:2]][23:16] <= data_i[23:16];
            end
            if (sel[1] == 1'b1) begin
                data_mem[addr[31:2]][15:8] <= data_i[15:8];
            end
            if (sel[0] == 1'b1) begin
                data_mem[addr[31:2]][7:0] <= data_i[7:0];
            end
        end
    end

    always @ (*) begin
        if (ce == `ChipDisable) begin
            data_o <= `ZeroWord;
        end 
        else if(we == `WriteDisable) begin
            data_o <= data_mem[addr[31:2]];
        end 
        else begin
            data_o <= `ZeroWord;
        end
    end
endmodule
