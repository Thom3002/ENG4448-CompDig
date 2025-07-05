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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
    port (
        A        : in  unsigned(7 downto 0);
        B        : in  unsigned(7 downto 0);
        CMD      : in  std_logic_vector(3 downto 0);
        R        : out unsigned(7 downto 0);
        ZERO     : out std_logic;
        NEGATIVE : out std_logic;
        OVERFLOW : out std_logic;
        EQUAL    : out std_logic;
        GREATER  : out std_logic;
        SMALLER  : out std_logic
    );
end alu;

architecture Behavioral of alu is
    -- signals
    signal temp_R : unsigned(7 downto 0);
    signal temp_OVERFLOW : std_logic;
begin

    process (A, B, CMD)

    variable sum_sub_res : unsigned(8 downto 0); -- 9 bits to handle overflow in addition/subtraction
    begin

        -- default values to avoid latches
        temp_R := (others => '0');
        ZERO     <= '0';
        NEGATIVE <= '0';
        OVERFLOW <= '0';
        EQUAL    <= '0';
        GREATER  <= '0';
        SMALLER  <= '0';
        temp_OVERFLOW <= '0';

        case CMD is
            when "0000" => -- ADD
                sum_sub_res := ("0" & A) + ("0" & B); -- Faz a conta com 9 bits para evitar overflow
                temp_R <= sum_sub_res(7 downto 0);
                temp_OVERFLOW <= sum_sub_res(8);

            when "0001" => -- SUB
                sum_sub_res := ("0" & A) - ("0" & B);
                temp_R <= sum_sub_res(7 downto 0);
                temp_OVERFLOW <= sum_sub_res(8);

            -- when "0010" => -- AND
            --     temp_R <= A and B;  -- AND
            --     temp_OVERFLOW <= '0';
            -- when "0011" => -- OR
            --     temp_R <= A or B;  -- OR
            --     temp_OVERFLOW <= '0';

            -- when "0100" => temp_R <= not A;    -- NOT
            when others =>
                temp_R <= (others => '0');
                temp_OVERFLOW <= '0';
        end case;

        R <= temp_R;
        OVERFLOW <= temp_OVERFLOW;

    end process;

end Behavioral;
