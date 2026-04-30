module tensor_core_controller (
	clock_in,
	reset_in,
	current_instruction,
	tensor_core_controller_output
);
	input wire clock_in;
	input wire reset_in;
	input wire [9:0] current_instruction;
	output reg signed [11:0] tensor_core_controller_output;
	wire signed [89:0] tensor_core_register_file_bulk_store_data;
	wire signed [107:0] tensor_core_output;
	wire signed [44:0] tensor_core_input1;
	wire signed [44:0] tensor_core_input2;
	wire [2:0] opcode = current_instruction[2:0];
	wire signed [9:0] burst_current_dual_load_data;
	assign burst_current_dual_load_data[5+:5] = current_instruction[9:5];
	assign burst_current_dual_load_data[0+:5] = current_instruction[4:0];
	reg is_burst_state_machine_active;
	wire is_burst_load_store_active = is_burst_state_machine_active || (opcode == 3'b010);
	reg [3:0] burst_current_index;
	wire signed [11:0] burst_current_store_data = (burst_current_index < 4'd9 ? tensor_core_output[(8 - burst_current_index) * 12+:12] : 12'b000000000000);
	always @(posedge clock_in) tensor_core_controller_output <= (is_burst_load_store_active ? burst_current_store_data : 12'b000000000000);
	always @(posedge clock_in)
		if (reset_in == 1'b1) begin
			burst_current_index <= 4'd0;
			is_burst_state_machine_active <= 1'b0;
		end
		else if ((opcode == 3'b010) && (burst_current_index == 4'd0)) begin
			burst_current_index <= 4'd1;
			is_burst_state_machine_active <= 1'b1;
		end
		else if ((burst_current_index < 4'd9) && (burst_current_index != 4'd0))
			burst_current_index <= burst_current_index + 1'b1;
		else if (burst_current_index == 4'd9) begin
			burst_current_index <= 4'd0;
			is_burst_state_machine_active <= 1'b0;
		end
		else
			burst_current_index <= burst_current_index;
	tensor_core_register_file main_tensor_core_register_file(
		.clock_in(clock_in),
		.reset_in(reset_in),
		.dual_load_enable_in(is_burst_state_machine_active),
		.dual_load_register_address_in(burst_current_index - 4'd1),
		.dual_load_data_in(burst_current_dual_load_data),
		.bulk_store_data_out(tensor_core_register_file_bulk_store_data)
	);
	tensor_core main_tensor_core(
		.clock_in(clock_in),
		.reset_in(reset_in),
		.should_start_tensor_core((opcode == 3'b001) && !is_burst_load_store_active),
		.tensor_core_input1(tensor_core_input1),
		.tensor_core_input2(tensor_core_input2),
		.tensor_core_output(tensor_core_output)
	);
	genvar _gv_map_idx_1;
	generate
		for (_gv_map_idx_1 = 0; _gv_map_idx_1 < 9; _gv_map_idx_1 = _gv_map_idx_1 + 1) begin : route_bulk_store_to_inputs
			localparam map_idx = _gv_map_idx_1;
			assign tensor_core_input1[(8 - map_idx) * 5+:5] = tensor_core_register_file_bulk_store_data[(17 - map_idx) * 5+:5];
			assign tensor_core_input2[(8 - map_idx) * 5+:5] = tensor_core_register_file_bulk_store_data[(17 - (map_idx + 9)) * 5+:5];
		end
	endgenerate
endmodule
