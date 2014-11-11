library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity LED_Control is
    port( clk		:	in std_logic;
		  red_on    :	out std_logic;
		  ir_on		:	out std_logic;
		  led_change:	out std_logic;
		  adc_read  :	out std_logic
        );
end LED_Control;
 
architecture behavioral of LED_Control is  
	signal count	: integer := 0;
	shared variable count300  : integer:= 0;
	signal ir_sig	 : std_logic := '1';
	signal red_sig	 : std_logic := '0';
	signal sclk		 : std_logic := '0';
	signal led_change_sig: std_logic := '0';
--internal clock of 1/ms = 1kHz
--change LED every 10ms
begin
	ir_on 	 <= ir_sig;
	red_on	 <= red_sig;
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
	
	process(sclk)
	begin
		if(sclk'event and sclk = '1') then
			count300 := count300 + 1;
			led_change_sig <= '0';
			if(count300 = 300) then
				ir_sig <= NOT ir_sig;
				red_sig <= NOT red_sig;
				count300 := 0;
				led_change_sig <= '1';
			end if;
		end if;
	end process;		
	
end behavioral;