module pll #(
    parameter real FS = 1000000.0,
    parameter real CENTER_FREQUENCY = 10000.0,
    parameter real CONTROL_GAIN = 1000.0, // Hz per Volt
    
    parameter [35:0] B0 = 36'b000100000000000000000000000000000000,
    parameter [35:0] B1 = 36'b000000000000000000000000000000000000,
    parameter [35:0] B2 = 36'b000000000000000000000000000000000000,
    parameter [35:0] A1 = 36'b000000000000000000000000000000000000,
    parameter [35:0] A2 = 36'b000000000000000000000000000000000000
) (
    input               clk_in,
    input signed [15:0] sig_ref_in,
    output [15:0]       vco_frequency_out
);
    wire signed [15:0] sig_vco_in;

    wire signed [31:0] pd_output;
    phase_detector pd (
        .clk_in(clk_in),
        .ref_in(sig_ref_in),
        .vco_in(sig_vco_in),
        .pd_error_out(pd_output)
    );

    wire signed [35:0] iir_input = (36'($signed(pd_output))) * 2;
    wire signed [35:0] iir_output;

    iir_filter #(
        .B0(B0),
        .B1(B1),
        .B2(B2),
        .A1(A1),
        .A2(A2)
    ) iir (
        .clk_in(clk_in),
        .signal_in(iir_input),
        .signal_out(iir_output)
    );

    vco_sine #(
        .FS(FS),
        .CENTER_FREQUENCY(CENTER_FREQUENCY),
        .CONTROL_GAIN(CONTROL_GAIN)
    ) vco (
        .clk_in(clk_in),
        .voltage_in(iir_output),
        .sample_out(sig_vco_in),
        .control_frequency_out(vco_frequency_out)
    );
endmodule;
