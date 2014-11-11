-- Clockwork orange memory manager
-- Code provided by team blue
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
     
entity Flash_2 is
    Port (clk : in  STD_LOGIC;
          reset: in  STD_LOGIC;
          ADDR : out  STD_LOGIC_VECTOR (22 downto 0);
          MT_CE : out STD_LOGIC;
          CE : out  STD_LOGIC;
          OE : out  STD_LOGIC;
          WE : out  STD_LOGIC;
          data_bpm_in : in STD_LOGIC_VECTOR (7 downto 0);
          newData : in STD_LOGIC; -- switch 7, it is active high
          led_out : out STD_LOGIC_VECTOR (7 downto 0);
        --SW : in STD_LOGIC_VECTOR (7 downto 0);
          DATA : inout  STD_LOGIC_VECTOR (15 downto 0);
          flash_rp : out  STD_LOGIC;
			 rgBtn	: in std_logic_vector(3 downto 0);
          STS : in  STD_LOGIC);
end Flash_2;
     
architecture Behavioral of Flash_2 is
        TYPE State_type IS ( s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16,
                                                                s17, s18, s19, s20, s21) ;
        SIGNAL y : State_type ;
        constant half_sec : integer range 0 to 12500000 := 12500000; -- clk cycle for 0.5s
        constant cycle : integer range 0 to 100 := 40; -- 1 cycle period
        constant p1 : integer range 0 to 2000 := 700;  -- minimum is 625
        constant p2 : integer range 0 to 5 := 4;
        constant p3 : integer range 0 to 2000 := 1600;-- minimum is 1500 cycles since 60microsecond/40 ns
        constant w4 : integer range 0 to 10 := 1; -- since w4 has a minimum of 50ns
        constant r2 : integer range 0 to 5 := 2; -- max is 110ns based on the lecture slide but just use 4 clk cycles = 200ns
        constant difference : integer range 0 to 100000 := 850; -- difference between p1 and p3
        signal cycle_count : integer range 0 to 100000000 := 0;
        signal LED_state : std_logic_vector ( 7 downto 0 ):= "01000000";
   signal reg_data : std_logic_vector(7 downto 0) := "00000000";
        shared variable address : std_logic_vector(22 downto 0) := "00000000000000000000000";
        shared variable upCount : std_logic_vector(7 downto 0) := "00000000";
    signal sclk : std_logic;
	 signal reset_sig : std_logic;
    shared variable clk_counter : integer := 0;
	 shared variable count: integer range 0 to 5 := 0;
