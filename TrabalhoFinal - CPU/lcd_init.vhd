library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lcd_init is
    Port (
        clk       : in  std_logic;
        reset       : in  std_logic;
        lcd_rs    : out std_logic;
        lcd_rw    : out std_logic;
        lcd_e     : out std_logic;
        lcd_data  : out std_logic_vector(3 downto 0);
        init_done : out std_logic
    );
end lcd_init;

architecture Behavioral of lcd_init is

    constant C1 : integer := 750000; -- wait time in cycles
    constant C2 : integer := 205000;
    constant C3 : integer := 5000;
    constant C4 : integer := 2000;
    constant CLEAR_WAIT : integer := 82000;
    
    type state_type is (WAIT1, SEND3_1, WAIT2, SEND3_2, WAIT3, SEND3_3, WAIT4, SEND2, WAIT5, ST_LCD_ENABLE, ST_LCD_WAIT, CLEAR);
    signal state : state_type := WAIT1;

    signal counter : integer range 0 to 1000000 := 0;
    signal counter_clear : integer range 0 to CLEAR_WAIT := 0;
    signal counter_230n : integer range 0 to 12 := 0;
    signal counter_1m : integer range 0 to 50 := 0;
    signal counter_40m : integer range 0 to 1000000 := 0;
    signal counter_cfg : integer range 0 to 7 := 0;
    
    type conf_data_t is array (0 to 7) of std_logic_vector(3 downto 0);
	signal conf_data : CONF_DATA_t := (0 => x"2", 1 => x"8", 2 => x"0", 3 => x"6", 4 => x"0", 5 => x"F", 6 => x"0", 7 => x"1");

    

    signal lower : std_logic := '0';
    signal init_done_reg : std_logic := '0';
begin

    process(clk, reset)
    begin
        if reset = '1' then
            state <= WAIT1;
            counter <= 0;
            init_done_reg <= '0';
        elsif rising_edge(clk) then
            case state is
                when WAIT1 =>
                    init_done_reg <= '0';
                    lcd_data <= "0011";
                    lcd_rw   <= '0';
                    lcd_rs   <= '0';
                    lcd_e    <= '0';
                    if counter < C1 then
                        counter <= counter + 1;
                    else
                        state <= SEND3_1;
                        counter <= 0;
                        lcd_rs   <= '0';
                    end if;

                when SEND3_1 =>
                    lcd_data <= "0011";
                    lcd_rw   <= '0';
                    lcd_e    <= '1';
                    state <= WAIT2;

                when WAIT2 =>
                    if counter < C2 then
                        counter <= counter + 1;
                        lcd_e <= '0';
                    else
                        state <= SEND3_2;
                        counter <= 0;
                    end if;

                when SEND3_2 =>
                    lcd_data <= "0011";
                    lcd_e <= '1';
                    state <= WAIT3;

                when WAIT3 =>
                    if counter < C3 then
                        counter <= counter + 1;
                        lcd_e <= '0';
                    else
                        state <= SEND3_3;
                        counter <= 0;
                    end if;

                when SEND3_3 =>
                    lcd_data <= "0011";
                    lcd_e <= '1';
                    state <= WAIT4;

                when WAIT4 =>
                    if counter < C4 then
                        counter <= counter + 1;
                        lcd_e <= '0';
                    else
                        state <= SEND2;
                        counter <= 0;
                    end if;

                when SEND2 =>
                    lcd_data <= "0010"; -- 4-bit mode
                    lcd_e <= '1';
                    state <= WAIT5;

                when WAIT5 =>
                    if counter < C4 then
                        counter <= counter + 1;
                        lcd_e <= '0';
                    else
                        state <= ST_LCD_ENABLE;
                        lcd_data <= conf_data(counter_cfg);
                        counter <= 0;
                    end if;
                    
                when ST_LCD_ENABLE =>
                    lcd_e <= '1';
                    counter_1m <= 0;
                    counter_40m <= 0;
                    if counter_230n /= 12 then
                        counter_230n <= counter_230n + 1;
                    else
                        if counter_cfg < 7 then
                            state <= ST_LCD_WAIT;
                            counter_cfg <= counter_cfg + 1;
                        else 
                            counter_cfg <= 0;
                            state <= CLEAR;
                        end if;
                    end if;
                    
                when ST_LCD_WAIT =>
                    counter_230n <= 0;
                    if lower = '0' then
                        counter_1m <= counter_1m + 1;
                        if counter_1m = 50 then
                            state <= ST_LCD_ENABLE;
                            lower <= not lower;
                        end if;
                    else 
                        counter_40m <= counter_40m + 1;
                        if counter_40m = 2000 then
                            state <= ST_LCD_ENABLE;
                            lower <= not lower;
                        end if;
                    end if;
                    lcd_e <= '0';
                    lcd_data <= conf_data(counter_cfg);
                    
                when CLEAR =>
                    if counter < CLEAR_WAIT then
                        counter <= counter + 1;
                        lcd_e <= '0';
                    else
                        init_done_reg <= '1';
                    end if;
            end case;
        end if;
    end process;
    
    init_done <= init_done_reg;

end Behavioral;
