module tensor_core_register_file (
	clock_in,
	reset_in,
	dual_load_enable_in,
	dual_load_register_address_in,
	dual_load_data_in,
	bulk_store_data_out
);
	reg _sv2v_0;
	input wire clock_in;
	input wire reset_in;
	input wire dual_load_enable_in;
	input wire [3:0] dual_load_register_address_in;
	input wire signed [9:0] dual_load_data_in;
	output reg signed [89:0] bulk_store_data_out;
	reg signed [4:0] registers [0:17];
	always @(*) begin
		if (_sv2v_0)
			;
		begin : sv2v_autoblock_1
			reg signed [31:0] n;
			for (n = 0; n < 18; n = n + 1)
				bulk_store_data_out[(17 - n) * 5+:5] = registers[n];
		end
	end
	always @(posedge clock_in)
		if (reset_in) begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < 18; i = i + 1)
				registers[i] <= 5'b00000;
		end
		else if (dual_load_enable_in) begin
			if (dual_load_register_address_in < 4'd9) begin : sv2v_autoblock_3
				reg signed [31:0] i;
				for (i = 0; i < 2; i = i + 1)
					registers[(dual_load_register_address_in << 1) + i] <= dual_load_data_in[(1 - i) * 5+:5];
			end
		end
	genvar _gv_generate_index_1;
	generate
		for (_gv_generate_index_1 = 0; _gv_generate_index_1 < 18; _gv_generate_index_1 = _gv_generate_index_1 + 1) begin : expose_regs
			localparam generate_index = _gv_generate_index_1;
			wire [4:0] reg_wire = registers[generate_index];
			wire [4:0] bulk_store_data_out_ = bulk_store_data_out[(17 - generate_index) * 5+:5];
		end
	endgenerate
	initial _sv2v_0 = 0;
endmodule

