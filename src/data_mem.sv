`timescale 1ns / 1ps
`include "define.vh"

module data_mem(
	input	logic clk,
	input	logic dwe,
	input	logic [2:0] mem_mode,
	input	logic [31:0] daddr,
	input	logic [31:0] dwdata,
	output	logic [31:0] drdata
    );
//data_ram[7][2][0]
	logic [31:0] data_ram[0:63]; //
	logic [1:0] offset;
	logic [5:0] ram_id;
	
	assign offset = daddr[1:0];
	assign ram_id = daddr[7:2];

	always_ff @(posedge clk) begin
		if(dwe) begin
			case(mem_mode)
				`SW: begin
					data_ram[ram_id] <= dwdata;
				end
				`SH: begin
					case(offset[1])
						1'd0: data_ram[ram_id][1:0] <= dwdata[15:0];
						1'd1: data_ram[ram_id][3:2] <= dwdata[15:0];
					endcase
				end
				`SB: begin
					case(offset)
						2'd0: data_ram[ram_id][0] <= dwdata[7:0];
						2'd1: data_ram[ram_id][1] <= dwdata[7:0];
						2'd2: data_ram[ram_id][2] <= dwdata[7:0];
						2'd3: data_ram[ram_id][3] <= dwdata[7:0];
					endcase
				end
			endcase 
		end	
	end

	map_4_load U_MAP_4_LOAD(
		.selected_mem(data_ram[ram_id]),
		.offset(offset),
		.mem_mode(mem_mode),
		.drdata(drdata)
		);

endmodule



module map_4_load(
	input logic [3:0][7:0] selected_mem,
	input logic [1:0] offset,
	input	logic [2:0] mem_mode,
	output	logic [31:0] drdata
	);

	always_comb begin
		drdata = 32'd0;
		case(mem_mode)
			`LB : begin
				case(offset)
					2'd0: drdata = {{24{selected_mem[0][7]}},selected_mem[0]};
					2'd1: drdata = {{24{selected_mem[1][7]}},selected_mem[1]};
					2'd2: drdata = {{24{selected_mem[2][7]}},selected_mem[2]};
					2'd3: drdata = {{24{selected_mem[3][7]}},selected_mem[3]};
				endcase	
			end
			`LBU: begin
				case(offset)
					2'd0: drdata = {24'd0,selected_mem[0]};
					2'd1: drdata = {24'd0,selected_mem[1]};
					2'd2: drdata = {24'd0,selected_mem[2]};
					2'd3: drdata = {24'd0,selected_mem[3]};
				endcase
			end
			`LH: begin
				case(offset[1])
					1'd0: drdata = {{16{selected_mem[1][7]}},selected_mem[1:0]};
					1'd1: drdata = {{16{selected_mem[3][7]}},selected_mem[3:2]};
				endcase
			end
			`LHU: begin
				case(offset[1])
					1'd0: drdata = {16'd0,selected_mem[1:0]};
					1'd1: drdata = {16'd0,selected_mem[3:2]};
				endcase
			end
			`LW: begin
				drdata = selected_mem;
			end
		endcase
	end
endmodule
	
