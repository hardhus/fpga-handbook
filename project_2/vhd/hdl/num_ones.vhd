----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 16:24:46
-- Design Name: 
-- Module Name: num_ones - Behavioral
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
use IEEE.numeric_std.all;
use IEEE.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity num_ones is
  generic(
    BITS : integer := 16
  );
  port(
    SW  : in  std_logic_vector(BITS - 1 downto 0);
    LED : out std_logic_vector(natural(ceil(log2(real(BITS)))) downto 0)
  );
end entity num_ones;

architecture rtl of num_ones is
begin

  counter : process(all)
    variable count : natural range 0 to BITS;
  begin
    count := 0;
    for i in SW'range loop
      if SW(i) then
        count := count + 1;
      end if;
    end loop;
    LED   <= std_logic_vector(to_unsigned(count, LED'length));
  end process counter;

end architecture rtl;
