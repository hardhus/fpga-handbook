----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.05.2026 17:47:05
-- Design Name: 
-- Module Name: adt7420_mdl - Behavioral
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

entity adt7420_mdl is
    generic(
        I2C_ADDR : std_logic_vector(6 downto 0) := 7x"4B"
    );
    port(
        temp : in    std_logic_vector(15 downto 0); -- the temperature to read out
        --
        scl  : in    std_logic;
        sda  : inout std_logic
    );
end entity adt7420_mdl;

architecture mdl of adt7420_mdl is

begin

    i2c : process is
        variable addr : std_logic_vector(6 downto 0);
        variable rnw  : std_logic;
    begin
        sda <= 'Z';

        -- Wait for START condition
        wait on sda until sda'event and sda = '0' and to_01(scl) = '1';
        report "I2C START";

        -- Receive device address
        for i in addr'high downto addr'low loop
            wait until rising_edge(scl);
            addr(i) := to_01(sda);
        end loop;
        report "addr = " & to_hstring(addr);
        assert addr = I2C_ADDR report "unexpected I2C address: " & to_hstring(addr) severity error;

        -- Receive R/W flag
        wait until rising_edge(scl);
        rnw := to_01(sda);
        assert rnw = '1' report "unexpected RNW" severity error;

        -- Transmit slave ACK
        wait until falling_edge(scl);
        sda <= '0';

        -- Transmit TEMP high byte
        for i in 15 downto 8 loop
            wait until falling_edge(scl);
            sda <= '0' when temp(i) = '0' else 'Z';
        end loop;

        -- Receive master ACK
        wait until falling_edge(scl);
        sda <= 'Z';
        wait until rising_edge(scl);
        assert sda = '0' report "expected ACK by master" severity error;

        -- Transmit TEMP low byte
        for i in 7 downto 0 loop
            wait until falling_edge(scl);
            sda <= '0' when temp(i) = '0' else 'X' when temp(i) = 'X' else 'Z';
        end loop;

        -- Receive master NO ACK
        wait until falling_edge(scl);
        sda <= 'Z';
        wait until rising_edge(scl);
        assert to_01(sda) = '1' report "expected NO ACK by master" severity error;
        
        -- Wait for STOP condition
        wait on sda until sda'event and to_01(sda) = '1' and to_01(scl) = '1';
        report "I2C STOP";

    end process i2c;

end architecture mdl;
