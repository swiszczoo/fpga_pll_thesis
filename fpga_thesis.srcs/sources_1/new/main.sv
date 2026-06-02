`define iir_b0  1.0625839e-05
`define iir_b1  2.1251678e-05
`define iir_b2  1.0625839e-05
`define iir_a1  1.99075886
`define iir_a2  -0.99080137

module top (
    input   clk,
    input   Vaux1_0_v_n,
    input   Vaux1_0_v_p,
    output  ck_io0,
    output  ck_io1,
    output  ck_io2,
    output  ck_io3,
    output  ck_io4,
    output  ck_io5,
    output  ck_io6,
    output  ck_io7,
    output  ck_io8,
    output  ck_io9,
    output  ck_io10,
    output  ck_io11,
    output  ck_io12,
    output  ck_io13,
    output  ck_io26,
    output  ck_io27
);
    wire data_ready_clk;
    wire signed [11:0] adc_value;

    adc_driver adc_instance (
        .clk_in(clk),
        .pos_in(Vaux1_0_v_p),
        .neg_in(vaux1_0_v_N),
        .data_ready_out(data_ready_clk),
        .last_sample_out(adc_value)
    );

    wire signed [15:0] sig_ref_in;
    assign sig_ref_in[15:4] = adc_value;
    assign sig_ref_in[3:0] = 4'b0000;

    wire [15:0] vco_frequency;
    pll #(
        .FS(25000000.0 / 26.0),
        .CENTER_FREQUENCY(10000.0),
        .CONTROL_GAIN(1000.0),

        .B0(`iir_b0 * $pow(2, 32)),
        .B1(`iir_b1 * $pow(2, 32)),
        .B2(`iir_b2 * $pow(2, 32)),
        .A1(`iir_a1 * $pow(2, 32)),
        .A2(`iir_a2 * $pow(2, 32))
    ) pll_instance (
        .clk_in(data_ready_clk),
        .sig_ref_in(sig_ref_in),
        .vco_frequency_out(vco_frequency)
    );

    // Assign vco_frequency to ChipKit digital I/O
    assign ck_io0 = vco_frequency[0];
    assign ck_io1 = vco_frequency[1];
    assign ck_io2 = vco_frequency[2];
    assign ck_io3 = vco_frequency[3];
    assign ck_io4 = vco_frequency[4];
    assign ck_io5 = vco_frequency[5];
    assign ck_io6 = vco_frequency[6];
    assign ck_io7 = vco_frequency[7];
    assign ck_io8 = vco_frequency[8];
    assign ck_io9 = vco_frequency[9];
    assign ck_io10 = vco_frequency[10];
    assign ck_io11 = vco_frequency[11];
    assign ck_io12 = vco_frequency[12];
    assign ck_io13 = vco_frequency[13];
    assign ck_io26 = vco_frequency[14];
    assign ck_io27 = vco_frequency[15];
endmodule
