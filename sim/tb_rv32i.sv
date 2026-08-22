`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/05/19 15:40:51
// Design Name: 
// Module Name: tb_rv32i
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


module tb_rv32i();
	top_rv32i_soc dut(
		.clk(clk),
		.rst(rst)
	);
	logic clk, rst;

	always #5 clk = ~clk;

	initial begin
		clk = 0;
		rst = 1;
		@(negedge clk);
		@(negedge clk);
		rst = 0;
		repeat(1000) @(negedge clk);
		$stop;
	end
endmodule
