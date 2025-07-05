----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:51:43 07/04/2025 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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

entity alu is
    generic (
        N : positive := 8                    -- largura
    );
    port (
        A        : in  unsigned(N-1 downto 0);
        B        : in  unsigned(N-1 downto 0);
        CMD      : in  std_logic_vector(3 downto 0);
        R        : out unsigned(N-1 downto 0);
        ZERO     : out std_logic;
        NEGATIVE : out std_logic;
        OVERFLOW : out std_logic;
        EQUAL    : out std_logic;
        GREATER  : out std_logic;
        SMALLER  : out std_logic
    );
end alu;

architecture Behavioral of alu is

begin


end Behavioral;

