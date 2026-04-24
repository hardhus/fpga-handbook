----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 24.04.2026 20:19:25
-- Design Name: 
-- Module Name: calculator_pkg - Behavioral
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

use work.counting_buttons_pkg.ALL; -- array_t

PACKAGE calculator_pkg IS

  constant NUM_SEGMENTS : integer := 8;
  constant UP           : natural := 0;
  constant DOWN         : natural := 1;
  constant LEFT         : natural := 2;
  constant RIGHT        : natural := 3;
  constant CENTER       : natural := 4;

  function bin_to_bcd(bin_in : in std_logic_vector(31 downto 0)) return array_t;

end package calculator_pkg;

package body calculator_pkg is

  function bin_to_bcd(bin_in : in std_logic_vector(31 downto 0)) return array_t is
    variable shifted : std_logic_vector(NUM_SEGMENTS * 4 - 1 downto 0);
    variable bin2bcd : array_t(NUM_SEGMENTS - 1 downto 0)(3 downto 0);
    variable digit   : unsigned(3 downto 0);
  begin
    shifted             := (others => '0');
    shifted(1 downto 0) := bin_in(31 downto 30);
    for i in 29 downto 1 loop
      shifted := shifted(30 downto 0) & bin_in(i);
      for j in 0 to NUM_SEGMENTS - 1 loop
        digit := unsigned(shifted(j * 4 + 3 downto j * 4));
        if digit > 4 then
          shifted(j * 4 + 3 downto j * 4) := std_logic_vector(digit + 3);
        end if;
      end loop;
    end loop;
    shifted             := shifted(30 downto 0) & bin_in(0);
    for i in 0 to NUM_SEGMENTS - 1 loop
      bin2bcd(i) := shifted(4 * i + 3 downto 4 * i);
    end loop;
    return bin2bcd;
  end function bin_to_bcd;

end package body calculator_pkg;
