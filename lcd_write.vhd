library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lcd_write is
    Port (
        clk        : in  std_logic;
        reset        : in  std_logic;
        init_done  : in  std_logic;
        lcd_rs     : out std_logic;
        lcd_rw     : out std_logic;
        lcd_e      : out std_logic;
        lcd_data   : out std_logic_vector(3 downto 0);
        ir_data    : in std_logic_vector(7 downto 0);
        memory_data: in std_logic_vector(7 downto 0)
    );
end lcd_write;

architecture Behavioral of lcd_write is
    type state_type is (IDLE, SEND_HIGH, SEND_LOW, DELAY);
    signal state : state_type := IDLE;

    signal counter_230n : integer range 0 to 12 := 0;
    signal counter_40m : integer range 0 to 2000 := 0;
    signal counter_1m : integer range 0 to 50 := 0;
    signal counter_message : integer range 0 to 31 :=0;
    signal nibble  : std_logic_vector(3 downto 0);
    signal counter : integer range 0 to 1000 := 0;
    type display_data_t is array (0 to 31) of std_logic_vector(7 downto 0);  
    signal message : display_data_t;
    subtype byte_t     is std_logic_vector(7 downto 0);
    type     ascii4_a  is array (0 to 3) of byte_t;   -- 4 bytes
    signal ascii_op   : ascii4_a;

--------------------------------------------------------------------
-- 2  FUNÇÃO  str4  : STRING(1?4) ? ascii4_a
--------------------------------------------------------------------
impure function str4(s : string) return ascii4_a is
    variable r : ascii4_a := (others => (others => '0'));
begin
    -- copia cada caractere para um elemento do array
    for i in s'range loop               -- i = 1 .. s'length
        r(i-1) := std_logic_vector(
                     to_unsigned(character'pos(s(i)), 8));
    end loop;
    return r;
end function;

--------------------------------------------------------------------
-- 3  FUNÇÃO  opcode_to_ascii : recebe IR e devolve vet(0..3)
--------------------------------------------------------------------
function opcode_to_ascii(instr : std_logic_vector(7 downto 0))
         return ascii4_a is
    variable m : ascii4_a := str4("????");
    constant op : std_logic_vector(3 downto 0) := instr(7 downto 4);
    constant ss : std_logic_vector(1 downto 0) := instr(1 downto 0);
begin
    case op is
        when "0000"   => m := str4("ADD ");
        when "0001"   => m := str4("SUB ");
        when "0010"   =>
            case ss is
                when "00" => m := str4("INC ");
                when "01" => m := str4("DEC ");
                when others => null;
            end case;
        when "0011"   => m := str4("AND ");
        when "0100"   => m := str4("OR  ");
        when "0101"   => m := str4("NOT ");
        when "0110"   => m := str4("XOR ");
        when "0111"   =>
            case ss is
                when "00" => m := str4("ROL ");
                when "01" => m := str4("ROR ");
                when "10" => m := str4("LSL ");
                when "11" => m := str4("LSR ");
                when others => null;
            end case;
        when "1000"   =>
            case ss is
                when "00" => m := str4("PUSH");
                when "01" => m := str4("POP ");
                when "10" => m := str4("ST  ");
                when "11" => m := str4("LD  ");
                when others => null;
            end case;
        when "1001"   => m := str4("LDR ");
        when "1010"   => m := str4("STR ");
        when "1011"   => m := str4("MOV ");
        when "1100"   => m := str4("JMPR");
        when "1101"   =>
            case ss is
                when "00" => m := str4("BCS ");
                when "01" => m := str4("BCC ");
                when "10" => m := str4("BEQ ");
                when "11" => m := str4("BNE ");
                when others => null;
            end case;
        when "1110"   =>
            case ss is
                when "00" => m := str4("BGT ");
                when "01" => m := str4("BLT ");
                when "10" => m := str4("BNEQ"); -- 4 letras
                when others => null;
            end case;
        when "1111"   =>
            if instr = x"FF" then
                m := str4("HALT");
            else
                m := str4("NOP ");
            end if;
        when others   => null;
    end case;
    return m;
end function;

function binary_to_ascii(instr : std_logic)
         return byte_t is
    variable m : byte_t ;
    constant op : std_logic := instr;
begin
    case op is
        when '0'   => m := x"30";
        when '1'   => m := x"31";
        when others=> null;
    end case;
    return m;
end function;
begin

    ascii_op <= opcode_to_ascii(ir_data);
    message <= (
    0 => ascii_op(0),
    1 => ascii_op(1),
    2 => ascii_op(2),
    3 => ascii_op(3),
    16 => binary_to_ascii(memory_data(7)),
    17 => binary_to_ascii(memory_data(6)),
    18 => binary_to_ascii(memory_data(5)),
    19 => binary_to_ascii(memory_data(4)),
    20 => binary_to_ascii(memory_data(3)),
    21 => binary_to_ascii(memory_data(2)),
    22 => binary_to_ascii(memory_data(1)),
    23 => binary_to_ascii(memory_data(0)),
    others => x"20");
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            counter <= 0;
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    lcd_rs <= '1'; -- dado
                    lcd_rw <= '0';
                    lcd_data <= message(counter_message)(7 downto 4);--message(counter_message)(7 downto 4);
                    lcd_e <= '1';
                    if init_done = '1' then
                        counter_230n <= counter_230n + 1;
                        if counter_230n = 12 then
                            counter_230n <= 0;
                            state <= SEND_HIGH;
                        end if;
                    end if;

                when SEND_HIGH =>
                    counter_230n <= 0;
                    lcd_e <= '0';
                    counter_1m <= counter_1m + 1;
                    if counter_1m = 50 then
                        lcd_data <= message(counter_message)(3 downto 0);--message(counter_message)(3 downto 0);
                        state <= SEND_LOW;
                    end if;

                when SEND_LOW =>
                    counter_1m <= 0;
                    lcd_e <= '1';
                    counter_230n <= counter_230n + 1;
                    if counter_230n = 12 then
                        counter_230n <= 0;
                        state <= DELAY;
                    end if;

                when DELAY =>
                    lcd_e <= '0';
                    counter_230n <= 0; 
                    if counter_40m < 2000 then
                        counter_40m <= counter_40m + 1;
                    else
                        state <= IDLE; -- enviar prxima letra aqui
                        counter_40m <= 0;
                        counter <= 0;
                        if counter_message = 31 then
                         counter_message <= 0;
                        else
                            counter_message <= counter_message + 1;
                        end if;
                    end if;
                when others =>
                    null;
            end case;
        end if;
    end process;
end Behavioral;
