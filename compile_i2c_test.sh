#!/bin/bash

iverilog -o dsn i2c_clk_tb.v i2c_clk.v
vvp dsn
gtkwave test.vcd &
