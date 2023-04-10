`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/09/14 17:32:36
// Design Name: 
// Module Name: core_min_sosp_tb
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

module core_min_sosp_tb();
    reg CLOCK_50;
    reg rst;
      
  initial begin
    CLOCK_50 = 1'b0;
    forever #5 CLOCK_50 = ~CLOCK_50;
  end
      
  initial begin
    rst = `RstEnable;
    #195 rst= `RstDisable;
  end
       
  core_min_sosp core_min_sosp0(
		.clk(CLOCK_50),
		.rst_n(rst)
	);

endmodule
