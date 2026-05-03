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


module tb_temp;

  parameter INTERVAL = 10000;
  parameter NUM_SEGMENTS = 8;
  parameter CLK_PER = 20;
  logic clk;
  logic SW, LED;

  // temp sensor interface
  tri1                            TMP_SCL;
  tri1                            TMP_SDA;
  tri1                            TMP_INT;
  tri1                            TMP_CT;

  // seven segment display
  logic        [NUM_SEGMENTS-1:0] anode;
  logic        [             7:0] cathode;

  // temperature for simulation
  logic signed [            15:0] TEMP;
  logic                           test_passed;

  initial clk = '0;
  always begin
    clk = #(CLK_PER / 2) ~clk;
  end

  i2c_temp #(
      .INTERVAL    (INTERVAL),
      .NUM_SEGMENTS(NUM_SEGMENTS),
      .CLK_PER     (CLK_PER)
  ) u_i2c_temp (
      .clk(clk),  // 100Mhz 

      // temp sensor display
      .TMP_SCL(TMP_SCL),
      .TMP_SDA(TMP_SDA),
      .TMP_INT(TMP_INT),
      .TMP_CT (TMP_CT),

      .SW (SW),
      .LED(LED),

      // seven segment display
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

  logic [15:0] captured_data;
  always_ff @(posedge clk) begin
    if (u_i2c_temp.smooth_convert) begin
      captured_data <= u_i2c_temp.smooth_data[15:0];
    end  // if
  end  // always_ff

  initial begin
    test_passed = 1'b1;

    // TEST 1: 20.5 C 
    SW          = '0;
    TEMP        = {9'd20, 4'd8, 3'b000};  // 20.5 °C
    $display("TEST 1 Starting: 20.5 C (Celsius) waiting...");
    repeat (1000000) @(posedge clk);
    if (captured_data !== 16'h0A40) begin
      $error("ERROR! Expected: 0A40, Got: %h", captured_data);
      test_passed = 1'b0;
    end else $display("-> TEST 1 SUCCESSFUL! 20.5 C verified.");

    // TEST 2: 20.5 C -> 68.9 F 
    SW = '1;
    $display("TEST 2 Starting: 68.9 F (Fahrenheit) waiting...");
    repeat (1000000) @(posedge clk);
    if (captured_data !== 16'h1473) begin
      $error("ERROR! Expected: 1473, Got: %h", captured_data);
      test_passed = 1'b0;
    end else $display("-> TEST 2 SUCCESSFUL! 68.9 F verified.");

    // TEST 3: -20.5 C 
    TEMP = {-9'sd20, 4'd8, 3'b000};  // -20.5 °C
    SW   = '0;
    $display("TEST 3 Starting: -20.5 C (Celsius) waiting...");
    repeat (1000000) @(posedge clk);
    if (captured_data !== 16'hF640) begin
      $error("ERROR! Expected: F640, Got: %h", captured_data);
      test_passed = 1'b0;
    end else $display("-> TEST 3 SUCCESSFUL! -20.5 C verified.");

    // TEST 4: -20.5 C -> -4.9 F 
    SW = '1;
    $display("TEST 4 Starting: -4.9 F (Fahrenheit) waiting...");
    repeat (1000000) @(posedge clk);
    if (captured_data !== 16'hF073) begin
      $error("ERROR! Expected: F073, Got: %h", captured_data);
      test_passed = 1'b0;
    end else $display("-> TEST 4 SUCCESSFUL! -4.9 F verified.");

    $display("===========================================");
    if (test_passed) $display("RESULT: ALL TESTS PASSED!");
    else $display("RESULT: SOME TESTS HAVE ERRORS, CHECK THE CODE.");
    $display("===========================================");

    $stop;
  end

endmodule
