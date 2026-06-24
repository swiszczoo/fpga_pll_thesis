parameter real tb_iir_b0 [1] = '{2.2059436460686298e-05};
parameter real tb_iir_b1 [1] = '{4.4118872921372596e-05};
parameter real tb_iir_b2 [1] = '{2.2059436460686298e-05};
parameter real tb_iir_a1 [1] = '{1.9866715465479383};
parameter real tb_iir_a2 [1] = '{-0.9867597842937811};

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
        .B0         (tb_iir_b0),
        .B1         (tb_iir_b1),
        .B2         (tb_iir_b2),
        .A1         (tb_iir_a1),
        .A2         (tb_iir_a2)
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
