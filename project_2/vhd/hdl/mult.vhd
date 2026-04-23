----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 16:24:46
-- Design Name: 
-- Module Name: mult - Behavioral
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

entity mult is
  generic(
    BITS : integer := 16
  );
  port(
    SW  : in  std_logic_vector(BITS - 1 downto 0);
    LED : out std_logic_vector(BITS - 1 downto 0)
  );
end entity mult;

architecture rtl of mult is
begin

  multipler : process(all)
    variable a_in   : signed(BITS / 2 - 1 downto 0);
    variable b_in   : signed(BITS / 2 - 1 downto 0);
    variable result : signed(BITS - 1 downto 0);
  begin
    a_in   := signed(SW(BITS - 1 downto BITS / 2));
    b_in   := signed(SW(BITS / 2 - 1 downto 0));
    result := a_in * b_in;
    LED    <= std_logic_vector(result);
  end process multipler;

end architecture rtl;
