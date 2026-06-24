parameter int tb_num_sos = 2;

parameter real tb_iir_b0 [tb_num_sos] = '{  4.35774336e-08,      1.00000000e-01 };
parameter real tb_iir_b1 [tb_num_sos] = '{  8.71548672e-08,      2.00000000e-01 };
parameter real tb_iir_b2 [tb_num_sos] = '{  4.35774336e-08,      1.00000000e-01 };
parameter real tb_iir_a1 [tb_num_sos] = '{  1.97000170e+00,      1.98730977e+00 };
parameter real tb_iir_a2 [tb_num_sos] = '{ -9.70264599e-01,     -9.87574980e-01 };

/*
parameter real tb_iir_b0 [tb_num_sos] = '{  6.59551947e-05,  6.59551947e-05 };
parameter real tb_iir_b1 [tb_num_sos] = '{  1.31910389e-04,  1.31910389e-04 };
parameter real tb_iir_b2 [tb_num_sos] = '{  6.59551947e-05,  6.59551947e-05 };
parameter real tb_iir_a1 [tb_num_sos] = '{  1.97689802e+00,  1.97689802e+00 };
parameter real tb_iir_a2 [tb_num_sos] = '{ -9.77161839e-01, -9.77161839e-01};
*/

`timescale 1ns / 10ps
module tb_pll(
    output [15:0] sig_ref_in,
    output [15:0] vco_frequency_out
);
    var bit clk_state = 1'b0;
    var bit data_ready_state = 1'b0;
    var bit signed [15:0] ref_signal = 16'b0;

    const real generator_frequency = 9750.0;
    const real pi = 3.14159;

    pll #(
        .FS(500000), // 500 kHz
        .CENTER_FREQUENCY(10000), // 10 kHz
        .CONTROL_GAIN(1000), // 2 kHz
        .NUM_SOS(tb_num_sos),

        .B0(tb_iir_b0),
        .B1(tb_iir_b1),
        .B2(tb_iir_b2),
        .A1(tb_iir_a1),
        .A2(tb_iir_a2)
    ) uut (
        .clk_in(clk_state),
        .data_ready_in(data_ready_state),
        .sig_ref_in(ref_signal),
        .vco_frequency_out(vco_frequency_out)
    );

    assign sig_ref_in = ref_signal;

    initial begin
        clk_state = 1'b0;
        forever #(0.05) clk_state = !clk_state;
    end

    initial begin
        forever begin
            @(posedge clk_state);
            data_ready_state <= 1'b1;
            @(posedge clk_state);
            data_ready_state <= 1'b0;
            for (int i = 0; i < 18; i++) @(posedge clk_state);
        end
    end

    initial begin
        real current_phase = 0.0;
        const real phase_increment = 2 * pi * generator_frequency / 500000.0;

        forever begin
            current_phase += phase_increment;
            if (current_phase > 2 * pi) begin
                current_phase -= 2 * pi;
            end

            ref_signal = $sin(current_phase) * ($pow(2, 15) - 1.0);
            #2;
        end
    end
endmodule
