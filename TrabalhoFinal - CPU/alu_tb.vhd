--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   16:44:12 07/05/2025
-- Design Name:
-- Module Name:   alu_tb - Behavioral
-- Project Name:  TrabalhoFinal
-- Target Device:
-- Tool versions:
-- Description:   Testbench para a ALU (assíncrona) - Foco em operadores aritméticos
--
-- Dependencies:  alu.vhd
--
-- Revision:
-- Revision 0.01 - File Created, adapted for arithmetic tests
--
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL; -- ESSENCIAL: para lidar com unsigned em A, B, R

ENTITY alu_tb IS
END alu_tb;

ARCHITECTURE behavior OF alu_tb IS

    -- Component Declaration for the Unit Under Test (ALU)
    COMPONENT alu
        PORT(
            A        : IN  unsigned(7 downto 0);
            B        : IN  unsigned(7 downto 0);
            CMD      : IN  std_logic_vector(3 downto 0);
            R        : OUT unsigned(7 downto 0);
            ZERO     : OUT std_logic;
            NEGATIVE : OUT std_logic;
            OVERFLOW : OUT std_logic;
            EQUAL    : OUT std_logic;
            GREATER  : OUT std_logic;
            SMALLER  : OUT std_logic
        );
    END COMPONENT;

    -- Sinais de INPUT para a ALU
    signal A_s   : unsigned(7 downto 0) := (others => '0');
    signal B_s   : unsigned(7 downto 0) := (others => '0');
    signal CMD_s : std_logic_vector(3 downto 0) := (others => '0');

    -- Sinais de OUTPUT da ALU
    signal R_s        : unsigned(7 downto 0);
    signal ZERO_s     : std_logic;
    signal NEGATIVE_s : std_logic;
    signal OVERFLOW_s : std_logic;
    signal EQUAL_s    : std_logic;
    signal GREATER_s  : std_logic;
    signal SMALLER_s  : std_logic;

    -- Período de espera para estabilização da lógica combinacional
    constant PROPAGATION_DELAY : time := 10 ns;

