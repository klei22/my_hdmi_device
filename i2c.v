`define IDLE 8'b0
`define START 8'b1
`define SEND_ADDR 8'h2
`define STOP 8'h3
`define SEND_DATA 8'h4
`define RECEIVE_DATA 8'h5
`define REPEATED_START 8'h6
`define CLKS_FOR_I2C 750  // 25MHz/100KHz = 250; 250 * 3 = 750x (for buffer) or 30KB/s
`define CLKS_FOR_I2C_HOLD 200 // 8us, min is 4 us, or factor of 100
`define INTERMESSAGE_DELAY 100_000

`define SET_READ_BIT 1
`define SET_WRITE_BIT 0

`define INDEX_RW_BIT 1
`define INDEX_NUM_STARTS 2

module i2c (
    input  wire clk,
    input  wire reset,
    output reg  sda,
    output reg  scl
);

  parameter I2C_ADDR = 7'h69, DATA_PACKET = 8'h05, RW_BIT = 1'h0, START_COUNTER = 8'h0;


  reg [7:0] data;  // 16 bytes of data, TODO index with params
  reg [3:0] data_index;  // index for the buffered data

  // Note: counter max value has to be at least as large as "CLKS_FOR_..." HOlD params
  reg [7:0] counter;  // 8-bit counter for triggering stage changes after bit transfer



  // 8-bit i2c-central
  reg [7:0] state;  // 8 bit state

  initial begin
    data[7:0]  = DATA_PACKET;
    counter    = 0;
    data_index = 0;
    state      = 0;
    sda        = 1;
    scl        = 1;
  end

  /* assign scl = (en_i2c_scl) ? clk : 1; */

  always @(posedge clk) begin
    if (reset == 1) begin
      // INITIALIZE OR RESET I2c-Bus state
      sda <= 1;
      scl <= 1;
      counter <= 0;
      data_index <= 0;
      state <= `IDLE;
    end else begin
      // TODO: Make a snippet for subcase
      case (state)
        `IDLE: begin  //idle, both the sda and scl should be high
          sda   <= 1;
          scl   <= 1;
          state <= `START;
        end
        `START: begin  //start sequence
          // hold the sda low for 8us
          if (counter == 0) begin
            sda <= 0;
            scl <= 1;
            counter <= counter + 1;
          end else if (counter == 1) begin
            // hold the scl low for 8us
            sda <= 0;
            scl <= 0;
            counter <= counter + 1;
          end else begin
            // reset counter and send to next state
            counter <= 0;
            state   <= `SEND_ADDR;
          end
        end
        `SEND_ADDR: begin  // send address for writing
          if (counter < 8) begin
            sda        <= data[data_index+:1];
            scl        <= 0;
            counter    <= counter + 1;  // increment counter
            data_index <= data_index + 1;
          end else begin
            counter <= 0;
            data_index <= data_index + 1;
            state <= `STOP;
          end
        end
        `STOP: begin  // msb address bit
          if (counter == 0) begin
            sda <= 0;
            scl <= 0;
            counter <= counter + 1;
          end else if (counter == 1) begin
            sda <= 0;
            scl <= 1;
            counter <= counter + 1;
          end else if (counter == 2) begin
            sda     <= 1;
            scl     <= 1;
            counter <= 0;  // increment counter
            state   <= 10;
          end
        end
        10: begin
          sda     <= 1;
          scl     <= 1;
          counter <= 0;
        end
        default: begin
        end
      endcase
    end
  end
endmodule
