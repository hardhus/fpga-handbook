`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2026 00:31:57
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
  logic                           clk;

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

  initial begin
    test_passed = 1'b1;

    TEMP        = {9'd20, 4'd8, 3'b000};  // 20.5 °C
    $display("TEST 1 Starting: 20.5 C waiting...");
    repeat (1000000) @(posedge clk);

    if (u_i2c_temp.smooth_data[15:3] !== TEMP[15:3]) begin
      $error("ERROR! Expected: %h, From The Filter: %h", TEMP[15:3], u_i2c_temp.smooth_data[15:3]);
      test_passed = 1'b0;
    end else begin
      $display("-> TEST 1 SUCCESSFUL! 20.5 C verified.");
    end

    TEMP = {-9'sd20, 4'd8, 3'b000};  // -20.5 °C
    $display("TEST 2 Starting: -20.5 C waiting...");
    repeat (1000000) @(posedge clk);

    if (u_i2c_temp.smooth_data[15:3] !== TEMP[15:3]) begin
      $error("ERROR! Expected: %h, From The Filter: %h", TEMP[15:3], u_i2c_temp.smooth_data[15:3]);
      test_passed = 1'b0;
    end else begin
      $display("TEST 2 SUCCESSFUL! -20.5 C verified.");
    end

    $display("===========================================");
    if (test_passed) $display("RESULT: ALL TESTS PASSED!");
    else $display("RESULT: SOME TESTS HAVE ERRORS, CHECK THE CODE.");
    $display("===========================================");

    $stop;
  end

endmodule
