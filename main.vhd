----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:27:39 07/04/2025 
-- Design Name: 
-- Module Name:    main - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all

entity main is
	port(
			CLK 							: in  STD_LOGIC;
			RESET							: in  STD_LOGIC;
			LCD_E, LCD_RS, LCD_RW 	: out STD_LOGIC;
			SF_CE0 						: out STD_LOGIC;
			LEDS							: out STD_LOGIC_VECTOR(7 downto 0);
			LCD_DATA						: out STD_LOGIC_VECTOR(3 downto 0)
		);
end main;

architecture Behavioral of main is

	 signal ram_addr : std_logic_vector(7 downto 0);
    signal ram_din  : std_logic_vector(7 downto 0);
    signal ram_dout : std_logic_vector(7 downto 0);
    signal ram_we   : std_logic;
	 signal pos255   : std_logic_vector(7 downto 0);
     -- LCD signals
   SIGNAL lcd_rs_s: STD_LOGIC;
   SIGNAL lcd_rw_s: STD_LOGIC;
   SIGNAL lcd_e_s: STD_LOGIC;
   SIGNAL lcd_data_s: STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL sf_ce0_s: STD_LOGIC;
   signal init_done : std_logic;
   
   signal clk_slow : std_logic := '0';
    signal div_cnt   : unsigned(26 downto 0) := (others => '0'); 
	 
begin

    process (CLK, RESET)
    begin
        if RESET = '1' then
            div_cnt   <= (others => '0');
            clk_slow <= '0';
        elsif rising_edge(CLK) then             -- CLK = 50 MHz
            if div_cnt = 25_000_000 then        -- 2 s / 20 ns - 1
                div_cnt   <= (others => '0');   -- reinicia
                clk_slow <= not clk_slow;     -- alterna (T = 2 s)
            else
                div_cnt <= div_cnt + 1;
            end if;
        end if;
    end process;
    
	U_CPU : entity work.CPU
			  port map (
					CLK      => clk_slow,
					RESET    => reset,
					RAM_ADDR => ram_addr,
					RAM_DIN  => ram_din,
					RAM_DOUT => ram_dout,
					RAM_WE   => ram_we
			  );
			  
			  
			  
   U_MEM : entity work.memory
        port map (
            CLK     => clk_slow,
            DIN     => ram_din,
            ADDR    => ram_addr,
            WE      => ram_we,
            DOUT    => ram_dout,
            POS_255 => pos255     
        );
        
    -- LCD
    U_LCD : ENTITY work.lcd
        PORT MAP(
            clk => CLK,
            reset => RESET,
            lcd_rs => lcd_rs_s,
            lcd_rw => lcd_rw_s,
            lcd_e => lcd_e_s,
            lcd_data => lcd_data_s,
            SF_CE0 => sf_ce0_s,
            ir_data => ram_dout,
            memory_data => pos255
            
        );
        
    LCD_E     <= lcd_e_s;
   LCD_RS    <= lcd_rs_s;
   LCD_RW    <= lcd_rw_s;
   SF_CE0    <= sf_ce0_s;
   LCD_DATA  <= lcd_data_s; 


end Behavioral;

