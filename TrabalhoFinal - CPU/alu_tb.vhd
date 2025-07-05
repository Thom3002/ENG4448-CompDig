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

        REPORT "Todos os testes da ALU concluídos." SEVERITY NOTE;
        WAIT; -- Termina a simulação
    end process;

END;