`timescale 1ns / 1ns
module tb_vco_sine(
    output [15:0]   sample_out,
    output [15:0]   control_frequency_out,
    output          data_ready_out
);
    var bit clk_state = 1'b0;
    var bit data_ready_state = 1'b0;
    var bit [35:0] voltage_state = 36'b0;

    vco_sine #(
        .FS(500000), // 500 kHz
        .CENTER_FREQUENCY(10000), // 10 kHz
        .CONTROL_GAIN(10000) // 10 kHz
    ) uut (
        .clk_in(clk_state),
        .data_ready_in(data_ready_state),
        .voltage_in(voltage_state),
        .data_ready_out(data_ready_out),
        .sample_out(sample_out),
        .control_frequency_out(control_frequency_out)
    );

    initial begin
        clk_state = 1'b0;
        forever #1 clk_state = !clk_state;
    end

    initial begin
        forever begin
            @(posedge clk_state);
            data_ready_state <= 1'b1;
            @(posedge clk_state);
            data_ready_state <= 1'b0;
            for (int i = 0; i < 8; i++) @(posedge clk_state);
        end
    end

    initial begin
        @(posedge clk_state);
        voltage_state <= 36'h000000000;
        #1000;
        @(posedge clk_state);
        voltage_state <= 36'h123456789;
        #2000;
        @(posedge clk_state);
        voltage_state <= 36'hf00000000;
        #2000;
        @(posedge clk_state);
        voltage_state <= 36'h000000000;
    end
endmodule
