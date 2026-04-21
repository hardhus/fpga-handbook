----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.04.2026 20:05:26
-- Design Name: 
-- Module Name: tb_challenge - Behavioral
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

entity tb_challenge is
end entity tb_challenge;

architecture test of tb_challenge is

  -- Define the signals
  signal SW  : std_logic_vector(2 downto 0);
  signal LED : std_logic_vector(1 downto 0);

begin

  -- Instantiate the module to be tested
  u_challenge : entity work.challenge
    port map(
      SW  => SW,
      LED => LED
    );

  -- Stimulus
  -- Equivalent to the initial block in SV
  initial : process
  begin
    SW <= "000";
    for i in 0 to 7 loop
      SW <= std_logic_vector(to_unsigned(i, SW'length));
      report "setting SW to " & to_string(to_unsigned(i, SW'length));
      wait for 100 ns;
    end loop;
    report "PASS: logic_ex test PASSED!";
    std.env.stop;
  end process initial;

  -- Checking
  checking : process
    variable SUM : unsigned(1 downto 0);
  begin
    wait until SW'event;
    SUM := 2d"0";
    for i in SW'range loop
      SUM := SUM + unsigned(unsigned'("0") & SW(i));
    end loop;
    wait for 1 ps;                      -- wait for LED to update
    assert SUM = unsigned(LED) report "FAIL: Addition mismatch" severity failure;
  end process checking;

end architecture test;

