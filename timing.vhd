library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;

-- Take a sample of 2 seconds 
-- Find top value 
-- Consider this to be the highest value possile
-- Take 50% of this to be the high value in the hysteresis loop
-- Take 12.5% of this to be the low value in the hysteresis loop
-- Sample every 10 ms, count 

entity timing is
	 Port (
		clk : in std_logic;
		red_led	:	out std_logic;
		ir_led	:		out std_logic;
		data_en	:	out std_logic;
	);
end hysteresis;

architecture Behavioral of timing is
	begin


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


