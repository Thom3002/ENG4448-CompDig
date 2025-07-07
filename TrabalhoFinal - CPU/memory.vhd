library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity memory is
    port(
        CLK     : in std_logic;
        DIN     : in std_logic_vector(7 downto 0);
        ADDR    : in std_logic_vector(7 downto 0);
        WE      : in std_logic;
        DOUT    : out std_logic_vector(7 downto 0);
        POS_255 : out std_logic_vector(7 downto 0)
    );
end memory;

architecture rtl of memory is

    type RAM_t is array(0 to 255) of std_logic_vector(7 downto 0);
    signal read_address : std_logic_vector(7 downto 0) := (others => '0');

    -- testinst.asm
    signal ram : RAM_t := (
        0  => "00000001", -- add R0, R1 -> R0 = 1
        1  => "00010001", -- sub R0, R1 -> R0 = 0
        2  => "00100000", -- inc R0     -> R0 = 1
        3  => "00100001", -- dec R0     -> R0 = 0
        4  => "00110001", -- and R0, R1 -> R0 = 0
        5  => "01000001", -- or R0, R1  -> R0 = 1
        6  => "01010000", -- not R0     -> R0 = 11111110
        7  => "01110001", -- ror R0     -> R0 = 01111111
        8  => "01100001", -- xor R0, R1 -> R0 = 01111110
        9  => "01110000", -- rol R0     -> R0 = 11111100
        10 => "01110010", -- lsl R0     -> R0 = 11111000
        11 => "01110011", -- lsr R0     -> R0 = 01111100
        12 => "10000000", -- push R0    -> memory[255] = R0
        13 => "10000001", -- pop R0     -> R0 = memory[255]
        14 => "10000010", -- st R0, 0x20-> memory[32] = R0
        15 => "00100000", -- addr = 0x20-> part of instruction above
        16 => "10000011", -- ld R0, 0x20-> R0 = memory[32]
        17 => "00100000", -- addr = 0x20-> part of instruction above
        18 => "10010001", -- ldr R0, R1 -> R0 = memory[R1]
        19 => "10100001", -- str R0, R1 -> memory[R1] = R0
        20 => "10110001", -- mov R0, R1 -> R0 = R1 (000000001)
        21 => "11000000", -- jmp 0x17   -> jump to instruction at addr 0x17 which is nop
        22 => "00010110", -- addr 0x19  -> addr of instruction 25 nop
        23 => "00100000", -- inc R0     ->
        24 => "00100000", -- inc R0     ->
        25 => "11110000", -- nop
        26 => "11111111", -- halt
        others => (others => '0')
    );

begin

    process(CLK) is
    begin
        if falling_edge(CLK) then
            if WE = '1' then
                ram(to_integer(unsigned(ADDR))) <= DIN;
            end if;
            read_address <= ADDR;
        end if;
    end process;

    DOUT    <= ram(to_integer(unsigned(read_address)));
    POS_255 <= ram(255);

end architecture;