BEGIN
    -- Instantiate the Unit Under Test (ALU)
    uut: alu PORT MAP (
          A        => A_s,
          B        => B_s,
          CMD      => CMD_s,
          R        => R_s,
          ZERO     => ZERO_s,
          NEGATIVE => NEGATIVE_s,
          OVERFLOW => OVERFLOW_s,
          EQUAL    => EQUAL_s,
          GREATER  => GREATER_s,
          SMALLER  => SMALLER_s
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Inicialização
        A_s <= to_unsigned(0, 8);
        B_s <= to_unsigned(0, 8);
        CMD_s <= "0000"; -- Default para ADD
        WAIT FOR PROPAGATION_DELAY;
        WAIT FOR 0 ns; -- Adicionado: Espera por 1 delta cycle para que os sinais de saída atualizem

        REPORT "--- Teste de Operacoes Aritmeticas da ALU ---" SEVERITY NOTE;

        -- Teste 1: ADD (5 + 3 = 8)
        REPORT "Teste 1: ADD (5 + 3 = 8)" SEVERITY NOTE;
        A_s <= to_unsigned(5, 8);
        B_s <= to_unsigned(3, 8);
        CMD_s <= "0000"; -- ADD
        WAIT FOR PROPAGATION_DELAY;
        WAIT FOR 0 ns; -- Adicionado
        ASSERT R_s = to_unsigned(8, 8) REPORT "T1: ADD - Resultado incorreto" SEVERITY ERROR;
        ASSERT ZERO_s = '0' REPORT "T1: ADD - ZERO flag incorreta" SEVERITY ERROR;
        ASSERT OVERFLOW_s = '0' REPORT "T1: ADD - OVERFLOW flag incorreta" SEVERITY ERROR;
        ASSERT NEGATIVE_s = '0' REPORT "T1: ADD - NEGATIVE flag incorreta" SEVERITY ERROR;
        ASSERT EQUAL_s = '0' REPORT "T1: ADD - EQUAL flag incorreta" SEVERITY ERROR;
        ASSERT GREATER_s = '1' REPORT "T1: ADD - GREATER flag incorreta" SEVERITY ERROR;
        ASSERT SMALLER_s = '0' REPORT "T1: ADD - SMALLER flag incorreta" SEVERITY ERROR;

        -- Teste 2: SUB (10 - 4 = 6)
        REPORT "Teste 2: SUB (10 - 4 = 6)" SEVERITY NOTE;
        A_s <= to_unsigned(10, 8);
        B_s <= to_unsigned(4, 8);
        CMD_s <= "0001"; -- SUB
        WAIT FOR PROPAGATION_DELAY;
        WAIT FOR 0 ns; -- Adicionado
        ASSERT R_s = to_unsigned(6, 8) REPORT "T2: SUB - Resultado incorreto" SEVERITY ERROR;
        ASSERT ZERO_s = '0' REPORT "T2: SUB - ZERO flag incorreta" SEVERITY ERROR;
        ASSERT OVERFLOW_s = '0' REPORT "T2: SUB - OVERFLOW flag incorreta" SEVERITY ERROR;
        ASSERT NEGATIVE_s = '0' REPORT "T2: SUB - NEGATIVE flag incorreta" SEVERITY ERROR;
        ASSERT EQUAL_s = '0' REPORT "T2: SUB - EQUAL flag incorreta" SEVERITY ERROR;
        ASSERT GREATER_s = '1' REPORT "T2: SUB - GREATER flag incorreta" SEVERITY ERROR;
        ASSERT SMALLER_s = '0' REPORT "T2: SUB - SMALLER flag incorreta" SEVERITY ERROR;

        -- Teste 3: ADD (0 + 0 = 0) - Teste de ZERO flag
        REPORT "Teste 3: ADD (0 + 0 = 0) - ZERO flag" SEVERITY NOTE;
        A_s <= to_unsigned(0, 8);
        B_s <= to_unsigned(0, 8);
        CMD_s <= "0000"; -- ADD
        WAIT FOR PROPAGATION_DELAY;
        WAIT FOR 0 ns; -- Adicionado
        ASSERT R_s = to_unsigned(0, 8) REPORT "T3: ADD Zero - Resultado incorreto" SEVERITY ERROR;
        ASSERT ZERO_s = '1' REPORT "T3: ADD Zero - ZERO flag incorreta" SEVERITY ERROR;
        ASSERT OVERFLOW_s = '0' REPORT "T3: ADD Zero - OVERFLOW flag incorreta" SEVERITY ERROR;
        ASSERT NEGATIVE_s = '0' REPORT "T3: ADD Zero - NEGATIVE flag incorreta" SEVERITY ERROR;
        ASSERT EQUAL_s = '1' REPORT "T3: ADD Zero - EQUAL flag incorreta" SEVERITY ERROR;
        ASSERT GREATER_s = '0' REPORT "T3: ADD Zero - GREATER flag incorreta" SEVERITY ERROR;
        ASSERT SMALLER_s = '0' REPORT "T3: ADD Zero - SMALLER flag incorreta" SEVERITY ERROR;

        -- Teste 4: SUB (5 - 5 = 0) - Teste de ZERO flag e EQUAL flag
        REPORT "Teste 4: SUB (5 - 5 = 0) - ZERO/EQUAL flags" SEVERITY NOTE;
        A_s <= to_unsigned(5, 8);
        B_s <= to_unsigned(5, 8);
        CMD_s <= "0001"; -- SUB
        WAIT FOR PROPAGATION_DELAY;
        WAIT FOR 0 ns; -- Adicionado
        ASSERT R_s = to_unsigned(0, 8) REPORT "T4: SUB Zero - Resultado incorreto" SEVERITY ERROR;
        ASSERT ZERO_s = '1' REPORT "T4: SUB Zero - ZERO flag incorreta" SEVERITY ERROR;
        ASSERT OVERFLOW_s = '0' REPORT "T4: SUB Zero - OVERFLOW flag incorreta" SEVERITY ERROR;
        ASSERT NEGATIVE_s = '0' REPORT "T4: SUB Zero - NEGATIVE flag incorreta" SEVERITY ERROR;
        ASSERT EQUAL_s = '1' REPORT "T4: SUB Zero - EQUAL flag incorreta" SEVERITY ERROR;
        ASSERT GREATER_s = '0' REPORT "T4: SUB Zero - GREATER flag incorreta" SEVERITY ERROR;
        ASSERT SMALLER_s = '0' REPORT "T4: SUB Zero - SMALLER flag incorreta" SEVERITY ERROR;

        -- Teste 5: ADD (200 + 100 = 44) - Teste de OVERFLOW (unsigned)
        REPORT "Teste 5: ADD (200 + 100 = 44) - OVERFLOW" SEVERITY NOTE;
        A_s <= to_unsigned(200, 8);
        B_s <= to_unsigned(100, 8);
        CMD_s <= "0000"; -- ADD
        WAIT FOR PROPAGATION_DELAY;
        WAIT FOR 0 ns; -- Adicionado
        -- 200 + 100 = 300. Em 8 bits unsigned (max 255): 300 mod 256 = 44.
        ASSERT R_s = to_unsigned(44, 8) REPORT "T5: ADD Overflow - Resultado incorreto" SEVERITY ERROR;
        ASSERT ZERO_s = '0' REPORT "T5: ADD Overflow - ZERO flag incorreta" SEVERITY ERROR;
        ASSERT OVERFLOW_s = '1' REPORT "T5: ADD Overflow - OVERFLOW flag incorreta" SEVERITY ERROR;
        ASSERT NEGATIVE_s = '0' REPORT "T5: ADD Overflow - NEGATIVE flag incorreta" SEVERITY ERROR; -- 44 é < 128
        ASSERT EQUAL_s = '0' REPORT "T5: ADD Overflow - EQUAL flag incorreta" SEVERITY ERROR;
        ASSERT GREATER_s = '0' REPORT "T5: ADD Overflow - GREATER flag incorreta" SEVERITY ERROR;
        ASSERT SMALLER_s = '0' REPORT "T5: ADD Overflow - SMALLER flag incorreta" SEVERITY ERROR;

        -- Teste 6: SUB (5 - 10 = 251) - Teste de UNDERFLOW / OVERFLOW (unsigned)
        REPORT "Teste 6: SUB (5 - 10 = 251) - UNDERFLOW/OVERFLOW" SEVERITY NOTE;
        A_s <= to_unsigned(5, 8);
        B_s <= to_unsigned(10, 8);
        CMD_s <= "0001"; -- SUB
        WAIT FOR PROPAGATION_DELAY;
        WAIT FOR 0 ns; -- Adicionado
        -- 5 - 10 = -5. Em 8 bits unsigned: -5 + 256 = 251 (11111011 bin)
        ASSERT R_s = to_unsigned(251, 8) REPORT "T6: SUB Underflow - Resultado incorreto" SEVERITY ERROR;
        ASSERT ZERO_s = '0' REPORT "T6: SUB Underflow - ZERO flag incorreta" SEVERITY ERROR;
        ASSERT OVERFLOW_s = '1' REPORT "T6: SUB Underflow - OVERFLOW flag incorreta" SEVERITY ERROR;
        ASSERT NEGATIVE_s = '1' REPORT "T6: SUB Underflow - NEGATIVE flag incorreta" SEVERITY ERROR; -- MSB é 1 (251 > 128)
        ASSERT EQUAL_s = '0' REPORT "T6: SUB Underflow - EQUAL flag incorreta" SEVERITY ERROR;
        ASSERT GREATER_s = '0' REPORT "T6: SUB Underflow - GREATER flag incorreta" SEVERITY ERROR;
        ASSERT SMALLER_s = '0' REPORT "T6: SUB Underflow - SMALLER flag incorreta" SEVERITY ERROR; -- 5 < 10

        -- Teste 7: Comparação (A > B) - GREATER flag
        REPORT "Teste 7: Comparacao (A > B) - GREATER" SEVERITY NOTE;
        A_s <= to_unsigned(15, 8);
        B_s <= to_unsigned(10, 8);
        CMD_s <= "0000"; -- CMD pode ser qualquer um que não altere as flags de comparação (ADD, NOP)
                          -- Já que as flags de comparação são calculadas do A e B da porta.
        WAIT FOR PROPAGATION_DELAY;
        WAIT FOR 0 ns; -- Adicionado
        ASSERT GREATER_s = '1' REPORT "T7: Comparacao - GREATER flag incorreta" SEVERITY ERROR;
        ASSERT SMALLER_s = '0' REPORT "T7: Comparacao - SMALLER flag incorreta" SEVERITY ERROR;
        ASSERT EQUAL_s = '0' REPORT "T7: Comparacao - EQUAL flag incorreta" SEVERITY ERROR;

        -- Teste 8: Comparação (A < B) - SMALLER flag
        REPORT "Teste 8: Comparacao (A < B) - SMALLER" SEVERITY NOTE;
        A_s <= to_unsigned(10, 8);
        B_s <= to_unsigned(15, 8);
        CMD_s <= "0000"; -- NOP ou ADD
        WAIT FOR PROPAGATION_DELAY;
        WAIT FOR 0 ns; -- Adicionado
        ASSERT GREATER_s = '0' REPORT "T8: Comparacao - GREATER flag incorreta" SEVERITY ERROR;
        ASSERT SMALLER_s = '1' REPORT "T8: Comparacao - SMALLER flag incorreta" SEVERITY ERROR;
        ASSERT EQUAL_s = '0' REPORT "T8: Comparacao - EQUAL flag incorreta" SEVERITY ERROR;

        -- Teste 9: Comparação (A = B) - EQUAL flag
        REPORT "Teste 9: Comparacao (A = B) - EQUAL" SEVERITY NOTE;
        A_s <= to_unsigned(10, 8);
        B_s <= to_unsigned(10, 8);
        CMD_s <= "0000"; -- NOP ou ADD
        WAIT FOR PROPAGATION_DELAY;
        WAIT FOR 0 ns; -- Adicionado
        ASSERT GREATER_s = '0' REPORT "T9: Comparacao - GREATER flag incorreta" SEVERITY ERROR;
        ASSERT SMALLER_s = '0' REPORT "T9: Comparacao - SMALLER flag incorreta" SEVERITY ERROR;
        ASSERT EQUAL_s = '1' REPORT "T9: Comparacao - EQUAL flag incorreta" SEVERITY ERROR;

        -- Teste 10: INC  (8 -> 9, sem overflow)
        REPORT "Teste 10: INC (8 -> 9)" SEVERITY NOTE;
        A_s    <= to_unsigned(8, 8);
        B_s    <= to_unsigned(0, 8);      -- ss == 00 (INC)
        CMD_s  <= "0010";                 -- opcode INC/DEC
        WAIT FOR PROPAGATION_DELAY; WAIT FOR 0 ns;
        ASSERT R_s = to_unsigned(9, 8)                    REPORT "T10 INC - Resultado"  SEVERITY ERROR;
        ASSERT ZERO_s = '0'                               REPORT "T10 INC - ZERO"       SEVERITY ERROR;
        ASSERT OVERFLOW_s = '0'                           REPORT "T10 INC - OVERFLOW"    SEVERITY ERROR;
        ASSERT NEGATIVE_s = '0'                           REPORT "T10 INC - NEGATIVE"    SEVERITY ERROR;

        -- Teste 11: INC  (255 -> 0, provoca overflow)
        REPORT "Teste 11: INC (255 -> 0) OVERFLOW" SEVERITY NOTE;
        A_s   <= to_unsigned(255, 8);
        CMD_s <= "0010";                                  -- INC
        WAIT FOR PROPAGATION_DELAY; WAIT FOR 0 ns;
        ASSERT R_s = to_unsigned(0, 8)                    REPORT "T11 INC ovf - Resultado" SEVERITY ERROR;
        ASSERT ZERO_s = '1'                               REPORT "T11 INC ovf - ZERO"      SEVERITY ERROR;
        ASSERT OVERFLOW_s = '1'                           REPORT "T11 INC ovf - OVERFLOW"  SEVERITY ERROR;
        ASSERT NEGATIVE_s = '0'                           REPORT "T11 INC ovf - NEGATIVE"  SEVERITY ERROR;

        -- Teste 12: DEC  (0 -> 255, overflow)
        REPORT "Teste 12: DEC (0 -> 255) OVERFLOW" SEVERITY NOTE;
        A_s   <= to_unsigned(0, 8);
        B_s <= "00000001"; -- ss = 01 (DEC)
        CMD_s <= "0010";
        WAIT FOR PROPAGATION_DELAY; WAIT FOR 0 ns;
        ASSERT R_s = to_unsigned(255, 8)                  REPORT "T12 DEC ovf - Resultado" SEVERITY ERROR;
        ASSERT ZERO_s = '0'                               REPORT "T12 DEC ovf - ZERO"      SEVERITY ERROR;
        ASSERT OVERFLOW_s = '1'                           REPORT "T12 DEC ovf - OVERFLOW"  SEVERITY ERROR;
        ASSERT NEGATIVE_s = '1'                           REPORT "T12 DEC ovf - NEGATIVE"  SEVERITY ERROR;

        -- Teste 13: DEC  (10 -> 9, sem overflow)
        REPORT "Teste 13: DEC (10 -> 9)" SEVERITY NOTE;
        A_s   <= to_unsigned(10, 8);
        B_s <= "00000001"; -- DEC
        CMD_s <= "0010";
        WAIT FOR PROPAGATION_DELAY; WAIT FOR 0 ns;
        ASSERT R_s = to_unsigned(9, 8)                    REPORT "T13 DEC - Resultado" SEVERITY ERROR;
        ASSERT OVERFLOW_s = '0'                           REPORT "T13 DEC - OVERFLOW"  SEVERITY ERROR;

        --------------------------------------------------------------------
        --  TESTES OPERADORES LÓGICOS  (14 a 20)
        --------------------------------------------------------------------
        -- Teste 14: AND  (F0 & 0F = 00)
        REPORT "Teste 14: AND (0xF0 & 0x0F = 0x00)" SEVERITY NOTE;
        A_s <= x"F0";  B_s <= x"0F";  CMD_s <= "0011"; -- AND
        WAIT FOR PROPAGATION_DELAY; WAIT FOR 0 ns;
        ASSERT R_s = x"00" REPORT "T14 AND - Resultado"  SEVERITY ERROR;
        ASSERT ZERO_s = '1' REPORT "T14 AND - ZERO"      SEVERITY ERROR;
        ASSERT NEGATIVE_s = '0' REPORT "T14 AND - NEG"   SEVERITY ERROR;
        ASSERT OVERFLOW_s = '0' REPORT "T14 AND - OVF"   SEVERITY ERROR;

        -- Teste 15: OR   (F0 | 0F = FF)
        REPORT "Teste 15: OR  (0xF0 | 0x0F = 0xFF)" SEVERITY NOTE;
        CMD_s <= "0100"; -- OR
        WAIT FOR PROPAGATION_DELAY; WAIT FOR 0 ns;
        ASSERT R_s = x"FF" REPORT "T15 OR - Resultado"   SEVERITY ERROR;
        ASSERT ZERO_s = '0' REPORT "T15 OR - ZERO"       SEVERITY ERROR;
        ASSERT NEGATIVE_s = '1' REPORT "T15 OR - NEG"    SEVERITY ERROR;

        -- Teste 16: NOT  (~F0 = 0F)
        REPORT "Teste 16: NOT (~0xF0 = 0x0F)" SEVERITY NOTE;
        CMD_s <= "0101"; -- NOT
        B_s <= (others => '0'); -- nn = 00 (NOT)
        WAIT FOR PROPAGATION_DELAY; WAIT FOR 0 ns;
        ASSERT R_s = x"0F" REPORT "T16 NOT - Resultado"  SEVERITY ERROR;
        ASSERT NEGATIVE_s = '0' REPORT "T16 NOT - NEG"   SEVERITY ERROR;

        -- Teste 17: XOR (AA xor 55 = FF)
        REPORT "Teste 17: XOR (0xAA ^ 0x55 = 0xFF)" SEVERITY NOTE;
        A_s <= x"AA";  B_s <= x"55";  CMD_s <= "0110"; -- XOR
        WAIT FOR PROPAGATION_DELAY; WAIT FOR 0 ns;
        ASSERT R_s = x"FF" REPORT "T17 XOR - Resultado" SEVERITY ERROR;
        ASSERT NEGATIVE_s = '1' REPORT "T17 XOR - NEG"  SEVERITY ERROR;

        -- Teste 18: ROL  (1000_0001 -> 0000_0011)
        REPORT "Teste 18: ROL (0x81 -> 0x03)" SEVERITY NOTE;
        A_s <= "10000001";
        B_s <= "00000000"; -- nn = 00 (ROL)
        CMD_s <= "0111"; -- ROL
        WAIT FOR PROPAGATION_DELAY; WAIT FOR 0 ns;
        ASSERT R_s = "00000011" REPORT "T18 ROL - Resultado" SEVERITY ERROR;
        ASSERT NEGATIVE_s = '0' REPORT "T18 ROL - NEG"       SEVERITY ERROR;

        -- Teste 19: ROR  (1000_0001 -> 1100_0000)
        REPORT "Teste 19: ROR (0x81 -> 0xC0)" SEVERITY NOTE;
        B_s <= "00000001"; -- nn = 01 (ROR)
        CMD_s <= "0111"; -- ROR
        WAIT FOR PROPAGATION_DELAY; WAIT FOR 0 ns;
        ASSERT R_s = "11000000" REPORT "T19 ROR - Resultado" SEVERITY ERROR;
        ASSERT NEGATIVE_s = '1' REPORT "T19 ROR - NEG"       SEVERITY ERROR;

        -- Teste 20: LSL  (1000_0001 -> 0000_0010)  e  LSR (-> 0100_0000)
        REPORT "Teste 20: LSL (0x81 -> 0x02)" SEVERITY NOTE;
        B_s <= "00000010"; -- nn = 10 (LSL)
        CMD_s <= "0111"; -- LSL
        WAIT FOR PROPAGATION_DELAY; WAIT FOR 0 ns;
        ASSERT R_s = "00000010" REPORT "T20 LSL - Resultado" SEVERITY ERROR;

        REPORT "Teste 21: LSR (0x81 -> 0x40)" SEVERITY NOTE;
        B_s <= "00000011"; -- nn = 11 (LSR)
        CMD_s <= "0111"; -- LSR
        WAIT FOR PROPAGATION_DELAY; WAIT FOR 0 ns;
        ASSERT R_s = "01000000" REPORT "T21 LSR - Resultado" SEVERITY ERROR;

        -- Fim
        REPORT "Todos os testes da ALU (aritméticos + lógicos) concluídos." SEVERITY NOTE;
        WAIT;
    end process;

END;
