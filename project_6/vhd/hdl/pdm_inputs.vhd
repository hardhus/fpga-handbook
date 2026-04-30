----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.04.2026 19:53:04
-- Design Name: 
-- Module Name: pdm_inputs - Behavioral
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

use work.util_pkg.ALL;

entity pdm_inputs is
  generic(
    CLK_FREQ     : natural := 100;      -- MHz
    MCLK_FREQ    : natural := 2500000;  -- Hz
    SAMPLE_COUNT : natural := 128
  );
  port(
    clk             : in  std_logic;
    -- mic interface
    m_clk           : out std_logic := '0';
    m_clk_en        : out std_logic := '0';
    m_data          : in  std_logic;
    -- Amplitude outputs
    amplitude       : out std_logic_vector(clog2(SAMPLE_COUNT + 1) - 1 downto 0);
    amplitude_valid : out std_logic := '0'
  );
end entity pdm_inputs;


architecture rtl of pdm_inputs is

  constant CLK_COUNT       : integer := (CLK_FREQ * 1000000) / (MCLK_FREQ * 2);
  constant WINDOW_SIZE     : natural := 200; 
  constant COUNTER1_OFFSET : natural := WINDOW_SIZE / 2; 
  constant TERMINAL_COUNT0 : natural := SAMPLE_COUNT; 
  constant TERMINAL_COUNT1 : natural := SAMPLE_COUNT - COUNTER1_OFFSET; 

  type sample_counter_array_t is array (natural range <>) of integer range 0 to SAMPLE_COUNT;

  signal counter        : integer range 0 to WINDOW_SIZE - 1 := 0;
  signal sample_counter : sample_counter_array_t(1 downto 0) := (others => 0);
  signal clk_counter    : integer range 0 to CLK_COUNT - 1   := 0;

begin

  process(clk) is
  begin
    if rising_edge(clk) then
      amplitude_valid <= '0';
      m_clk_en        <= '0';

      if clk_counter = CLK_COUNT - 1 then
        clk_counter <= 0;
        m_clk       <= not m_clk;
        m_clk_en    <= not m_clk;
      else
        clk_counter <= clk_counter + 1;
      end if;

      if m_clk_en then
        if counter < WINDOW_SIZE - 1 then
          counter <= counter + 1;
        else
          counter <= 0;
        end if;
        if counter = TERMINAL_COUNT0 then
          amplitude         <= std_logic_vector(to_unsigned(sample_counter(0), amplitude'length));
          amplitude_valid   <= '1';
          sample_counter(0) <= 0;
        elsif counter < TERMINAL_COUNT0 then
          if m_data then
            sample_counter(0) <= sample_counter(0) + 1;
          end if;
        end if;
        if counter = TERMINAL_COUNT1 then
          amplitude         <= std_logic_vector(to_unsigned(sample_counter(1), amplitude'length));
          amplitude_valid   <= '1';
          sample_counter(1) <= 0;
        elsif (counter < TERMINAL_COUNT1) or (counter >= COUNTER1_OFFSET) then
          if m_data then
            sample_counter(1) <= sample_counter(1) + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

end architecture rtl;
