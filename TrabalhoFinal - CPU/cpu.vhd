LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY CPU IS
	PORT (
		CLK : IN STD_LOGIC;
		RESET : IN STD_LOGIC;
		RAM_ADDR : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		RAM_DIN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		RAM_DOUT : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		RAM_WE : OUT STD_LOGIC
	);
END CPU;

ARCHITECTURE Behavioral OF CPU IS

	TYPE cpu_fsm_t IS (st_idle, st_fetch, st_decode, st_execute, st_write);
	SIGNAL state : cpu_fsm_t := st_idle;

	-- UC registers
	SIGNAL PC, IR, SP, MAR : unsigned(7 DOWNTO 0) := (OTHERS => '0');

	TYPE reg_array IS ARRAY(0 TO 3) OF unsigned(7 DOWNTO 0);
	SIGNAL registers : reg_array := (
		0 => "10000000",
		OTHERS => (OTHERS => '0')
	);

	-- ALU signals
	SIGNAL ALU_A, ALU_B, ALU_R : unsigned(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL ALU_CMD             : unsigned(3 DOWNTO 0)  := (OTHERS => '0');

	SIGNAL alu_zero   : STD_LOGIC;
    SIGNAL alu_neg    : STD_LOGIC;
    SIGNAL alu_ovf    : STD_LOGIC;
    SIGNAL alu_eq     : STD_LOGIC;
    SIGNAL alu_gt     : STD_LOGIC;
	SIGNAL alu_lt     : STD_LOGIC;

	TYPE ALU_FLAGS_t IS RECORD
		zero : std_logic;
		negative : std_logic;
		overflow : std_logic;
		equal : std_logic;
		greater : std_logic;
		smaller : std_logic;
	END RECORD ALU_FLAGS_t;

SIGNAL ALU_FLAGS : ALU_FLAGS_t := (OTHERS => '0');

   -- LCD signals
   SIGNAL lcd_rs_s: STD_LOGIC;
   SIGNAL lcd_rw_s: STD_LOGIC;
   SIGNAL lcd_e_s: STD_LOGIC;
   SIGNAL lcd_data_s: STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL sf_ce0_s: STD_LOGIC;

BEGIN
	-- ALU
	U_ALU : ENTITY work.alu
		PORT MAP(
			A => ALU_A,
			B => ALU_B,
			CMD => std_logic_vector(ALU_CMD(3 DOWNTO 0)),
			R => ALU_R,
			ZERO => alu_zero,
			NEGATIVE => alu_neg,
			OVERFLOW => alu_ovf,
			EQUAL => alu_eq,
			GREATER => alu_gt,
			SMALLER => alu_lt
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
				SF_CE0 => sf_ce0_s
			);

	PROCESS (CLK)
	BEGIN
		IF rising_edge(clk) THEN
			IF reset = '1' THEN
				state <= st_idle;
			ELSE
				CASE state IS
					WHEN st_idle =>
						PC <= to_unsigned(0, PC'length); -- Program Counter
						IR <= to_unsigned(0, IR'length); -- Instruction Register
						SP <= to_unsigned(254, SP'length); -- Stack Pointer
						MAR <= to_unsigned(0, MAR'length); -- Memory Address Register
						IF reset = '0' THEN
							state <= st_fetch;
						END IF;

					WHEN st_fetch =>
						RAM_WE <= '0';
						IR <= unsigned(RAM_DOUT);

						state <= st_decode;

					WHEN st_decode =>
						-- add Rx, Ry "0000 Rx Ry" Rx ? Rx + Ry; PC ? PC + 1
						IF IR(7 DOWNTO 4) = "0000" THEN
							ALU_A <= registers(to_integer(IR(3 DOWNTO 2)));
							ALU_B <= registers(to_integer(IR(1 DOWNTO 0)));
							ALU_CMD <= "0000"; -- add

						state <= st_execute;
						-- sub Rx,Ry "0001 Rx Ry" Rx ← Rx − Ry
						ELSIF IR(7 DOWNTO 4) = "0001" THEN
							ALU_A <= unsigned(registers(to_integer(IR(3 DOWNTO 2))));
							ALU_B <= unsigned(registers(to_integer(IR(1 DOWNTO 0))));
							ALU_CMD <= "0001";

						-- inc/dec Rx "0010 Rx ss" ss=00 inc, 01 dec
						ELSIF IR(7 DOWNTO 4) = "0010" THEN
							ALU_A <= unsigned(registers(to_integer(IR(3 DOWNTO 2))));
							IF IR(1 DOWNTO 0) = "00" THEN -- inc
								ALU_B <= to_unsigned(1, 8); -- 00000001 (incrementa 1)
								ALU_CMD <= "0000"; -- add
							ELSE -- dec
								ALU_B <= to_unsigned(1, 8);
								ALU_CMD <= "0001"; -- sub
							END IF;

						-- and Rx,Ry "0011 Rx Ry"
						ELSIF IR(7 DOWNTO 4) = "0011" THEN
							ALU_A <= unsigned(registers(to_integer(IR(3 DOWNTO 2))));
							ALU_B <= unsigned(registers(to_integer(IR(1 DOWNTO 0))));
							ALU_CMD <= "0010";

						-- or Rx,Ry "0100 Rx Ry"
						ELSIF IR(7 DOWNTO 4) = "0100" THEN
							ALU_A <= unsigned(registers(to_integer(IR(3 DOWNTO 2))));
							ALU_B <= unsigned(registers(to_integer(IR(1 DOWNTO 0))));
							ALU_CMD <= "0011";

						-- not Rx      "0101 Rx 00"  Rx ? ~Rx
						elsif IR(7 downto 4) = "0101" then
							 ALU_A   <= registers(to_integer(IR(3 downto 2)));
							 ALU_B   <= ("000000" & IR(1 downto 0));
							 ALU_CMD <= "0101";

						-- xor Rx, Ry  "0110 Rx Ry"  Rx ? Rx ^ Ry
						elsif IR(7 downto 4) = "0110" then
							 ALU_A   <= registers(to_integer(IR(3 downto 2)));
							 ALU_B   <= registers(to_integer(IR(1 downto 0)));
							 ALU_CMD <= "0110";

						-- rol/rOr/lsl/lsr "0111 Rx nn" nn=00 rol,01 ror,10 lsl,11 lsr
						elsif IR(7 downto 4) = "0111" then
							 ALU_A   <= registers(to_integer(IR(3 downto 2)));
							 ALU_B   <= ("000000" & IR(1 downto 0));
							 ALU_CMD <= "0111";

						-- push / pop / st / ld   "1000 Rx ss"
						ELSIF IR(7 DOWNTO 4) = "1000" THEN
							 -- push Rx  ss = 00
							 IF IR(1 DOWNTO 0) = "00" THEN
								  MAR      <= SP;            -- endereço da pilha
								  RAM_DIN  <= std_logic_vector(registers(to_integer(IR(3 DOWNTO 2))));
								  RAM_WE   <= '1';                            -- escreve na RAM
								  state    <= st_write;                       -- SP -- no write

							 -- pop Rx   ss = 01
							 ELSIF IR(1 DOWNTO 0) = "01" THEN
								  MAR      <= SP + 1;        -- SP + 1 primeiro
								  RAM_WE   <= '0';                            -- leitura
								  state    <= st_write;                       -- captura dado + SP++

							 -- st Rx, ADDR   ss = 10  (ADDR em PC+1)
							 ELSIF IR(1 DOWNTO 0) = "10" THEN
								  MAR      <= PC + 1;        -- lê ADDR no próximo byte
								  RAM_WE   <= '0';                            -- leitura
								  state    <= st_write;                       -- faz escrita na 2ª fase

							 -- ld Rx, ADDR   ss = 11
							 ELSE                                             -- "11"
								  MAR      <= PC + 1;        -- lê ADDR
								  RAM_WE   <= '0';                            -- leitura
								  state    <= st_write;                       -- traz dado para Rx
							 END IF;

						-- ldr Rx, [Ry]   "1001 Rx Ry"
						ELSIF IR(7 DOWNTO 4) = "1001" THEN
							 MAR      <= registers(to_integer(IR(1 DOWNTO 0))); -- endereço = Ry
							 RAM_WE   <= '0';                                   -- leitura
							 state    <= st_write;                              -- copia em Rx

						-- str Rx, [Ry]   "1010 Rx Ry"
						ELSIF IR(7 DOWNTO 4) = "1010" THEN
							 MAR      <= registers(to_integer(IR(1 DOWNTO 0))); -- endereço = Ry
							 RAM_DIN  <= std_logic_vector(registers(to_integer(IR(3 DOWNTO 2)))); -- dado = Rx
							 RAM_WE   <= '1';                                   -- escrita
							 state    <= st_write;


						END IF;

					WHEN st_execute =>

						-- Copia o resultado da ALU para o registrador de destino
						IF IR(7 DOWNTO 4) >= "0000" AND IR(7 DOWNTO 4) <= "0111" THEN -- Todas as instruções ALU
							registers(to_integer(IR(3 DOWNTO 2))) <= ALU_R;
							ALU_FLAGS.zero     <= alu_zero;
							ALU_FLAGS.negative <= alu_neg;
							ALU_FLAGS.overflow <= alu_ovf;
							ALU_FLAGS.equal    <= alu_eq;
							ALU_FLAGS.greater  <= alu_gt;
							ALU_FLAGS.smaller  <= alu_lt;
						END IF;

						PC <= PC + 1;

						state <= st_fetch;


					WHEN st_write =>
						-- RAM_WE <= '0';
						-- IF IR(7 DOWNTO 2) = "100000" THEN      -- push
						-- SP <= SP - 1;
						-- ELSIF IR(7 DOWNTO 2) = "100001" THEN   -- pop
						-- 	registers(to_integer(IR(3 DOWNTO 2))) <= RAM_DOUT;
						-- 	SP <= SP + 1;
						-- 	PC <= PC + 1;             -- push/pop/ldr/str
						-- 	state <= st_fetch;
				END CASE;
			END IF;
		END IF;
	END PROCESS;
	RAM_ADDR <= std_logic_vector(MAR); -- memory address register

END Behavioral;
