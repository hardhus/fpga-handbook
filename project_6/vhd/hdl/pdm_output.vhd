----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.04.2026 19:53:25
-- Design Name: 
-- Module Name: pdm_output - Behavioral
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

entity pdm_output is
  port(
    clk      : in  std_logic;           -- 100 MHz
    data_in  : in  unsigned(6 downto 0);
    data_out : out std_logic := '0'
  );
end entity pdm_output;

architecture rtl of pdm_output is

  signal error : unsigned(6 downto 0) := (others => '0');

begin

  process(clk)
  begin
    if rising_edge(clk) then
      if data_in >= error then
        data_out <= '1';
        error    <= error + 127 - data_in;
      else
        data_out <= '0';
        error    <= error - data_in;
      end if;
    end if;
  end process;
end architecture;
