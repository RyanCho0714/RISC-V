`timescale 1ns / 1ps
`include "define.vh"

module rv32i_datapath(
	input clk,
	input rst,
	input logic [31:0] instr_code,
	input logic rf_we,
	input logic branch,
	input logic jal,
	input logic jalr,
	input logic alusrc_sel,
	input logic [2:0] rfsrc_sel,
	input logic [31:0] drdata,
	input logic [3:0] alu_control,
	output logic [31:0] instr_addr,
	output logic [31:0] daddr,
	output logic [31:0] dwdata
    );

	logic [31:0] rs2, rs1, alu_result, wb_mux_out, imm_extend;
	logic [31:0] alu_rs2_mux;
	logic b_taken;
	logic [31:0] pc_4;
	logic [31:0] pc_imm;

	assign daddr = alu_result;
	assign dwdata = rs2;

//	mux_2X1 U_REG_FILE_SRC_MUX( //should be changed to 5X1
//		.in0(alu_result),
//		.in1(drdata),
//		.sel(rfsrc_sel),
//		.out_mux(rfsrc_mux_out)
//		);

	mux_5X1 U_WB_5X1(
		.in0(alu_result),
		.in1(drdata),
		.in2(imm_extend),
		.in3(pc_imm),
		.in4(pc_4),
		.sel(rfsrc_sel),
		.wb_out(wb_mux_out)
		);

	register_file U_REG_FILE(
		.clk(clk),
		.raddr1(instr_code[19:15]),
		.raddr2(instr_code[24:20]),
		.rf_we(rf_we),
		.waddr(instr_code[11:7]),
		.wdata(wb_mux_out),
		.rdata1(rs1),
		.rdata2(rs2)
		);

	alu U_ALU(
		.rs1(rs1),
		.rs2(alu_rs2_mux),
		.alu_control(alu_control),
		.alu_result(alu_result),
		.b_taken(b_taken)
		);

	imm_extend U_IMM_EXT(
		.instr_code(instr_code), 
 		.imm_extend(imm_extend)
		);

	mux_2X1 U_ALU_RS2_MUX(
		.in0(rs2),
		.in1(imm_extend),
		.sel(alusrc_sel),
		.out_mux(alu_rs2_mux)
		);

	program_counter U_PC(
		.clk(clk),
		.rst(rst),
		.b_taken(b_taken),
		.branch(branch),
		.jal(jal),
		.jalr(jalr),
		.rs1(rs1),
		.pc_in(instr_addr),
		.imm_extend(imm_extend),
		.pc_out(instr_addr),
		.pc_imm(pc_imm),	
		.pc_4(pc_4)	
		);	

endmodule
	