begin
reset_sig <= rgBtn(0);
process(clk)
    begin
        if(clk'event and clk = '1') then
            clk_counter := clk_counter + 1;
            if (count = 4) then
                count := 0;
                sclk <= NOT sclk;
            end if;
        end if;
end process;
    FSM_process : process(reset_sig, sclk)
--      LED_state <= "00001111";
    begin
        if reset_sig = '1' then
            y <= s1;
            cycle_count <= 0;
        elsif (rising_edge(sclk)) then
            case y is -- reseting flash start
                when s1 => -- hold reset for 0.5 secs
                    if cycle_count >= difference then
                        y <= s2;
                        cycle_count <= 0;
                    else
                        y <= s1;
                        cycle_count <= cycle_count + 1;
                      --cycle_count <= 0;
                    end if;
                    flash_rp <= '1';
                    CE <= '1';
                    WE <= '1';
                    ADDR <= (others => 'Z');
                    DATA <= (others => 'Z');
                    OE <= '1';     
                    MT_CE <= '1';
                when s2 =>
                    if cycle_count >= half_sec then -- hold flash_rp for 0.5 s
                        y <= s3;
                        cycle_count <= 0;
                    else
                        y <= s2;
                        flash_rp <= '0';
                        cycle_count <= cycle_count + 1;
                    end if;

                    CE <= '1';
                    WE <= '1';
                    ADDR <= (others => 'Z');
                    DATA <= (others => 'Z');
                    OE <= '1';     
                    MT_CE <= '1';
                when s3 =>
                    if STS = '1' then
    --                  y <= s4;
                        flash_rp <= '1';
                        CE <= '1';
                        WE <= '1';
                        ADDR <= (others => 'Z');
                        DATA <= (others => 'Z');
                        OE <= '1';     
                        MT_CE <= '1';
                        -- not neccessary, as long as you hold reset for 0.5 s
                        -- it should reset.

                        --p2 is 40 * 4 ns
                        if (cycle_count >= p2) then -- wait for p2
                            y <= s4;
                            cycle_count <= 0;
                        else
                            y <= s3;
                            cycle_count <= cycle_count + 1;
                        end if;
                    end if;
                when s4 =>
                    if STS = '1' then                                      
                        y <= s5;  -- reseting flash ends and starting to erase 0th blk       and newData = '1'
                        flash_rp <= '1';
                        CE <= '1';
                        WE <= '1';
                        ADDR <= (others => 'Z');
                        DATA <= (others => 'Z');
                        OE <= '1';     
                        MT_CE <= '1';

                    end if;
                when s5 =>
                    if cycle_count >= w4 then
                        y <= s6;
                        cycle_count <= 0;
                        CE <= '1';
                        WE <= '1'; -- only 5 MSB is needed to select the blk address
                        ADDR <= (others => 'Z');
                    else
                        y <= s5;
                        cycle_count <= cycle_count + 1;
                        CE <= '0';
                        WE <= '0';
                        ADDR <= (others => '0');
                        DATA <= x"0020"; -- 0020
                    end if;
                    if ( y = s5 ) then
                        DATA <= x"0020";
                    else
                        DATA <= (others => 'Z');
                    end if;
                    flash_rp <= '1';
                    OE <= '1';     
                    MT_CE <= '1';
                when s6 =>
                    if STS = '1' then
                        y <= s7;
                        flash_rp <= '1';
                        CE <= '1';
                        WE <= '1';
                        ADDR <= (others => 'Z');
                        DATA <= (others => 'Z');
                        OE <= '1';     
                        MT_CE <= '1';
                    end if;
                when s7 => -- redundant state
                  --if STS = '1' then
                        if STS = '1' then
                            y <= s8;
                            flash_rp <= '1';
                            CE <= '1';
                            WE <= '1';
                            ADDR <= (others => 'Z');
                            DATA <= (others => 'Z');
                            OE <= '1';     
                            MT_CE <= '1';
                        end if;
                  --end if;
                when s8 =>
                    if cycle_count >= w4 then
                        y <= s9;
                        cycle_count <= 0;
                        CE <= '1';
                        WE <= '1'; -- only 5 MSB is needed to select the blk address
                        ADDR <= (others => 'Z');
                    else
                        CE <= '0';
                        WE <= '0'; -- only 5 MSB is needed to select the blk address
                        ADDR <= (others => '0');
                        --DATA <= x"00D0";      -- 00D0
                        y <= s8;
                        cycle_count <= cycle_count + 1;
                    end if;
                        if ( y = s8 ) then
                                DATA <= x"00D0";
                        else
                                DATA <= (others => 'Z');
                        end if;
                        flash_rp <= '1';
                        OE <= '1';     
                        MT_CE <= '1';
                when s9 =>
                    if STS = '1' then
                        y <= s10;
                        cycle_count <= 0;
                        flash_rp <= '1';
                        CE <= '1';
                        WE <= '1';
                        ADDR <= (others => 'Z');
                        DATA <= (others => 'Z');
                        OE <= '1';     
                        MT_CE <= '1';
                    end if; -- end erasing 0th block
                when s10 => -- starting writing
                    if STS = '1' then
                        y <= s11; -- dont forget to add "if newData == 1"
                        flash_rp <= '1';
                        CE <= '1';
                        WE <= '1';
                        ADDR <= (others => 'Z');
                        DATA <= (others => 'Z');
                        OE <= '1';     
                        MT_CE <= '1';
                    end if;
                when s11 =>
                    if cycle_count >= w4 then
                        y <= s12;
                        cycle_count <= 0;
                        CE <= '1';
                        WE <= '1'; -- only 5 MSB is needed to select the blk address
                    else
                        y <= s11;
                        cycle_count <= cycle_count + 1;
                        CE <= '0';
                        WE <= '0';
                    end if;
                    if y = s11 then
                        DATA <= x"0010";
                    else
                        DATA <= (others => 'Z');
                    end if;
                    flash_rp <= '1';
                    ADDR <= (others => 'Z');
                    OE <= '1';     
                    MT_CE <= '1';                                  
                when s12 =>
                    if STS = '1' then
                        y <= s13;
                        flash_rp <= '1';
                        CE <= '1';
                        WE <= '1';
                        ADDR <= (others => 'Z');
                        DATA <= (others => 'Z');
                        OE <= '1';     
                        MT_CE <= '1';
                    end if;
                when s13 => -- redundant state
                        if STS = '1' then
                            y <= s14;
                            flash_rp <= '1';
                            CE <= '1';
                            WE <= '1';
                            ADDR <= (others => 'Z');
                            DATA <= (others => 'Z');
                            OE <= '1';     
                            MT_CE <= '1';
                        end if;
                when s14 =>
                -- writing PA and PD
                    if cycle_count >= w4 then
                        y <= s15;
                        cycle_count <= 0;
                        CE <= '1';
                        WE <= '1'; -- only 5 MSB is needed to select the blk address
                        ADDR <= (others => 'Z');
                    else
                        y <= s14;
                        cycle_count <= cycle_count + 1;
                        CE <= '0';
                        WE <= '0';
                        ADDR <= address; --address writing to 1st address, not the 0th address -- ignore the 0th bit of address                       
                    end if;
                    if ( y = s14 ) then
                        DATA(7 downto 0)<= data_bpm_in; --  does not work if the 2nd Most significant hex value is 'A'
                    else
                        DATA <= (others => 'Z');
                    end if;
                    flash_rp <= '1';
                    OE <= '1';     
                    MT_CE <= '1';
                when s15 => -- end writing
                if STS = '1' then
                        y <= s16;
                        flash_rp <= '1';
                        CE <= '1';
                        WE <= '1';
                        ADDR <= (others => 'Z');
                        DATA <= (others => 'Z');
                        OE <= '1';     
                        MT_CE <= '1';
                    end if;
                when s16 =>
                    y <= s17;
                when s17 =>
                    if cycle_count >= w4 then
                        y <= s18;
                        cycle_count <= 0;
                        CE <= '1';
                        WE <= '1';
                    else
                        y <= s17;
                        cycle_count <= cycle_count + 1;
                       
                        CE <= '0';
                        WE <= '0';
                      --ADDR <= "0000000000000000000010";
                    --  DATA <= x"00FF";--
                    end if;
                    if ( y = s17 ) then
                        DATA <= x"00FF";
                    else
                        DATA <= (others => 'Z');
                    end if;
                    flash_rp <= '1';
                    ADDR <= (others => 'Z');
                    OE <= '1';     
                    MT_CE <= '1';
                when s18 =>
                    if STS = '1' then
                        y <= s19;
                        flash_rp <= '1';
                        CE <= '1';
                        WE <= '1';
                        ADDR <= (others => 'Z');
                        DATA <= (others => 'Z');
                        OE <= '1';     
                        MT_CE <= '1';
                    end if;
                when s19 =>
                    if cycle_count >= r2 then  -- && DATA != "ZZZZZZZZZZZ"?
                      --y <= s20;
                        cycle_count <= 0;
                        reg_data <= DATA(7 downto 0);
                        ADDR <= (others => 'Z');
                       
                        if address = "00000000000000001111111" then
                                address := (others => '0');
                                y <= S19;
                        else
                                y <= S20;
                        end if;
                       
                        CE <= '1';
                        OE <= '1';
                    else
                        y <= s19;
                        cycle_count <= cycle_count + 1;
                        ADDR <= address ;-- address(7 downto 0) "000000000000000" & SW
                       
                        DATA <= (others => 'Z');
                        CE <= '0';
                        OE <= '0';
                    end if;
                   
--                          if DATA(7 downto 0) = x"DD" then
--                              reg_data <= DATA(7 downto 0);
--                          end if;
                    flash_rp <= '1';
                    WE <= '1';
                    MT_CE <= '1';
                when s20 => -- data should be available from read
                    -- do nth
                    if STS = '1' and newData = '1' then
                        if cycle_count >= 10 then
                            y <= s10;
                            flash_rp <= '1';
                            CE <= '1';
                            WE <= '1';
                            ADDR <= (others => 'Z');
                            DATA <= (others => 'Z');
                            OE <= '1';
                            MT_CE <= '1';--00000111111111111111111
                            if address = "00000111111111111111111" then
                                    address := (others => '0');
                                    y <= s21;
                            end if;
                            address := std_logic_vector( unsigned(address) + 1 );
                            if upCount = "11111111" then
                                    upCount := (others => '0');
                            end if;
                            upCount := std_logic_vector( unsigned(upCount) + 1 );
                            cycle_count <= 0;
                        else
                            cycle_count <= cycle_count + 1;
                        end if;
                    end if;
                when s21 =>
                     -- yolo state
                when others =>
                    null;
                end case;
            end if;
    end process;
    led_out <= reg_data;
end Behavioral;
