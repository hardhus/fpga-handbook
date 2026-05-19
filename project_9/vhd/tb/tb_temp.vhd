----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 19.05.2026 15:02:10
-- Design Name:
-- Module Name: tb_temp - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.env.ALL;
use work.counting_buttons_pkg.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_temp is
end entity tb_temp;

architecture test of tb_temp is

  constant INTERVAL     : natural := 10000;
  constant NUM_SEGMENTS : natural := 8;
  constant CLK_PER      : natural := 20; -- ns
  constant SMOOTHING    : natural := 16;

  signal clk : std_logic := '0';
  signal SW  : std_logic_vector(1 downto 0) := "00";
  signal LED : std_logic_vector(1 downto 0);

  -- temp sensor interface
  signal TMP_SCL : std_logic;
  signal TMP_SDA : std_logic;
  signal TMP_INT : std_logic;
  signal TMP_CT  : std_logic;

  -- 7 segment display
  signal anode   : std_logic_vector(NUM_SEGMENTS - 1 downto 0);
  signal cathode : std_logic_vector(7 downto 0);

  -- temperature for simulation
  signal TEMP : std_logic_vector(15 downto 0) := (others => '0');

begin

  clk <= not clk after (CLK_PER * 1 ns) / 2;

  uut : entity work.i2c_temp
    generic map(
      SMOOTHING    => SMOOTHING,
      INTERVAL     => INTERVAL,
      NUM_SEGMENTS => NUM_SEGMENTS,
      CLK_PER      => CLK_PER
    )
    port map(
      clk     => clk,
      -- temp sensor interface
      TMP_SCL => TMP_SCL,
      TMP_SDA => TMP_SDA,
      TMP_INT => TMP_INT,
      TMP_CT  => TMP_CT,
      -- switch interface
      SW      => SW,
      LED     => LED,
      -- 7 segment display
      anode   => anode,
      cathode => cathode
    );

  adt7420 : entity work.adt7420_mdl
    generic map(
      I2C_ADDR => 7x"4B"
    )
    port map(
      temp => TEMP,
      scl  => TMP_SCL,
      sda  => TMP_SDA
    );

  -- Simulate I2C pull-ups on the board
  TMP_SCL <= 'H';
  TMP_SDA <= 'H';

  -------------------------------------------------------------------------
  -- STIMULUS PROCESS
  -------------------------------------------------------------------------
  stimulus : process
  begin
    report "========================================";
    report "[" & to_string(now) & "] Simulation starting...";
    report "========================================";

    -- --- PHASE 1: Celsius Mode with Positive Temp ---
    SW   <= "00";
    TEMP <= "000010100" & "1000" & "000";  -- +20.5 °C
    report "[" & to_string(now) & "] Phase 1: Testing Celsius with +20.5 C (Filling FIFO)...";
    for i in 1 to 100000 loop wait until rising_edge(clk); end loop;

    -- --- PHASE 2: Fahrenheit Mode with Positive Temp ---
    SW   <= "01";
    report "[" & to_string(now) & "] Phase 2: SW set to 01 (Testing Fahrenheit conversion)...";
    for i in 1 to 100000 loop wait until rising_edge(clk); end loop;

    -- --- PHASE 3: Kelvin Mode with Positive Temp ---
    SW   <= "10";
    report "[" & to_string(now) & "] Phase 3: SW set to 10 (Testing Kelvin conversion with +20.5 C)...";
    for i in 1 to 100000 loop wait until rising_edge(clk); end loop;

    -- --- PHASE 4: Celsius Mode with Negative Temp ---
    TEMP <= std_logic_vector(to_signed(-20, 9)) & "1000" & "000"; -- -20.5 °C
    SW   <= "00";
    report "[" & to_string(now) & "] Phase 4: Testing Celsius with -20.5 C...";
    for i in 1 to 100000 loop wait until rising_edge(clk); end loop;

    -- --- PHASE 5: Fahrenheit Mode with Negative Temp ---
    SW   <= "01";
    report "[" & to_string(now) & "] Phase 5: SW set to 01 (Testing Fahrenheit for negative temp)...";
    for i in 1 to 100000 loop wait until rising_edge(clk); end loop;

    -- --- PHASE 6: Kelvin Mode with Negative Temp ---
    SW   <= "10";
    report "[" & to_string(now) & "] Phase 6: SW set to 10 (Testing Kelvin for negative temp)...";
    for i in 1 to 100000 loop wait until rising_edge(clk); end loop;

    report "========================================";
    report "[" & to_string(now) & "] Challenge test completed successfully! Calling std.env.finish.";
    report "========================================";
    finish;
  end process;

  -------------------------------------------------------------------------
  -- MONITOR PROCESS
  -------------------------------------------------------------------------
  monitor_proc : process(clk)
    -- VHDL-2008 External Name ile i2c_temp icindeki encoded sinyaline erisim
    alias uut_encoded is << signal .tb_temp.uut.encoded : array_t(NUM_SEGMENTS - 1 downto 0)(3 downto 0) >>;
    variable prev_encoded : array_t(NUM_SEGMENTS - 1 downto 0)(3 downto 0) := (others => (others => '0'));
  begin
    if rising_edge(clk) then
      if uut_encoded /= prev_encoded then
        report "[" & to_string(now) & "] New Encoded Value: " &
               integer'image(to_integer(unsigned(uut_encoded(7)))) & "," &
               integer'image(to_integer(unsigned(uut_encoded(6)))) & "," &
               integer'image(to_integer(unsigned(uut_encoded(5)))) & "," &
               integer'image(to_integer(unsigned(uut_encoded(4)))) & "," &
               integer'image(to_integer(unsigned(uut_encoded(3)))) & "," &
               integer'image(to_integer(unsigned(uut_encoded(2)))) & "," &
               integer'image(to_integer(unsigned(uut_encoded(1)))) & "," &
               integer'image(to_integer(unsigned(uut_encoded(0))));
        prev_encoded := uut_encoded;
      end if;
    end if;
  end process;

end architecture test;
