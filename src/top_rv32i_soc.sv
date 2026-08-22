`timescale 1ns / 1ps

module top_rv32i_soc(
	input clk,
	input rst,
	output logic sort_done
    );

	logic [31:0] instr_code, instr_addr, daddr, dwdata, drdata;
	logic [2:0] mem_mode;
	logic dwe;


//	always @(posedge clk, posedge rst) begin
//		if(rst) begin
//			sort_done <= 1'b0;
//		end else if(instr_addr == 32'h74) begin
//			sort_done <= 1'b1;
//		end
//	end

	always @(posedge clk, posedge rst) begin
		if(rst) begin
			sort_done <= 1'b0;
		end else begin
			sort_done <= instr_addr[0];
		end
	end

	rv32i_cpu U_CPU(
		.*
	);


	instruction_mem U_INSTR_ROM(
		.*
	);
	
	data_mem U_DATA_MEM(
		.*
	);

endmodule
