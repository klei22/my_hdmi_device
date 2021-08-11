#!/bin/bash

# iverilog -o dsn i2c_clk_tb.v i2c_clk.v
# vvp dsn
# gtkwave test.vcd &

iverilog -o dsn i2c_tb.v i2c.v i2c_scl_clk.v i2c_sda_clk.v
vvp dsn
gtkwave test.vcd &
