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
    signal temp_greater  : std_logic;
    signal temp_smaller  : std_logic;
    signal temp_OVERFLOW : std_logic;

begin

    process (A, B, CMD)

    variable sum_sub_res : unsigned(8 downto 0); -- 9 bits p/ ADD/SUB
begin
    -- valores-padrão para evitar latch
    temp_R        <= (others => '0');
    temp_overflow <= '0';

    case CMD is

        -- Operadores aritméticos
        when "0000" => -- ADD
            sum_sub_res := ("0" & A) + ("0" & B);
            temp_R        <= sum_sub_res(7 downto 0);
            temp_overflow <= sum_sub_res(8);

        when "0001" => -- SUB
            sum_sub_res := ("0" & A) - ("0" & B);
            temp_R        <= sum_sub_res(7 downto 0);
            temp_overflow <= sum_sub_res(8);

		  when "0010" =>
            case B(1 downto 0) is
                when "00" =>                     -- INC  (Rx ← Rx + 1)
                    temp_R        <= A + 1;
				    if A = "11111111" then
                        temp_overflow <= '1';
                    else
                        temp_overflow <= '0';
                    end if;

                when "01" =>                     -- DEC  (Rx ← Rx - 1)
                    temp_R        <= A - 1;
                    if A = "00000000" then
                        temp_overflow <= '1';
                    else
                        temp_overflow <= '0';
                    end if;

                when others =>
                    temp_R        <= (others => '0');
                    temp_overflow <= '0';
            end case;

        -- Operadores lógicos
        when "0011" => -- AND
            temp_R <= A and B;

        when "0100" => -- OR
            temp_R <= A or B;

        when "0101" => -- NOT
            temp_R <= not A;

        when "0110" => -- XOR
            temp_R <= A xor B;

        when "0111" => -- ROL/ROR/LSL/LSR
            case B(1 downto 0) is
                when "00" => -- ROL
                    temp_R <= A(6 downto 0) & A(7);
                when "01" => -- ROR
                    temp_R <= A(0) & A(7 downto 1);
                when "10" => -- LSL
                    temp_R <= A(6 downto 0) & '0';
                when "11" => -- LSR
                    temp_R <= '0' & A(7 downto 1);
                when others =>
                    temp_R <= (others => '0');
            end case;

        when others =>
            temp_R        <= (others => '0');
            temp_overflow <= '0';
    end case;
end process;

	R <= temp_R;
    ZERO     <= '1' when temp_R = 0   else '0';
    NEGATIVE <= temp_R(7);
    GREATER <= '1' when (A > B) and (temp_overflow = '0') else '0';
	SMALLER <= '1' when (A < B) and (temp_overflow = '0') else '0';
	EQUAL   <= '1' when (A = B) and (temp_overflow = '0') else '0';

    OVERFLOW <= temp_overflow;

end Behavioral;
