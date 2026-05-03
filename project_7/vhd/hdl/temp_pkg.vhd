----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.05.2026 17:44:10
-- Design Name: 
-- Module Name: temp_pkg - Behavioral
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
 
use work.counting_buttons_pkg.ALL;

package temp_pkg is

  constant NUM_SEGMENTS : integer := 8;
  function bin_to_bcd(bin_in : in std_logic_vector(31 downto 0)) return array_t;

end package temp_pkg;

package body temp_pkg is

  function bin_to_bcd(bin_in : in std_logic_vector(31 downto 0)) return array_t is
    variable shifted : unsigned(NUM_SEGMENTS * 4 - 1 downto 0);
    variable bin2bcd : array_t(NUM_SEGMENTS -1 downto 0)(3 downto 0);
  begin

    shifted             := (others => '0');
    shifted(1 downto 0) := unsigned(bin_in(31 downto 30));
    for i in 29 downto 1 loop
      shifted := shifted(30 downto 0) & bin_in(i);
      for j in 0 to NUM_SEGMENTS - 1 loop
        if shifted(j * 4 + 3 downto j * 4) > 4 then
          shifted(j * 4 + 3 downto j * 4) := shifted(j * 4 + 3 downto j * 4) + 3;
        end if;
      end loop;
    end loop;
    shifted             := shifted(30 downto 0) & bin_in(0);
    for i in 0 to NUM_SEGMENTS - 1 loop
      bin2bcd(i) := std_logic_vector(shifted(4 * i + 3 downto 4 * i));
    end loop;
    return bin2bcd;    
  end function bin_to_bcd;

end package body temp_pkg;
