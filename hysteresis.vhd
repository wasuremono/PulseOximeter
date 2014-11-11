library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;

-- Take a sample of 2 seconds 
-- Find top value 
-- Consider this to be the highest value possible
-- Take 50% of this to be the hi value in the hysteresis loop
-- Take 12.5% of this to be the lo value in the hysteresis loop
-- Sample every 10 ms, count 

entity hysteresis is
	 Port (
		clk : in std_logic;
		led_sel : in std_logic;
		led_change:	in std_logic;
		data_in : in std_logic_vector(9 downto 0);
		ir_out	: out std_logic_vector(9 downto 0);
		red_out	: out std_logic_vector(9 downto 0);
		data_out : out std_logic_vector(9 downto 0)
	);
end hysteresis;

architecture Behavioral of hysteresis is
	signal count	: integer := 0;
	shared variable min		: std_logic_vector(9 downto 0) := "0110010000";
	shared variable hi		: std_logic_vector(9 downto 0) := "0000000000";
	shared variable lo		: std_logic_vector(9 downto 0) := "1111111111";
	shared variable max		: std_logic_vector(9 downto 0) := "1010111100";
	signal data    : std_logic_vector(9 downto 0);
	signal state	: integer := 1;
	shared variable interval: integer := 0;
	shared variable period  : integer := 0;
	signal beatState	: integer := 0;
	signal indexPeriod : integer := 0;
	signal sclk    : std_logic := '0';
	signal isBeat	: std_logic := '0';
	shared variable oneSec		: integer := 0;
	shared variable lastBPM    : integer := 0;
	shared variable currentBPM : integer := 0;
	
    signal avgBPM : std_logic_vector(9 downto 0):= "0000000000";
    signal avgPeriod : integer := 0;
	signal sumVals : std_logic_vector(10 downto 0):= "00000000000";
	signal modify  : std_logic := '0';
	signal updateBPM : std_logic := '0';
	signal periodvector  : std_logic_vector(9 downto 0):= "0000000000";
	type ram_t is array (0 to 125) of std_logic_vector(15 downto 0);
	signal ram : ram_t := (X"00F0",X"00E6",X"00DE",X"00D6",X"00CE",X"00C8",X"00C1",X"00BB",X"00B5",X"00B0",X"00AB",X"00A6",X"00A2",X"009D",X"0099",X"0096",X"0092",X"008E",X"008B",X"0088",X"0085",X"0082",X"007F",X"007D",X"007A",X"0078",X"0075",X"0073",X"0071",X"006F",X"006D",X"006B",X"0069",X"0067",X"0065",X"0064",X"0062",X"0060",X"005F",X"005D",X"005C",X"005A",X"0059",X"0058",X"0056",X"0055",X"0054",X"0053",X"0052",X"0051",X"0050",X"004E",X"004D",X"004C",X"004B",X"004B",X"004A",X"0049",X"0048",X"0047",X"0046",X"0045",X"0044",X"0044",X"0043",X"0042",X"0041",X"0041",X"0040",X"003F",X"003F",X"003E",X"003D",X"003D",X"003C",X"003C",X"003B",X"003A",X"003A",X"0039",X"0039",X"0038",X"0038",X"0037",X"0037",X"0036",X"0036",X"0035",X"0035",X"0034",X"0034",X"0033",X"0033",X"0032",X"0032",X"0032",X"0031",X"0031",X"0030",X"0030",X"0030",X"002F",X"002F",X"002E",X"002E",X"002E",X"002D",X"002D",X"002D",X"002C",X"002C",X"002C",X"002B",X"002B",X"002B",X"002A",X"002A",X"002A",X"0029",X"0029",X"0029",X"0029",X"0028",X"0028",X"0028",X"0028");
	begin

sumVals <= std_logic_vector(to_unsigned(lastBPM+currentBPM,sumVals'length)) when modify = '1' else sumVals;
avgBPM <= "0000000000" when lastBPM = 0 else "0" & sumVals(9 downto 1);
--indexPeriod <= avgPeriod - 25 when updateBPM = '1' else indexPeriod;

--indexPeriod <= period - 25; --if shit explodes look here
--data_out <= std_logic_vector(to_signed(indexPeriod, data_out'length));
data_out <= "0000000000" when period = 0 else avgBPM;--std_logic_vector(to_unsigned(lastBPM,data_out'length)); --ram(indexPeriod) (9 downto 0);
--data_out <= interval (9 downto 0);
--data_out <= data_in;
process(clk)
	begin
		if(clk'event and clk = '1') then
			count <= count + 1;
			if(count = 500000) then
				count <= 0;
				sclk <= NOT sclk;
			end if;
		end if;
end process;
process(sclk,led_sel)
	begin
		oneSec := oneSec + 1;
		if(oneSec = 100) then
			updateBPM <= '1';
			oneSec := 0;
		else 
			updateBPM <= '0';
		end if;
		-- Transitional states of the ppg
		if(rising_edge(sclk)) then
		--State 0 Sample
			if(state = 0) then
				if (data_in > hi) then 
					--max <= data_in;
				end if;
		--State 1 Measure
			elsif(state = 1) then
				if(led_change = '1') then
				--	min := data_in;
					hi := "0000000000";
					lo := "1111111111";
				end if;
				if(beatState = 0) then
					interval := interval + 1;
					if(data_in > min) then
						beatState <= 1;
						if(data_in > hi) then	
							hi := data_in;
						end if;
					end if;
                    if( interval > 175 ) then
                        if(data_in < hi) then
                            min := data_in;
							hi := "0000000000";
							lo := "1111111111";
                        end if;
                        interval := 0;
                        beatState <= 0;
                    end if;
				elsif(beatState = 1) then
					if(data_in < lo) then	
						lo :=  data_in;
					end if;
					if(data_in < min) then                        
						if (interval < 175) then 
							lastBPM :=  to_integer(unsigned(ram(period-25)(9 downto 0)));
                            currentBPM := to_integer(unsigned(ram(interval-25)(9 downto 0)));
                            if (period = 0) then
										  lastBPM := 0;
                                period := interval;
                            elsif (lastBPM - currentBPM > 15) then
                                modify <= '0';
                            elsif (lastBPM - currentBPM < -15) then
                                modify <= '0';                            
                            else 
                                period := interval;
                                modify <= '1';                                
                            end if;	                            
                        interval := 0;
                        beatState <= 0;                 
                        end if;
					elsif(data_in > min) then
						interval := interval + 1;
                        if( interval > 175 ) then
                            if(data_in < max) then
                                min := data_in;
								hi := "0000000000";
								lo := "1111111111";
                            end if;
                            interval := 0;
                            beatState <= 0;
                        end if;
					end if;
				end if;
			end if;

		end if;
		--
			
end process;

process(led_sel)
	variable vDiff : std_logic_vector(9 downto 0):= "0000000000";
	variable intHi : integer := 0;
	variable intLo : integer:= 0;
	
	begin
		intHi := to_integer(unsigned(hi));
		intLo := to_integer(unsigned(lo));
		vDiff := std_logic_vector(to_unsigned(intHi - intLo,vDiff'length));
	--0 is red 1 is ir
	if(led_Sel = '0') then
		ir_out <= vDiff;		
	else
		red_out <= vDiff;	
	end if;
end process;
end Behavioral;

