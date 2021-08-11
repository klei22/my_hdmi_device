module i2c_scl_clk (
    input  wire clk,
    input  wire reset,
    output wire i2c_scl_clk_div
);

  reg [7:0] clk_taps;
  initial begin
    clk_taps = 8'd64;
  end

  always @(posedge (clk), posedge (reset)) begin
    if (reset) begin
      clk_taps <= 8'h64;
    end else begin
      clk_taps <= clk_taps + 1;
    end
  end

  assign i2c_scl_clk_div = clk_taps[7];  // div by 256
endmodule

