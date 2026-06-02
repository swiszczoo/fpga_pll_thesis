module mult_36x36_safe(
  input wire            CLK,
  input wire [35:0]     A,
  input wire [35:0]     B,
  output reg [71:0]     P
);
    wire [71:0] mult_out;
    logic ready = 1'b0;

    mult_36x36 mult (
        .CLK(CLK),
        .A(A),
        .B(B),
        .P(mult_out)
    );

    always_comb begin
        if (ready) P = mult_out;
        else P = 72'b0;
    end

    always_ff @(posedge CLK) begin
        ready <= 1;
    end
endmodule
