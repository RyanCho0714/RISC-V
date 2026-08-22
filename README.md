# RV32I Single-Cycle CPU

RISC-V RV32I 명령어 집합을 구현한 싱글 사이클 CPU/SoC. SystemVerilog로 작성했고 Xilinx Vivado에서 시뮬레이션 및 합성을 검증했습니다.

## 구성

```
src/    RTL 소스
sim/    테스트벤치
docs/   발표자료, 완료보고서, 트러블슈팅
```

### src/

| 파일 | 설명 |
|---|---|
| `top_rv32i_soc.sv` | CPU + instruction memory + data memory 통합 top 모듈 |
| `rv32i_cpu.sv` | datapath와 control_unit을 묶는 CPU 모듈 |
| `rv32i_datapath.sv` | PC, register file, ALU, immediate extension, mux 등 데이터패스 (adder, mux_2X1/5X1, alu, register_file, program_counter, imm_extend 서브모듈 포함) |
| `control_unit.sv` | opcode/funct3/funct7 기반 제어신호 생성 |
| `instruction_mem.sv` | 128-word instruction ROM (`$readmemh`로 `instruction_code.mem` 로드) |
| `data_mem.sv` | 64-word data memory, byte/half/word 단위 read-modify-write 지원 |
| `define.vh` | opcode, alu_control, mem_mode 등 매크로 정의 |

### 지원 명령어 (RV32I)

- **R-type**: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
- **I-type**: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
- **Load**: LB, LH, LW, LBU, LHU
- **Store**: SB, SH, SW
- **Branch**: BEQ, BNE, BLT, BGE, BLTU, BGEU
- **U-type**: LUI, AUIPC
- **Jump**: JAL, JALR

## 시뮬레이션

`sim/tb_rv32i.sv`가 `top_rv32i_soc`을 인스턴스화합니다. clk 10ns 주기로 2클럭 동안 리셋 후 1000클럭 동안 실행합니다.

```
clk = 0, rst = 1
2 negedge 대기
rst = 0
1000 negedge 동안 실행 후 $stop
```

`TEST_SIMULATION` 매크로를 정의하면 `instruction_mem`/`register_file`에 내장된 테스트용 초기값이 함께 로드됩니다.

## 문서

- [발표자료](docs/발표자료.pdf)
- [완료보고서](docs/완료보고서.pdf)
- [트러블슈팅](TROUBLESHOOTING.md) — Vivado 합성 시 multi-dimensional packed array 관련 이슈 해결 과정

## 참고자료 (레포 미포함)

용량·저작권 문제로 원본 PDF는 레포에 포함하지 않았습니다. 필요 시 아래 공식 출처에서 확인할 수 있습니다.

- RISC-V Unprivileged ISA Spec: https://github.com/riscv/riscv-isa-manual
- RISC-V Instruction Set Reference Card: https://riscv.org/technical/specifications/
- AMD/Xilinx UG901 (Vivado Design Suite User Guide: Synthesis): https://docs.amd.com/r/en-US/ug901-vivado-synthesis
