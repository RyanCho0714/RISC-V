`timescale 1ns / 1ps

module instruction_mem(
	input logic [31:0] instr_addr,
	output logic [31:0] instr_code
    );
		
	logic [31:0] instr_rom[0:127];
	//SLT $ SRA has signed figure!
`ifdef TEST_SIMULATION	
	initial begin //for simulation
		instr_rom[0] = 32'h0031_02b3; // ADD x5= x2+ x3 -> x5 = 8
		instr_rom[1] = 32'h4050_83b3; // SUB x7= x1- x5 -> x7 = -7
		instr_rom[2] = 32'h0030_90b3; // SLL x1 << x3 -> x1 = 1*2^5(32)
		instr_rom[3] = 32'h0072_a133; // SLT x5 < x7 -> x2 = false(0)
		instr_rom[4] = 32'h0072_b1b3; // SLTU x5 < x7 -> x3 = true(1)
		instr_rom[5] = 32'h0030_dfb3; // x1 >> x3 -> x31 = 32 >> 1 => 16 (100000 => 010000)
		instr_rom[6] = 32'h4033_deb3; // x7 >> x3 -> x29 = -7 >> 1 => ? (1111...111001 => 1111...111100)
		instr_rom[7] = 32'h0031_2123; // sw x2, x3, 2 => rs1, rs2, imm : x3을x2의 저장된 값(0)의 2를 더한 곳 M[2]에 x3값(1)이 저장된다.
		instr_rom[8] = 32'h0021_2403; // lw x8, x2, 2 : rd, rs1, imm 
		instr_rom[9] = 32'h0043_8413; // addi x8, x7, 4 : rd, rs1, imm 
		instr_rom[10] = 32'hFE84_0CE3; // BEQ x8, x8, -8 : rd, rs1, imm 
		instr_rom[11] = 32'h0031_02b3; // ADD x5= x2+ x3 -> x5 = 8
		instr_rom[12] = 32'h0031_02b3; // ADD x5= x2+ x3 -> x5 = 8
		instr_rom[13] = 32'h0031_02b3; // ADD x5= x2+ x3 -> x5 = 8
		instr_rom[14] = 32'h0031_02b3; // ADD x5= x2+ x3 -> x5 = 8
		instr_rom[15] = 32'h0031_02b3; // ADD x5= x2+ x3 -> x5 = 8
			
	end	
`endif
	initial begin
		$readmemh("instruction_code.mem", instr_rom);
	end

	assign instr_code = instr_rom[instr_addr[31:2]]; //right shift 해줘 /4 처럼 만든것

endmodule
