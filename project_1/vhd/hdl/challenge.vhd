----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.04.2026 20:03:51
-- Design Name: 
-- Module Name: challenge - Behavioral
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

entity challenge is
  port(
    SW  : in  std_logic_vector(2 downto 0);
    LED : out std_logic_vector(1 downto 0)
  );
end entity challenge;

architecture rtl of challenge is
begin
  LED(0) <= SW(1) xor SW(0) xor SW(2);
  LED(1) <= (SW(1) and SW(0)) or ((SW(1) xor SW(0)) and SW(2));

end architecture rtl;

