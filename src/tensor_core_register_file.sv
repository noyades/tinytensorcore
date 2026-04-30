module tensor_core_register_file (
    input logic clock_in,
    input logic reset_in,

    input logic dual_load_enable_in,
    input logic [3:0] dual_load_register_address_in,
    input logic [9:0] dual_load_data_in_flat,
    
    output logic [89:0] bulk_store_data_out_flat
);

    reg signed [4:0] registers [18];

    genvar pack_i;
    generate
        for (int n = 0; n < 18; n++) begin: pack_output
            assign bulk_store_data_out_flat[pack_i*5 +: 5] = registers[pack_i];
        end
    endgenerate
    

    always_ff @(posedge clock_in) begin
        if (reset_in) begin
            for (int i = 0; i < 18; i++) begin
                registers[i] <= 5'b0;
            end
        end

        else if (dual_load_enable_in) begin
            if (dual_load_register_address_in < 4'd9) begin
                for (int i = 0; i < 2; i++) begin
                    registers[(dual_load_register_address_in << 1) + i] <= dual_load_data_in[i];
                end
            end
        end
    end

endmodule
