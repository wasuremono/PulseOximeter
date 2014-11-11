library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity adc_comm is
    port(   clk      : in  std_logic;    --nexys clock(currently 100MHZ)
            rst      : in  std_logic;    --reset
            sclk_out : out std_logic;    --MCP3002 clock
            cs       : out  std_logic;    --MCP3002 Chip Select
            din      : out  std_logic;    --MCP3002 din
            dout     : in std_logic;    --MCP3002 dout
			--adc_read : in std_logic;
            data_out : out std_logic_vector(9 downto 0); --10bit data output  
				count_out: out std_logic_vector(3 downto 0)
        );
end adc_comm;
 
architecture behavioral of adc_comm is  
    --signal cs        : std_logic;
    --signal data_out  : std_logic_vector(9 downto 0);
    signal sclk      : std_logic :='1';
    --signal din       : std_logic;
    --signal dout      : std_logic;
    signal count     : integer := 1;
    signal count16   : std_logic_vector(3 downto 0):="0000";--16 counter
    signal data      : std_logic_vector(9 downto 0):="0000000000";
	signal adc_en	 :std_logic := '0';
begin
    --100MHz to 1.2MHz
    count_out <= count16;
	
    process(clk)
    begin
        if(clk'event and clk = '1') then
            count <= count + 1;
            if(count = 420000) then
                sclk <= NOT sclk;
                count <= 1;
            end if;
        end if;
    end process;

    process(sclk)
    begin
			if(rising_edge(sclk)) then
				count16 <=  count16 + '1';
				if(count16 >= "0110") then
					data(9 downto 1) <= data(8 downto 0);
					data(0) <= dout;
				else
					data <= data;
				end if;
				if(count16 = "0000") then
					data_out <= data;
					
				end if;  
			end if;
			if (falling_edge(sclk)) then
				if(count16 = "0000") then
						cs  <= '1';
						din <= '0';			
				elsif(count16 = "0001") then
					cs  <= '0';
					din <= '1';
				elsif(count16 = "0010") then
					cs  <= '0';
					din <= '1';
				elsif(count16 = "0011") then
					cs  <= '0';
					din <= '0';
				elsif(count16 = "0100") then
					 cs <= '0';
					 din <= '1';
				else 
					cs  <= '0';
					din <= '0';
				end if;	
			end if;
		end process;
		sclk_out <= sclk;
		  
end behavioral;