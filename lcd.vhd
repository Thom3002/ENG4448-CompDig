----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:36:11 05/26/2025 
-- Design Name: 
-- Module Name:    lcd- Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

entity lcd is
    Port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        lcd_rs     : out std_logic;
        lcd_rw     : out std_logic;
        lcd_e      : out std_logic;
        lcd_data   : out std_logic_vector(3 downto 0);
        SF_CE0     : out std_logic;
        ir_data    : in std_logic_vector(7 downto 0);
        memory_data: in std_logic_vector(7 downto 0)
    );
end lcd;

architecture Behavioral of lcd is
    signal init_done : std_logic;
    signal char_data : std_logic_vector(7 downto 0);
    signal write_en  : std_logic;
    signal lcd_rs_init, lcd_rw_init, lcd_e_init : std_logic;
    signal lcd_rs_write, lcd_rw_write, lcd_e_write : std_logic;  
    signal lcd_data_init : std_logic_vector(3 downto 0);
    signal lcd_data_write : std_logic_vector(3 downto 0);
begin

    -- desativa Strata Flash
    SF_CE0 <= '1';

    U1: entity work.lcd_init
        port map (
            clk         => clk,
            reset       => reset,
            lcd_rs      => lcd_rs_init,
            lcd_rw      => lcd_rw_init,
            lcd_e       => lcd_e_init,
            lcd_data    => lcd_data_init,
            init_done   => init_done
        );

    U2: entity work.lcd_write
        port map (
            clk         => clk,
            reset       => reset,
            init_done   => init_done,
            lcd_rs      => lcd_rs_write,
            lcd_rw      => lcd_rw_write,
            lcd_e       => lcd_e_write,
            lcd_data    => lcd_data_write,
            ir_data     => ir_data,
            memory_data => memory_data
        );

    lcd_data <= lcd_data_write when init_done = '1' 
                else lcd_data_init ;
    lcd_rs <= lcd_rs_write when init_done = '1' 
                else lcd_rs_init ;
    lcd_rw <= lcd_rw_write when init_done = '1' 
                else lcd_rw_init ;
    lcd_e <= lcd_e_write when init_done = '1' 
                else lcd_e_init ;

end Behavioral;

