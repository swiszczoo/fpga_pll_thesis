// 2nd order PLL filter coefficients
// Butterworth, fc = 1500 Hz, fs = 961538 Hz
/*
parameter int num_sos = 1;
parameter real iir_b0 [num_sos-1:0] = '{2.38531558e-05};
parameter real iir_b1 [num_sos-1:0] = '{4.77063117e-05};
parameter real iir_b2 [num_sos-1:0] = '{2.38531558e-05};
parameter real iir_a1 [num_sos-1:0] = '{1.98613842};
parameter real iir_a2 [num_sos-1:0] = '{-0.98623384};
*/

// 4th order PLL filter coeffcients
// Butterworth, fc = 2500 Hz, fs = 961358 Hz
parameter int num_sos = 2;
parameter real iir_b0 [num_sos] = '{  4.35774336e-08,      1.00000000e-01 };
parameter real iir_b1 [num_sos] = '{  8.71548672e-08,      2.00000000e-01 };
parameter real iir_b2 [num_sos] = '{  4.35774336e-08,      1.00000000e-01 };
parameter real iir_a1 [num_sos] = '{  1.97000170e+00,      1.98730977e+00 };
parameter real iir_a2 [num_sos] = '{ -9.70264599e-01,     -9.87574980e-01 };


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
    parameter [3:0] CLK_DIV = 5 - 1; // 125 MHz / 5 -> 25 MHz (26x ADC rate)

    wire data_ready_clk;
    wire signed [11:0] adc_value;
    wire [1:0] debug_adc_state;

    adc_driver adc_instance (
        .clk_in(clk),
        .pos_in(Vaux1_0_v_p),
        .neg_in(vaux1_0_v_N),
        .data_ready_out(data_ready_clk),
        .last_sample_out(adc_value),
        .debug_adc_state_out(debug_adc_state)
    );

    logic [3:0] clk_div_counter = 4'b0;
    logic [3:0] clk_div_counter_next;
    
    logic pll_clk_reg = 1'b0;
    logic pll_clk_next;

    logic [11:0] adc_value_q = 12'b0;
    logic data_ready_clk_q = 1'b0;

    always_comb begin
        if (clk_div_counter == CLK_DIV || data_ready_clk) begin
            clk_div_counter_next = 4'b0;
            pll_clk_next = 1'b1;
        end else begin
            clk_div_counter_next = clk_div_counter + 4'b1;
            pll_clk_next = 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        clk_div_counter <= clk_div_counter_next;
        pll_clk_reg <= pll_clk_next;
        adc_value_q <= adc_value;

        if (pll_clk_next) begin
            data_ready_clk_q <= data_ready_clk;
        end
    end

    wire signed [15:0] sig_ref_in_q;
    assign sig_ref_in_q[15:4] = adc_value_q;
    assign sig_ref_in_q[3:0] = 4'b0000;

    wire [15:0] vco_frequency;
    wire vco_data_ready;
    logic prev_vco_data_ready = 1'b0;
    logic bipolar_trigger = 1'b0;

    pll #(
        .FS(25000000.0 / 26.0),
        .CENTER_FREQUENCY(10000.0),
        .CONTROL_GAIN(1000.0),
        .NUM_SOS(num_sos),

        .B0(iir_b0),
        .B1(iir_b1),
        .B2(iir_b2),
        .A1(iir_a1),
        .A2(iir_a2)
    ) pll_instance (
        .clk_in(pll_clk_reg),
        .data_ready_in(data_ready_clk_q),
        .sig_ref_in(sig_ref_in_q),
        .data_ready_out(vco_data_ready),
        .vco_frequency_out(vco_frequency)
    );

    always_ff @(posedge pll_clk_reg) begin
        if (vco_data_ready && !prev_vco_data_ready) begin
            bipolar_trigger <= !bipolar_trigger;
        end

        prev_vco_data_ready <= vco_data_ready;
    end

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
    assign ck_io27 = bipolar_trigger;
endmodule
