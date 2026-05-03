----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.05.2026 18:49:31
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
use IEEE.numeric_std.ALL;

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

  constant INTERVAL     : natural                       := 5000; -- ns
  constant NUM_SEGMENTS : natural                       := 8;
  constant CLK_PER      : natural                       := 10; -- ns
  constant SMOOTHING    : natural                       := 16;

  signal clk : std_logic := '0';

  -- Temperature Sensor Interface
  signal TMP_SCL : std_logic;
  signal TMP_SDA : std_logic;
  signal TMP_INT : std_logic;
  signal TMP_CT  : std_logic;

  -- 7 segment display
  signal anode   : std_logic_vector(NUM_SEGMENTS - 1 downto 0);
  signal cathode : std_logic_vector(7 downto 0);
  
  -- Temperature for simulation
  signal TEMP_SIG : std_logic_vector(15 downto 0) := (others => '0');

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
      -- Temperature sensor interface
      TMP_SCL => TMP_SCL,
      TMP_SDA => TMP_SDA,
      TMP_INT => TMP_INT,
      TMP_CT  => TMP_CT,
      -- 7 segment display
      anode   => anode,
      cathode => cathode
    );

  adt7420 : entity work.adt7420_mdl
    generic map(
      I2C_ADDR => 7x"4B"
    )
    port map(
      temp => TEMP_SIG,
      scl  => TMP_SCL,
      sda  => TMP_SDA
    );

  -- Simulate I2C pull-ups on the board
  TMP_SCL <= 'H';
  TMP_SDA <= 'H';
  
  -- Smart Logger Process
  process
    variable test_passed : boolean := true;
    variable expected_val: std_logic_vector(12 downto 0);
    variable filter_val  : std_logic_vector(12 downto 0);
    
    -- For accessing internal signals in VHDL-2008 (External Names)
    alias internal_smooth_data is << signal uut.smooth_data : std_logic_vector(15 downto 0) >>;
  begin
    TEMP_SIG <= 9d"20" & 4d"8" & "000";
    report "TEST 1 Starting: 20.5 C waiting...";
    
    for i in 1 to 1000000 loop
        wait until rising_edge(clk);
    end loop;
    
    expected_val := TEMP_SIG(15 downto 3);
    filter_val   := internal_smooth_data(15 downto 3);

    if filter_val /= expected_val then
        report "ERROR! Expected: " & to_hstring(expected_val) & ", From The Filter: " & to_hstring(filter_val) severity error;
        test_passed := false;
    else
        report "-> TEST 1 SUCCESSFUL! 20.5 C verified.";
    end if;
    
    TEMP_SIG <= std_logic_vector(to_signed(-20, 9)) & 4d"8" & "000";
    report "TEST 2 Starting: -20.5 C waiting...";
    
    for i in 1 to 1000000 loop
        wait until rising_edge(clk);
    end loop;

    expected_val := TEMP_SIG(15 downto 3);
    filter_val   := internal_smooth_data(15 downto 3);

    if filter_val /= expected_val then
        report "ERROR! Expected: " & to_hstring(expected_val) & ", From The Filter: " & to_hstring(filter_val) severity error;
        test_passed := false;
    else
        report "-> TEST 2 SUCCESSFUL! -20.5 C verified.";
    end if;

    report "===========================================";
    if test_passed then
        report "RESULT: ALL TESTS PASSED!";
    else
        report "RESULT: SOME TESTS HAVE ERRORS, CHECK THE CODE.";
    end if;
    report "===========================================";

    std.env.stop;
  end process;

end architecture test;
