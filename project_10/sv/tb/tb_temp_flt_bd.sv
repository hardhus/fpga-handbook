`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.05.2026 23:30:29
// Design Name: 
// Module Name: tb_temp_flt_bd
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


module tb_temp_flt_bd;

  parameter NUM_SEGMENTS = 8;
  parameter CLK_PER = 20;

  logic                           clk;
  logic                           rst;
  logic        [             1:0] SW;
  logic        [             1:0] LED;

  // temp sensor interface
  tri1                            TMP_SCL;
  tri1                            TMP_SDA;
  wire                            TMP_INT;
  wire                            TMP_CT;

  // 7 segment display 
  logic        [NUM_SEGMENTS-1:0] anode;
  logic        [             7:0] cathode;

  logic signed [            15:0] TEMP;

  initial clk = '0;
  always begin
    clk = #(CLK_PER / 2) ~clk;
  end

  initial begin
    $display("=========================================================");
    $display("[%0t] Block Design Simulation Starting...", $time);
    $display("=========================================================");

    rst  = 1'b1;
    SW   = 2'b00;
    TEMP = {9'd20, 4'd8, 3'b000};  // +20.5 °C
    #(CLK_PER * 10);
    rst = 1'b0;

    // --- PHASE 1: Celsius Mode with Positive Temp ---
    SW  = 2'b00;
    $display("[%0t] Phase 1: Testing Celsius with +20.5 C (Filling FIFO)...", $time);
    repeat (100000) @(posedge clk);

    // --- PHASE 2: Fahrenheit Mode with Positive Temp ---
    SW = 2'b01;
    $display("[%0t] Phase 2: SW set to 01 (Testing Fahrenheit conversion)...", $time);
    repeat (100000) @(posedge clk);

    // --- PHASE 3: Kelvin Mode with Positive Temp ---
    SW = 2'b10;
    $display("[%0t] Phase 3: SW set to 10 (Testing Kelvin conversion with +20.5 C)...", $time);
    repeat (100000) @(posedge clk);

    // --- PHASE 4: Celsius Mode with Negative Temp ---
    TEMP = {-9'sd20, 4'd8, 3'b000};  // -20.5 °C
    SW   = 2'b00;
    $display("[%0t] Phase 4: Testing Celsius with -20.5 C...", $time);
    repeat (100000) @(posedge clk);

    // --- PHASE 5: Fahrenheit Mode with Negative Temp ---
    SW = 2'b01;
    $display("[%0t] Phase 5: SW set to 01 (Testing Fahrenheit for negative temperature)...", $time);
    repeat (100000) @(posedge clk);

    // --- PHASE 6: Kelvin Mode with Negative Temp ---
    SW = 2'b10;
    $display("[%0t] Phase 6: SW set to 10 (Testing Kelvin for negative temperature)...", $time);
    repeat (100000) @(posedge clk);

    $display("=========================================================");
    $display("[%0t] Challenge Block Design Test Completed Successfully!", $time);
    $display("=========================================================");
    $stop;
  end

  i2c_temp_flt_bd_wrapper u_dut (
      .sys_clock(clk),
      .reset    (rst),
      .SW_0     (SW),
      .LED_0    (LED),
      .TMP_SCL_0(TMP_SCL),
      .TMP_SDA_0(TMP_SDA),
      .TMP_INT_0(TMP_INT),
      .TMP_CT_0 (TMP_CT),
      .anode_0  (anode),
      .cathode_0(cathode)
  );

  defparam u_dut.i2c_temp_flt_bd_i.adt7420_i2c_0.inst.INTERVAL = 10000;

  adt7420_mdl #(
      .I2C_ADDR(7'h4B)
  ) u_sensor_model (
      .temp(TEMP),
      .scl (TMP_SCL),
      .sda (TMP_SDA)
  );

  logic [NUM_SEGMENTS-1:0][3:0] monitor_encoded;
  logic [            31:0]      prev_encoded = '0;

  assign monitor_encoded = u_dut.i2c_temp_flt_bd_i.flt_temp_0.seven_segment_tdata;

  always @(posedge clk) begin
    if (monitor_encoded !== prev_encoded) begin
      $display("[%0t ns] New Encoded Value: %0h %0h %0h %0h %0h %0h %0h %0h", $time / 1000.0,
               monitor_encoded[7], monitor_encoded[6], monitor_encoded[5], monitor_encoded[4],
               monitor_encoded[3], monitor_encoded[2], monitor_encoded[1], monitor_encoded[0]);
      prev_encoded = monitor_encoded;
    end
  end

endmodule