module program_counter(
	input clk,
	input rst,
	input b_taken,
	input branch,
	input jal,
	input jalr,
	input logic [31:0] rs1,
	input logic [31:0] pc_in,
	input logic [31:0] imm_extend,
	output logic [31:0] pc_out,	
	output logic [31:0] pc_imm,	
	output logic [31:0] pc_4	
	);

	logic [31:0] pc_reg, pc_next; 
	logic [31:0] pc_jalr, pc_target;
	assign pc_out = pc_reg;
	
	//assign pc_imm = jalr ? {pc_target[31:1], 1'b0} : pc_target;

	always_ff @(posedge clk, posedge rst) begin
		if(rst) begin
			pc_reg <= 0;
		end else begin
			pc_reg <= pc_next;
		end
	end

	mux_2X1 U_PC_JALR_MUX(
		.in0(pc_in),
		.in1(rs1),
		.sel(jalr), // you need to set sel_signal.
		.out_mux(pc_jalr)
		);

	adder U_ADDER1(
		.in0(imm_extend),
		.in1(pc_jalr),
		.out(pc_imm) //pc_imm
	);
	
	adder U_ADDER2(
		.in0(32'd4),
		.in1(pc_in),
		.out(pc_4)
	);

	mux_2X1 U_PC_SRC_MUX(
		.in0(pc_4),
		.in1(pc_imm),
		.sel(jalr|jal|(branch&b_taken)),
		.out_mux(pc_next)
		);

endmodule

module adder(
	input [31:0] in0,
	input [31:0] in1,
	output [31:0] out
	);

	assign out = in0 + in1;

endmodule

module imm_extend(
	input logic [31:0] instr_code, 
	output logic [31:0] imm_extend
	);

	always_comb begin
		case(instr_code[6:0])
			default : imm_extend = 32'd0;
			`S_TYPE : imm_extend = {{20{instr_code[31]}}, instr_code[31:25], instr_code[11:7]};	
			`I_TYPE, `IL_TYPE, `JL_TYPE : imm_extend = {{20{instr_code[31]}}, instr_code[31:20]};
			`B_TYPE : imm_extend = {{20{instr_code[31]}}, instr_code[7], instr_code[30:25], instr_code[11:8], 1'b0};
			`LUI, `AUIPC : imm_extend = {instr_code[31:12], 12'h0000};
			`J_TYPE : imm_extend = {{12{instr_code[31]}}, instr_code[19:12], instr_code[20], instr_code[30:21], 1'b0};
		endcase
	end
endmodule

module mux_5X1(
	input logic [31:0] in0, // load alu
	input logic [31:0] in1, // load data memory
	input logic [31:0] in2, // load Upper Imm
	input logic [31:0] in3, // Add Upper Imm to PC
	input logic [31:0] in4, // load JAL, JALR : PC+4
	input logic [2:0] sel,
	output logic [31:0] wb_out
	);
	
	always_comb begin
		case(sel)
			3'b000 :	wb_out = in0;
			3'b001 : 	wb_out = in1;
			3'b010 : 	wb_out = in2;
			3'b011 : 	wb_out = in3;
			3'b100 : 	wb_out = in4;
			default : wb_out = 32'd0;
		endcase
	end
endmodule

module mux_2X1(
	input logic [31:0] in0,
	input logic [31:0] in1,
	input logic sel,
	output logic [31:0] out_mux
	);
	
	assign out_mux = (sel) ? in1 : in0;

endmodule
	
module alu(
	input logic [31:0] rs1,
	input logic [31:0] rs2,
	input logic [3:0] alu_control,
	output logic [31:0] alu_result,
	output logic b_taken
	);

	always_comb begin
		alu_result = 0;
		case(alu_control)
			`ADD : alu_result = rs1 + rs2;
			`SUB : alu_result = rs1 - rs2;
			`SLL : alu_result = rs1 << rs2;
			//logical left: shift lest and fill 0 from right side
			`SLT : alu_result = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
			//`SLT : alu_result = ((signed) a < (signed) b) ? 1 : 0;
			`SLTU : alu_result = (rs1 < rs2) ? 1 : 0;
			`XOR : alu_result = rs1 ^ rs2;
			`SRL : alu_result = rs1 >> rs2[4:0];
			//logical right: shift right and fill 0 from the left side
			`SRA : alu_result = $signed(rs1) >>> rs2[4:0];
			//arithmetic right: shift right and fill MSB from the left
			`AND : alu_result = rs1 & rs2;
			`OR : alu_result = rs1 | rs2;
		endcase
	end

	always_comb begin
		b_taken = 1'b0;
		case(alu_control[2:0])
			`BEQ: begin
				if (rs1 == rs2) b_taken = 1'b1;
				else b_taken = 1'b0;
			end
			`BNE: begin
				if (rs1 != rs2) b_taken = 1'b1;
				else b_taken = 1'b0;
			end
			`BLT: begin
				if($signed(rs1) < $signed(rs2)) b_taken = 1'b1;
				else b_taken = 1'b0;
			end
			`BGE: begin
				if($signed(rs1) >= $signed(rs2)) b_taken = 1'b1;
				else b_taken = 1'b0;
			end
			`BLTU: begin
				if(rs1 < rs2) b_taken = 1'b1;
				else b_taken = 1'b0;
			end
			`BGEU: begin
				if(rs1 >= rs2) b_taken = 1'b1;
				else b_taken = 1'b0;
			end
		endcase
	end
endmodule


module register_file(
	input logic clk,
	input logic [4:0] raddr1,
	input logic [4:0] raddr2,
	input logic rf_we,
	input logic [4:0] waddr,
	input logic [31:0] wdata,
	output logic [31:0] rdata1,
	output logic [31:0] rdata2
	);

	logic [31:0] register_file[1:31];

`ifdef TEST_SIMULATION
	int i = 0;
	initial begin
		for(i=1; i<32; i++)
			register_file[i] = 2*i-1;
	end
`endif


	always_ff @(posedge clk) begin
		if(rf_we) begin
			register_file[waddr] <= wdata;
		end
	end


	assign rdata1 = (raddr1) ? register_file[raddr1] : 32'h0000_0000;
	assign rdata2 = (raddr2) ? register_file[raddr2] : 32'h0000_0000;

endmodule














