----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.04.2026 19:11:31
-- Design Name: 
-- Module Name: tb - Behavioral
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

entity tb is
end entity tb;

architecture tb of tb is
    signal SW: std_logic_vector(1 downto 0);
    signal LED: std_logic_vector(3 downto 0);
begin

    u_logic_ex : entity work.logic_ex
    port map(
      SW  => SW,
      LED => LED
    );

  initial : process
  begin
    SW <= "00";
    for i in 0 to 3 loop
      SW <= std_logic_vector(to_unsigned(i, SW'length));
      report "setting SW to " & to_string(to_unsigned(i, SW'length));
      wait for 100 ns;
    end loop;
    report "PASS: logic_ex test PASSED!";
    std.env.stop;
    wait;
  end process initial;

  checking : process
  begin
    wait until LED'event;
    if not SW(0) /= LED(0) then
      report "FAIL: NOT Gate mismatch" severity failure;
    end if;
    if and SW /= LED(1) then
      report to_string(and SW);
      report "FAIL: AND Gate mismatch" severity failure;
    end if;
    if or SW /= LED(2) then
      report "FAIL: OR Gate mismatch" severity failure;
    end if;
    if xor SW /= LED(3) then
      report "FAIL: XOR Gate mismatch" severity failure;
    end if;
  end process checking;

end architecture tb;
