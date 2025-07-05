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
        lcd_data   : out std_logic_vector(3 downto 0)
    );
end lcd_write;

architecture Behavioral of lcd_write is
    type state_type is (IDLE, SEND_HIGH, SEND_LOW, DELAY);
    signal state : state_type := IDLE;

    signal counter_230n : integer range 0 to 12 := 0;
    signal counter_40m : integer range 0 to 2000 := 0;
    signal counter_1m : integer range 0 to 50 := 0;
    signal counter_message : integer range 0 to 14 :=0;
    signal nibble  : std_logic_vector(3 downto 0);
    signal counter : integer range 0 to 1000 := 0;
    type display_data_t is array (0 to 14) of std_logic_vector(7 downto 0);
    signal  message : DISPLAY_DATA_t := (0 => x"54", 1 => x"48", 2 => x"4f", 3 => x"4d", 4 => x"41", 5 => x"53", 6 => x"20", 7 => x"45", 8 => x"20", 9 => x"46", 10 => x"45", 11 => x"4c", 12 => x"49", 13 => x"50", 14 => x"45");
    

begin
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
                    lcd_data <= message(counter_message)(7 downto 4);
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
                        lcd_data <= message(counter_message)(3 downto 0);
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
                    if counter_message =  14 then
                        state <= DELAY;
                    else 
                        if counter_40m < 2000 then
                            counter_40m <= counter_40m + 1;
                        else
                            state <= IDLE; -- enviar prxima letra aqui
                            counter_40m <= 0;
                            counter <= 0;
                            counter_message <= counter_message + 1;
                        end if;
                    end if;

                when others =>
                    null;
            end case;
        end if;
    end process;
end Behavioral;
