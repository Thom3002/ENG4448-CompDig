-------------------------------------------------------------------------------
-- Test-bench - Fibonacci              resultado → RAM(255) e halt
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_tb is end;
architecture tb of cpu_tb is
    ---------------------------------------------------------------------------
    -- UUT
    ---------------------------------------------------------------------------
    component CPU
        port ( CLK      : in  std_logic;
               RESET    : in  std_logic;
               RAM_ADDR : out std_logic_vector(7 downto 0);
               RAM_DIN  : out std_logic_vector(7 downto 0);
               RAM_DOUT : in  std_logic_vector(7 downto 0);
               RAM_WE   : out std_logic );
    end component;

    -- sinais
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '1';
    signal ram_addr : std_logic_vector(7 downto 0);
    signal ram_din  : std_logic_vector(7 downto 0);
    signal ram_dout : std_logic_vector(7 downto 0);
    signal ram_we   : std_logic;

    constant clk_period : time := 20 ns;  -- 50 MHz
    constant RESULT_ADDR : integer := 255; -- 0xFF I/O

    ---------------------------------------------------------------------------
    -- Programa Fibonacci (v1) - resultado (8 bits) em RAM(255),
    -- termina com HALT = x"FF"
    ---------------------------------------------------------------------------
    type ram_t is array (0 to 255) of std_logic_vector(7 downto 0);

signal ram : ram_t := (
    -- Programa
    16#00# => x"83",  -- LD  R0,0xF1  (prev ← 1)
    16#01# => x"F1",
    16#02# => x"87",  -- LD  R1,0xF2  (curr ← 1)
    16#03# => x"F2",
    16#04# => x"8B",  -- LD  R2,0xF3  (counter ← 6)
    16#05# => x"F3",
    16#06# => x"8F",  -- LD  R3,0x08  (endereço do laço)
    16#07# => x"08",

    -- Laço principal (PC = 0x08)
    16#08# => x"01",  -- ADD R0,R1
    16#09# => x"61",  -- XOR R0,R1
    16#0A# => x"64",  -- XOR R1,R0
    16#0B# => x"61",  -- XOR R0,R1
    16#0C# => x"29",  -- DEC R2
    16#0D# => x"CF",  -- BNZ R3 → 0x08

    -- Fim
    16#0E# => x"86",  -- ST  R1,0xFF
    16#0F# => x"FF",
    16#10# => x"FF",  -- HALT

    -- Dados constantes
    16#F1# => x"01",
    16#F2# => x"01",
    16#F3# => x"06",
    others => (others => '0')
);

begin
    ---------------------------------------------------------------------------
    uut : CPU
        port map ( CLK      => clk,
                   RESET    => reset,
                   RAM_ADDR => ram_addr,
                   RAM_DIN  => ram_din,
                   RAM_DOUT => ram_dout,
                   RAM_WE   => ram_we );

    ---------------------------------------------------------------------------
    clk <= not clk after clk_period/2;

    ---------------------------------------------------------------------------
    ram_proc : process(clk)
    begin
        if falling_edge(clk) then
            if ram_we = '1' then
                ram(to_integer(unsigned(ram_addr))) <= ram_din;
            end if;
            ram_dout <= ram(to_integer(unsigned(ram_addr)));
        end if;
    end process;

    ---------------------------------------------------------------------------
    -- estímulo: solta reset, espera HALT, confere RAM(255)
    ---------------------------------------------------------------------------
    stim : process
        variable cycles : integer := 0;
    begin
        wait for 200 ns;
        reset <= '0';

        wait until ram(to_integer(unsigned(ram_addr))) = x"FF"; -- HALT fetch
        wait for clk_period;    -- garante término da instrução

        report "Fibonacci = " &
               integer'image(to_integer(unsigned(ram(RESULT_ADDR))))
               severity note;

        wait;
    end process;
end architecture;