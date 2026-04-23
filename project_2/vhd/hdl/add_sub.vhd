----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 16:24:46
-- Design Name: 
-- Module Name: add_sub - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity add_sub is
  generic(
    SELECTOR : string  := "";
    BITS     : integer := 16
  );
  port(
    SW  : in  std_logic_vector(BITS - 1 downto 0);
    LED : out std_logic_vector(BITS - 1 downto 0)
  );
end entity add_sub;

architecture rtl of add_sub is
begin

  adder : process(all)
    variable a_in   : signed(BITS - 1 downto 0);
    variable b_in   : signed(BITS - 1 downto 0);
    variable result : signed(BITS - 1 downto 0);
  begin
    a_in := resize(signed(SW(BITS - 1 downto BITS / 2)), BITS);
    b_in := resize(signed(SW(BITS / 2 - 1 downto 0)), BITS);

    if (SELECTOR = "ADD") then
      result := a_in + b_in;
    else
      result := a_in - b_in;
    end if;
    LED <= std_logic_vector(result);
  end process adder;

end architecture rtl;
