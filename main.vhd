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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
	port(
			CLK 							: in  STD_LOGIC;
			RESET							: in  STD_LOGIC;
			LCD_E, LCD_RS, LCD_RW 	: out STD_LOGIC;
			SF_CE0 						: out STD_LOGIC;
			LEDS							: out STD_LOGIC_VECTOR(7 downto 0);
			DOUT_LCD						: out STD_LOGIC_VECTOR(3 downto 0)
		);
end main;

architecture Behavioral of main is

	 signal ram_addr : std_logic_vector(7 downto 0);
    signal ram_din  : std_logic_vector(7 downto 0);
    signal ram_dout : std_logic_vector(7 downto 0);
    signal ram_we   : std_logic;
	 signal pos255   : std_logic_vector(7 downto 0);
	 
begin

	U_CPU : entity work.CPU
			  port map (
					CLK      => clk,
					RESET    => reset,
					RAM_ADDR => ram_addr,
					RAM_DIN  => ram_din,
					RAM_DOUT => ram_dout,
					RAM_WE   => ram_we
			  );
			  
			  
			  
   U_MEM : entity work.memory
        port map (
            CLK     => clk,
            DIN     => ram_din,
            ADDR    => ram_addr,
            WE      => ram_we,
            DOUT    => ram_dout,
            POS_255 => pos255     
        );


end Behavioral;

