library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity vrms is
    port( clock 	: in std_logic;
		  data_red	: in std_logic_vector(9 downto 0);
		  data_ir	: in std_logic_vector(9 downto 0);
		  vrms_red	: out std_logic_vector(9 downto 0);
		  vrms_ir	: out std_logic_vector(9 downto 0)
        );
end vrms;
 
architecture behavioral of vrms is  
	signal count		: integer := '0';
	signal cycle_count  : integet := '0';
	signal count_red	: integer := '0';
	signal count_ir     : integer := '0';
	signal min_red		: std_logic_vector(9 downto 0);
	signal max_red		: std_logic_vector(9 downto 0);
	signal min_ir		: std_logic_vector(9 downto 0);
	signal max_ir		: std_logic_vector(9 downto 0);
	
begin
	--Red is between clock counts of 0-100000, ir between 150000- 250000, blank between 250000-300000
	--count => 100000 = 1ms
	--400 cycle counts = 1.2s ==  time to calculate vrms
	process(clock)
		if clock'event and clock = '1' then
			count <= count + 1;
			
		end if;
    end process;
	if(count < 100000) then	
			count_red <= count_red + 1;
		elsif (count < 150000) then
		elsif (count < 250000) then	
			count_ir <= count_ir + 1;
		elsif (count < 300000) then
		elsif( count  = 300000) then
			count <= 0;
			cycle_count <= cycle_count + 1;
	end if;
	
end behavioral;