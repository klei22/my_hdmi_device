`timescale 10ns / 10ns

module i2c_clk_tb;

  reg reset = 0;

  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0, i2c_clk_tb);
    #10000 $finish;
  end

  /* Make a regular pulsing clock. */
  reg clk = 0;
  always #2 clk = !clk; // 40ns period, b/c 25MHz freq

  wire i2c_clk_div;
  i2c_clk i2cclk1 (
      .clk(clk),
      .reset(reset),
      .i2c_clk_div(i2c_clk_div)
  );

endmodule
