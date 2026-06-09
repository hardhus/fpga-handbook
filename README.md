# FPGA Digital System Design Lab Projects

This repository contains a collection of hardware description language (HDL) projects implemented in both **SystemVerilog** and **VHDL**. The designs cover fundamental combinatorial logic circuits, finite state machines (FSMs), digital signaling DSP pipelines (PDM/PWM), and multi-protocol hardware interfaces (I2C/AXI-Stream) integrated with AMD Xilinx IP cores.

---

## 📂 Directory Structure & Projects Overview

The repository is organized into standalone development modules, each providing symmetric codebases for dual-language validation.

### 🔹 Project 1: Fundamental Combinatorial Logic
* **Directory:** `project_1/`
* **Core Modules:** `logic_ex`, `challenge` (Full Adder)
* **Description:** Implementation of basic logic gates (NOT, AND, OR, XOR) and a structural/behavioral Full Adder circuit mapped to board switches (`SW`) and LEDs.

### 🔹 Project 2: Arithmetic Logic Unit (ALU) & Vector Operations
* **Directory:** `project_2/`
* **Core Modules:** `add_sub`, `mult`, `num_ones`, `leading_ones`, `project_2` (ALU Top)
* **Description:** A parameterized combinatorial processing unit performing signed addition, subtraction, multiplication, population count (counting active bits), and leading-one detection using iterative loops and advanced conditional generation techniques.

### 🔹 Project 3: Multiplexed 7-Segment Display Controller
* **Directory:** `project_3/`
* **Core Modules:** `cathode_top`, `seven_segment`, `counting_buttons`
* **Description:** An asynchronous pushbutton counter with optional hardware debouncer logic that streams integrated hexadecimal or binary-coded decimal (BCD) increments onto a time-multiplexed 8-digit 7-segment display.

### 🔹 Project 4: State Machine Calculator Engine
* **Directory:** `project_4/`
* **Core Modules:** `calculator_mealy`, `calculator_moore`, `calculator_top`
* **Description:** A multi-bit calculator driven by directional buttons and hardware register storage. Implemented twice to contrast **Mealy** and **Moore** finite state machine (FSM) output behaviors, backed by a clock management network (`sys_pll`).

### 🔹 Project 5: Traffic Light Controller with PWM Dimming
* **Directory:** `project_5/`
* **Core Modules:** `traffic_light`
* **Description:** A timed FSM driving an intersecting traffic signal model. Incorporates asynchronous sensor sync registers for vehicle detection and a 1 kHz Pulse Width Modulation (PWM) subsystem to drive tricolor LEDs.

### 🔹 Project 6: PDM Audio Recorder & PWM Playback Pipeline
* **Directory:** `project_6/`
* **Core Modules:** `pdm_inputs`, `pdm_output`, `pwm_outputs`, `pdm_top`
* **Description:** A complete digital audio recording pipeline. Samples 1-bit Pulse Density Modulation (PDM) streams from an FPGA-bound omnidirectional microphone, filters it into structural binary amplitude indexes inside internal block RAM (`RAM_SIZE`), and plays it back using a custom delta-sigma audio PWM controller.

### 🔹 Project 7 & 8: Fixed-Point I2C Temperature Sensor Node
* **Directory:** `project_7/` & `project_8/`
* **Core Modules:** `i2c_temp`, `temp_pkg`
* **Description:** Hardware master controller interfacing with an external **ADT7420** temperature sensor over an explicit bit-banged I2C sequence. Includes a moving-average smoothing FIFO buffer (`xpm_fifo_sync`) and dynamic BCD scale converters to feed real-time Celsius (°C) and Fahrenheit (°F) readouts onto a 7-segment cluster.

### 🔹 Project 9 & 10: Advanced Floating-Point (FP) Sensor Pipeline & IP Integrator
* **Directory:** `project_9/` & `project_10/`
* **Core Modules:** `i2c_temp_flt`, `flt_temp`, `i2c_temp_flt_band_sv`
* **Description:** A high-end scientific DSP platform utilizing Xilinx/AMD Floating-Point Floating-Point IP cores. Fixed-point I2C data streams are piped through `fix_to_float`, filtered inside an algebraic FP adder-subtractor, mathematically scaled to Kelvin notations via a `fused_mult_add` core, and mapped back to the display framework. Accompanied by Xilinx Vivado IP Integrator Block Designs (`i2c_temp_flt_bd`).

---

## 🛠️ Stack & Verification Environment

* **Hardware Description Languages:** `SystemVerilog` (IEEE 1800) / `VHDL` (VHDL-2008)
* **EDA Toolchain:** `AMD Xilinx Vivado Design Suite` / `Vivado Simulator (XSIM)`
* **IP Hardware Macros Used:** `xpm_fifo_sync`, `sys_pll`, `fix_to_float`, `flt_to_fix`, `fp_addsub`, `fp_mult`, `fp_fused_mult_add`
* **Bus Topologies:** `I2C`, `AXI4-Stream (AXIS)`, `AXI4-Lite (AXIL)`

## 🔬 Simulation and Verification

Every hardware project is accompanied by a self-checking testbench framework located under the respective `/tb` folders.
* Testbenches feature automated mathematical validation checkers, hierarchical cross-module signal hooks (using VHDL-2008 **External Names** and SystemVerilog `.*` interfaces), and device behavioral models (such as `adt7420_mdl`) simulating accurate bus transactions for comprehensive verification coverage.
