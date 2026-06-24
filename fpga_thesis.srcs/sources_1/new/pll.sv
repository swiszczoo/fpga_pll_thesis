module pll #(
    parameter real FS = 1000000.0,
    parameter real CENTER_FREQUENCY = 10000.0,
    parameter real CONTROL_GAIN = 1000.0, // Hz per Volt
    parameter int NUM_SOS = 1,
    
    parameter real B0 [NUM_SOS] = '{1.0},
    parameter real B1 [NUM_SOS] = '{0.0},
    parameter real B2 [NUM_SOS] = '{0.0},
    parameter real A1 [NUM_SOS] = '{0.0},
    parameter real A2 [NUM_SOS] = '{0.0}
) (
    input               clk_in,
    input               data_ready_in,
    input signed [15:0] sig_ref_in,
    output              data_ready_out,
    output [15:0]       vco_frequency_out
);
    wire signed [15:0] sig_vco_in;

    wire signed [31:0] pd_output;
    wire pd_ready;
    phase_detector pd (
        .clk_in(clk_in),
        .data_ready_in(data_ready_in),
        .ref_in(sig_ref_in),
        .vco_in(sig_vco_in),
        .data_ready_out(pd_ready),
        .pd_error_out(pd_output)
    );

    wire signed [35:0] iir_data [NUM_SOS:0];
    assign iir_data[0] = (36'($signed(pd_output))) * 2;

    wire signed [35:0] iir_output = iir_data[NUM_SOS];

    wire iir_ready [NUM_SOS:0];
    assign iir_ready[0] = pd_ready;
    
    genvar i;
    generate
        for (i = 1; i <= NUM_SOS; i++) begin
            iir_filter #(
                .B0(B0[i - 1]),
                .B1(B1[i - 1]),
                .B2(B2[i - 1]),
                .A1(A1[i - 1]),
                .A2(A2[i - 1])
            ) iir (
                .clk_in(clk_in),
                .data_ready_in(iir_ready[i - 1]),
                .signal_in(iir_data[i - 1]),
                .data_ready_out(iir_ready[i]),
                .signal_out(iir_data[i])
            );
        end
    endgenerate

    vco_sine #(
        .FS(FS),
        .CENTER_FREQUENCY(CENTER_FREQUENCY),
        .CONTROL_GAIN(CONTROL_GAIN)
    ) vco (
        .clk_in(clk_in),
        .data_ready_in(iir_ready[NUM_SOS]),
        .voltage_in(iir_output),
        .data_ready_out(data_ready_out),
        .sample_out(sig_vco_in),
        .control_frequency_out(vco_frequency_out)
    );
endmodule;
