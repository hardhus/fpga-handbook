----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 19:25:35
-- Design Name: 
-- Module Name: seven_segment - Behavioral
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
use IEEE.math_real.ALL;
use WORK.counting_buttons_pkg.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seven_segment is
  generic(
    NUM_SEGMENTS : integer := 8;
    CLK_PER      : integer := 10;       
    REFR_RATE    : integer := 1000      
  );
  port(
    clk         : in  std_logic;
    reset       : in  std_logic;        
    encoded     : in  array_t(NUM_SEGMENTS - 1 downto 0)(3 downto 0);
    digit_point : in  std_logic_vector(NUM_SEGMENTS - 1 downto 0);
    anode       : out std_logic_vector(NUM_SEGMENTS - 1 downto 0);
    cathode     : out std_logic_vector(7 downto 0)
  );
end entity seven_segment;

architecture rtl of seven_segment is

constant INTERVAL : natural := 1000000000 / (CLK_PER * REFR_RATE);

  signal refresh_count : integer range 0 to INTERVAL         := 0;
  signal anode_count   : integer range 0 to NUM_SEGMENTS - 1 := 0;
  signal segments      : array_t(NUM_SEGMENTS - 1 downto 0)(7 downto 0);

begin

  g_genarray : for i in 0 to NUM_SEGMENTS - 1 generate
    ct : entity work.cathode_top
      port map(
        clk         => clk,
        encoded     => encoded(i),
        digit_point => digit_point(i),
        cathode     => segments(i)
      );
  end generate;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset then
        refresh_count <= 0;
        anode_count   <= 0;
      else
        if refresh_count = INTERVAL then
          refresh_count <= 0;
          if anode_count = NUM_SEGMENTS - 1 then
            anode_count <= 0;
          else
            anode_count <= anode_count + 1;
          end if;
        else
          refresh_count <= refresh_count + 1;
        end if;
        anode              <= (others => '1');
        anode(anode_count) <= '0';
        cathode            <= segments(anode_count);
      end if;
    end if;
  end process;

end architecture rtl;
