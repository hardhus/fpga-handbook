----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 19:18:57
-- Design Name: 
-- Module Name: cathode_top - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cathode_top is
  port(
    clk         : in  std_logic;
    encoded     : in  std_logic_vector(3 downto 0);
    digit_point : in  std_logic;
    cathode     : out std_logic_vector(7 downto 0)
  );
end entity cathode_top;

architecture rtl of cathode_top is

  signal dp_reg      : std_logic                    := '0';
  signal cathode_reg : std_logic_vector(6 downto 0) := (others => '0');

begin

process(clk)
  begin
    if rising_edge(clk) then
      dp_reg <= digit_point;
      case encoded is
        when x"0"   => cathode_reg <= "1000000";
        when x"1"   => cathode_reg <= "1111001";
        when x"2"   => cathode_reg <= "0100100";
        when x"3"   => cathode_reg <= "0110000";
        when x"4"   => cathode_reg <= "0011001";
        when x"5"   => cathode_reg <= "0010010";
        when x"6"   => cathode_reg <= "0000010";
        when x"7"   => cathode_reg <= "1111000";
        when x"8"   => cathode_reg <= "0000000";
        when x"9"   => cathode_reg <= "0010000";
        when x"A"   => cathode_reg <= "0001000";
        when x"B"   => cathode_reg <= "0000011";
        when x"C"   => cathode_reg <= "1000110";
        when x"D"   => cathode_reg <= "0100001";
        when x"E"   => cathode_reg <= "0000110";
        when x"F"   => cathode_reg <= "0001110";
        when others => cathode_reg <= "0001110";
      end case;
    end if;
  end process;

  cathode <= dp_reg & cathode_reg;

end architecture;
