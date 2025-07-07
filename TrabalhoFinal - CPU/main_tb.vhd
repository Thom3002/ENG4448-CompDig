-- main_tb.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_tb is
end main_tb;

architecture Behavioral of main_tb is

    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';

    signal lcd_e     : std_logic;
    signal lcd_rs    : std_logic;
    signal lcd_rw    : std_logic;
    signal sf_ce0    : std_logic;
    signal leds      : std_logic_vector(7 downto 0);
    signal lcd_data  : std_logic_vector(3 downto 0);

    -- signals to connect CPU and memory
    signal ram_addr  : std_logic_vector(7 downto 0);
    signal ram_din   : std_logic_vector(7 downto 0);
    signal ram_dout  : std_logic_vector(7 downto 0);
    signal ram_we    : std_logic;
    signal pos255    : std_logic_vector(7 downto 0);

    constant CLK_PERIOD : time := 2 sec;  -- Clock period set to 2 seconds (0.5 Hz)

begin

    -- Clock generation: 0.5 Hz to have 2s per clock cycle
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Reset process: reset active high for initial 4 seconds, then released
    reset_process : process
    begin
        reset <= '1';
        wait for 4 sec;
        reset <= '0';
        wait;
    end process;

    -- Instantiate main (which instantiates CPU and memory)
    uut: entity work.main
        port map (
            CLK     => clk,
            RESET   => reset,
            LCD_E   => lcd_e,
            LCD_RS  => lcd_rs,
            LCD_RW  => lcd_rw,
            SF_CE0  => sf_ce0,
            LEDS    => leds,
            lcd_data=> lcd_data
        );

    -- Connect signals between CPU and memory
    -- The main.vhd architecture handles these internally, but to be safe:
    -- ram signals inside main are internal, so no need to connect here.

    -- Optionally, add a monitor process to print PC, IR, registers or outputs here,
    -- if CPU exposes signals for debugging (not shown in your code)

end Behavioral;
