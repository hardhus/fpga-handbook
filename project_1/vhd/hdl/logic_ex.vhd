----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.04.2026 19:06:38
-- Design Name: 
-- Module Name: logic_ex - Behavioral
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

entity logic_ex is
port(
    SW  : in  std_logic_vector(1 downto 0);
    LED : out std_logic_vector(3 downto 0)
    );
end logic_ex;

architecture rtl of logic_ex is
begin
    LED(0) <= not SW(0);
    LED(1) <= SW(1) and SW(0);
    LED(2) <= SW(1) or SW(0);
    LED(3) <= SW(1) xor SW(0);
end architecture rtl;
