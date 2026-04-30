module tensor_core_register_file (
	clock_in,
	reset_in,
	dual_load_enable_in,
	dual_load_register_address_in,
	dual_load_data_in_flat,
	bulk_store_data_out_flat
);
	input wire clock_in;
	input wire reset_in;
	input wire dual_load_enable_in;
	input wire [3:0] dual_load_register_address_in;
	input wire signed [4:0] dual_load_data_in_flat;
	output wire signed [89:0] bulk_store_data_out_flat;
	reg signed [4:0] registers [0:17];
	integer i;
	assign bulk_store_data_out_flat[4:0] = registers[0];
	assign bulk_store_data_out_flat[9:5] = registers[1];
	assign bulk_store_data_out_flat[14:10] = registers[2];
	assign bulk_store_data_out_flat[19:15] = registers[3];
	assign bulk_store_data_out_flat[24:20] = registers[4];
	assign bulk_store_data_out_flat[29:25] = registers[5];
	assign bulk_store_data_out_flat[34:30] = registers[6];
	assign bulk_store_data_out_flat[39:35] = registers[7];
	assign bulk_store_data_out_flat[44:40] = registers[8];
	assign bulk_store_data_out_flat[49:45] = registers[9];
	assign bulk_store_data_out_flat[54:50] = registers[10];
	assign bulk_store_data_out_flat[59:55] = registers[11];
	assign bulk_store_data_out_flat[64:60] = registers[12];
	assign bulk_store_data_out_flat[69:65] = registers[13];
	assign bulk_store_data_out_flat[74:70] = registers[14];
	assign bulk_store_data_out_flat[79:75] = registers[15];
	assign bulk_store_data_out_flat[84:80] = registers[16];
	assign bulk_store_data_out_flat[89:85] = registers[17];
	wire [4:0] load_base = {dual_load_register_address_in, 1'b0};
	always @(posedge clock_in)
		if (reset_in) begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < 18; i = i + 1)
				registers[i] <= 5'b00000;
		end
		else if (dual_load_enable_in && (dual_load_register_address_in < 4'd9)) begin
			registers[load_base] <= dual_load_data_in_flat[4:0];
			registers[load_base + 1] <= dual_load_data_in_flat[9:5];
		end
endmodule
