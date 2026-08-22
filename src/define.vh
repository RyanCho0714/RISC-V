// OP-CODE instruction code [6:0]
`define R_TYPE 7'b011_0011
`define S_TYPE 7'b010_0011
`define IL_TYPE 7'b000_0011
`define I_TYPE 7'b001_0011
`define B_TYPE 7'b110_0011
`define LUI 7'b011_0111
`define AUIPC 7'b001_0111
`define JL_TYPE 7'b110_0111
`define J_TYPE 7'b110_1111



// R-type Instruction
// {funct7, funct3} total 10bit

`define ADD 4'b0_000
`define SUB 4'b1_000
`define SLL 4'b0_001
`define SLT 4'b0_010
`define SLTU 4'b0_011
`define XOR 4'b0_100
`define SRL 4'b0_101
`define SRA 4'b1_101
`define OR 4'b0_110
`define AND 4'b0_111

// S-Type Instruction(mem_mode)
`define SB 3'b000
`define SH 3'b001
`define SW 3'b010

// I-Type Instruction -> same as R-Type
`define ADDI 4'b0_000
`define SLTI 4'b0_010
`define SLTIU 4'b0_011
`define XORI 4'b0_100
`define ORI 4'b0_110
`define ANDI 4'b0_111
`define SLLI 4'b0_001
`define SRLI 4'b0_101
`define SRAI 4'b1_101

// IL-Type -> mem mode
`define LB 3'b000
`define LH 3'b001
`define LW 3'b010
`define LBU 3'b100
`define LHU 3'b101

// B-Type Instruction
`define BEQ 3'b000
`define BNE 3'b001
`define BLT 3'b100
`define BGE 3'b101
`define BLTU 3'b110
`define BGEU 3'b111

// JALR mem_mode
`define JL 3'b000
