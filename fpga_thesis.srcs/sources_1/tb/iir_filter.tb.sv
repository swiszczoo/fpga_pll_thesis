`timescale 1ns / 1ns
module tb_iir_filter (
    output [35:0]   filter_in, // Q4.32
    output [35:0]   filter_out, // Q4.32
    output          data_ready_out
);
    var bit clk_state = 1'b0;
    var bit data_ready_state = 1'b0;
    var bit [35:0] signal_in_state = 36'b0;

    iir_filter #(
        .B0         (36'h0000001ca),
        .B1         (36'h000000394),
        .B2         (36'h0000001ca),
        .A1         (36'h1ffc36fd6),
        .A2         (36'hf003c88f2)
    ) uut (
        .clk_in         (clk_state),
        .data_ready_in  (data_ready_state),
        .signal_in      (signal_in_state),
        .data_ready_out (data_ready_out),
        .signal_out     (filter_out)
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
        signal_in_state = 36'h000000000;
        #10000;
        @(posedge clk_state);
        signal_in_state <= 36'h100000000;
    end

    assign filter_in = signal_in_state;
endmodule
