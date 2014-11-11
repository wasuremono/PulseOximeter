library IEEE;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY bcd7seg IS
	port(sw_in :IN STD_LOGIC_VECTOR(9 downto 0);
	        segdisp_out: out std_logic_vector(0 to 7);
		clk50in :in std_logic;
		seg_sel: OUT STD_LOGIC_VECTOR(3 downto 0);
		set_mode: in std_logic
		);		
END bcd7seg;

Architecture behavioral OF bcd7seg IS
	SIGNAL bcd: STD_logic_vector(3 downto 0);
	SIGNAL leds: STD_logic_vector(7 downto 0);
	SIGNAL digit: STD_logic_vector(3 downto 0);
	SIGNAL clk: std_logic;
	SIGNAL hundred: INTEGER range 0 to 9;
	SIGNAL ten: INTEGER range 0 to 9;
	SIGNAL unit: INTEGER range 0 to 9;
	SIGNAL dispcount: INTEGER range 0 to 3;
   SIGNAL counter: INTEGER range 0 to 1000000;
	SIGNAL sum: INTEGER range 0 to 999 := 0;
	SIGNAL target: INTEGER range 0 to 999 := 0;
	SIGNAL target_prev: INTEGER range 0 to 999 := 0;
	SIGNAL letter: std_logic_vector(7 downto 0);
begin

		clk <= clk50in;		
		digit <= "1110" when dispcount = 0 else
		"1101" when dispcount = 1 else
		"1011" when dispcount = 2 else
		"0111";
					--p "00110000"
		letter <=  "11000000" when set_mode = '1' else
					--s "01001000"
					 "11000100"when  set_mode = '0'
					;
					
		leds <= letter when dispcount = 3 else
		"00000011" when bcd = "0000" else
		"10011111"  when bcd = "0001" else
		"00100101" when bcd = "0010" else
		"00001101" when bcd = "0011" else
		"10011001" when bcd = "0100" else 
		"01001001" when bcd = "0101" else 
		"01000001" when bcd = "0110" else 
		"00011111" when bcd = "0111" else  
		"00000001" when bcd = "1000" else 
		"00001001" when bcd = "1001"		
		; 
		
		
	PROCESS(clk)
	BEGIN	
		segdisp_out <= leds;
		seg_sel <= digit;
		if clk'event and clk = '1' then
			-- Increment display counter
			counter <= counter + 1;
			if (counter = 100000) then
				dispcount <= dispcount + 1;
				counter <= 0;
			end if;	 
		end if;
	END PROCESS;
	
	
	PROCESS(clk)
	BEGIN	
		if clk'event and clk = '1' then
				target <= to_integer(unsigned(sw_in));
				if (target_prev /= target) then
					hundred <= 0;
					ten <= 0;
					unit <= 0;
					sum <= 0;
					target_prev <= target;
				elsif ((target - sum - 100)  >= 0) then
					hundred <= hundred + 1;
					sum <= sum + 100;
				elsif((target  - sum - 10) >= 0) then
					ten <= ten + 1;
					sum <= sum + 10;
				elsif ((target  - sum - 1) >= 0)then 
					unit <= unit + 1;
					sum <= sum + 1;
				else 
				case dispcount is
				  when 0 =>  bcd <=  std_logic_vector(to_unsigned(unit, bcd'length)) ;
				  when 1 =>  bcd <= std_logic_vector(to_unsigned(ten, bcd'length));
				  when 2 =>  bcd <= std_logic_vector(to_unsigned(hundred, bcd'length));
				  when others => bcd <= "0000";
				end case;
				end if;
		end if;
	END PROCESS;
END behavioral;