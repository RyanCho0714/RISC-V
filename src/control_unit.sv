`timescale 1ns / 1ps
`include "define.vh"

module control_unit(
	input logic [31:0] instr_code,
	output logic rf_we,
	output logic branch,
	output logic alusrc_sel,
	output logic [3:0] alu_control,
	output logic [2:0] rfsrc_sel,
	output logic [2:0] mem_mode,
	output logic dwe,
	output logic jal,
	output logic jalr
    );

	logic [6:0] funct7;
	logic [2:0] funct3;
	logic [6:0] opcode;


	assign funct7 = instr_code[31:25];
	assign funct3 = instr_code[14:12];
	assign opcode = instr_code[6:0]; 
			
	//[DEBUG]
	typedef enum logic [6:0] {
		DBG_R_TYPE = `R_TYPE,
		DBG_S_TYPE = `S_TYPE,
		DBG_I_TYPE = `I_TYPE,
		DBG_IL_TYPE = `IL_TYPE,
		DBG_B_TYPE = `B_TYPE,
		DBG_LUI = `LUI,
		DBG_AUIPC = `AUIPC,
		DBG_JL_TYPE = `JL_TYPE,
		DBG_J_TYPE = `J_TYPE
	} opcode_dbg_e;

	opcode_dbg_e opcode_dbg;
	assign opcode_dbg = opcode_dbg_e'(opcode);
	
	always_comb begin
		rf_we = 0;
		alusrc_sel = 0;
		alu_control = 0;
		rfsrc_sel = 0;
		mem_mode = 3'b0;
		dwe = 0;
		branch= 1'b0;
		jal = 1'b0;
		jalr = 1'b0;
		case(opcode)
			`R_TYPE : begin
				rf_we = 1'b1;
				alusrc_sel = 0;
				alu_control = {funct7[5], funct3};
				rfsrc_sel = 3'b000;
				mem_mode = 3'b000;
				dwe = 0;
				branch= 1'b0;
				jal = 1'b0;
				jalr = 1'b0;
			end
			`S_TYPE : begin
				rf_we = 1'b0;
				alusrc_sel = 1'b1;
				alu_control = `ADD;
				rfsrc_sel = 3'b000;
				mem_mode = funct3;
				dwe = 1'b1;
				branch= 1'b0;
				jal = 1'b0;
				jalr = 1'b0;
			end
			`IL_TYPE : begin
				rf_we = 1'b1;
				alusrc_sel = 1'b1; //rs1+imm
				alu_control = `ADD;
				rfsrc_sel = 3'b001;
				mem_mode = funct3;
				dwe = 1'b0;
				branch= 1'b0;
				jal = 1'b0;
				jalr = 1'b0;
			end
			`I_TYPE : begin
				rf_we = 1'b1;
				alusrc_sel = 1'b1;
				if(funct3 == 3'b101)	alu_control = {funct7[5], funct3};
				else					alu_control = {1'b0, funct3};
				rfsrc_sel = 3'b000;
				mem_mode = funct3;
				dwe = 1'b0;
				branch= 1'b0;
				jal = 1'b0;
				jalr = 1'b0;
			end
			`B_TYPE : begin
				rf_we = 1'b0;
				alusrc_sel = 1'b0; 
				alu_control = {1'b0, funct3};
				rfsrc_sel = 3'b000;
				mem_mode = 0;
				dwe = 1'b0;
				branch= 1'b1;			
				jal = 1'b0;
				jalr = 1'b0;
			end
			`LUI, `AUIPC : begin
				rf_we = 1'b1;
				alusrc_sel = 1'b0; 
				alu_control = 4'd0; //don't care
				if(opcode == `LUI) begin
					rfsrc_sel = 3'b010; //rd = imm
				end else begin
					rfsrc_sel = 3'b011; //rd = imm
				end
				mem_mode = 0;
				dwe = 1'b0;
				branch= 1'b0;			
				jal = 1'b0;
				jalr = 1'b0;
			end
			`JL_TYPE, `J_TYPE : begin
				rf_we = 1'b1;
				alusrc_sel = 1'b0; 
				alu_control = 4'b0000;
				rfsrc_sel = 3'b100; //rd = imm
				mem_mode = 0;
				dwe = 1'b0;
				branch= 1'b0;			
				jal = 1'b1;
				if(opcode == `J_TYPE) begin
					jalr = 1'b0;
				end else begin
					jalr = 1'b1;
				end
			end
		endcase
	end
		
endmodule
