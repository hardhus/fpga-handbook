`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 03.05.2026 20:50:45
// Design Name:
// Module Name: tb_temp
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module tb_temp_flt;

  parameter INTERVAL = 10000;
  parameter NUM_SEGMENTS = 8;
  parameter CLK_PER = 20;

  logic                           clk;
  logic        [             1:0] SW;  // Updated to 2-bit to support 3 temperature scales
  logic        [             1:0] LED;  // Updated to 2-bit to monitor scale status

  // temp sensor interface
  tri1                            TMP_SCL;
  tri1                            TMP_SDA;
  tri1                            TMP_INT;
  tri1                            TMP_CT;

  // 7 segment display
  logic        [NUM_SEGMENTS-1:0] anode;
  logic        [             7:0] cathode;

  // temperature for simulation
  logic signed [            15:0] TEMP;

  initial clk = '0;
  always begin
    clk = #(CLK_PER / 2) ~clk;
  end

  initial begin
    $display("========================================");
    $display("[%0t] Simulation starting...", $time);
    $display("========================================");

    // --- PHASE 1: Celsius Mode with Positive Temp ---
    SW   = 2'b00;  // Celsius Mode
    TEMP = {9'd20, 4'd8, 3'b000};  // +20.5 °C
    $display("[%0t] Phase 1: Testing Celsius with +20.5 C (Filling FIFO)...", $time);
    repeat (100000) @(posedge clk);

    // --- PHASE 2: Fahrenheit Mode with Positive Temp ---
    SW = 2'b01;  // Fahrenheit Mode
    $display("[%0t] Phase 2: SW set to 01 (Testing Fahrenheit conversion)...", $time);
    repeat (100000) @(posedge clk);

    // --- PHASE 3: Kelvin Mode with Positive Temp ---
    SW = 2'b10;  // Kelvin Mode
    $display("[%0t] Phase 3: SW set to 10 (Testing Kelvin conversion with +20.5 C)...", $time);
    repeat (100000) @(posedge clk);

    // --- PHASE 4: Celsius Mode with Negative Temp ---
    TEMP = {-9'sd20, 4'd8, 3'b000};  // -20.5 °C
    SW   = 2'b00;  // Celsius Mode
    $display("[%0t] Phase 4: Testing Celsius with -20.5 C...", $time);
    repeat (100000) @(posedge clk);

    // --- PHASE 5: Fahrenheit Mode with Negative Temp ---
    SW = 2'b01;  // Fahrenheit Mode
    $display("[%0t] Phase 5: SW set to 01 (Testing Fahrenheit for negative temperature)...", $time);
    repeat (100000) @(posedge clk);

    // --- PHASE 6: Kelvin Mode with Negative Temp ---
    SW = 2'b10;  // Kelvin Mode
    $display("[%0t] Phase 6: SW set to 10 (Testing Kelvin for negative temperature)...", $time);
    repeat (100000) @(posedge clk);

    $display("========================================");
    $display("[%0t] Challenge test completed successfully! Calling $stop.", $time);
    $display("========================================");
    $stop;
  end

  i2c_temp_flt #(
      .INTERVAL    (INTERVAL),
      .NUM_SEGMENTS(NUM_SEGMENTS),
      .CLK_PER     (CLK_PER)
  ) u_i2c_temp (
      .clk(clk),  // 100Mhz clock

      // temp sensor interface
      .TMP_SCL(TMP_SCL),
      .TMP_SDA(TMP_SDA),
      .TMP_INT(TMP_INT),
      .TMP_CT (TMP_CT),

      .SW (SW),
      .LED(LED),

      // 7 segment display
      .anode  (anode),
      .cathode(cathode)
  );

  adt7420_mdl #(
      .I2C_ADDR(7'h4B)
  ) adt7420_mdl (
      .temp(TEMP),
      .scl (TMP_SCL),
      .sda (TMP_SDA)
  );

  // Monitor to display encoded value only when it changes
  logic [NUM_SEGMENTS-1:0][3:0] monitor_encoded;
  logic [            31:0]      prev_encoded = '0;

  // Safely hook into the internal multi-dimensional vector
  assign monitor_encoded = u_i2c_temp.encoded;

  always @(posedge clk) begin
    if (monitor_encoded !== prev_encoded) begin
      $display("[%0t ns] New Encoded Value: %0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d", $time / 1000.0,
               monitor_encoded[7], monitor_encoded[6], monitor_encoded[5], monitor_encoded[4],
               monitor_encoded[3], monitor_encoded[2], monitor_encoded[1], monitor_encoded[0]);
      prev_encoded = monitor_encoded;
    end
  end


endmodule
