library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity memory is
    port(
    clock        : in      std_logic; -- CLK
    reset        : in      std_logic;
    Addr_out     : out     std_logic_vector(23 downto 1); -- ADDR
    Data         : inout   std_logic_vector(15 downto 0); -- DATA
    Data_bpm     : in      std_logic_vector( 7 downto 0);
    Data_bpm_out : out     std_logic_vector(7 downto 0);
    OE           : out     std_logic; -- OE(Output enabled)
    WE           : out     std_logic; -- WE(Write enabled)--Active low/0 default read
    MT_CE        : out     std_logic; -- MT-CE
    STS          : in      std_logic; -- STATUS
    RP           : out     std_logic := '1'; -- RP#/Reset -- Don't want to reset
    CE           : out     std_logic; -- CHIP ENABLE
	a_out		  : out     std_logic_vector(22 downto 0);
	state_out    : out     std_logic_vector(5 downto 0);
	sclk_o       : out     std_logic;
	rgBtn 		 : in std_logic_vector(3 downto 0);
	sw_in        : in      std_logic_vector ( 7 downto 0);
	led_out		 : out	  std_logic_vector(5 downto 0);
	temp         : out     std_logic_vector(15 downto 0)

    );
end memory;

architecture Behavioral of memory is
    Type state is (init_mem,erase_mem,write_mem,read_mem,idle_mem,write_cycle,read_cycle,wait_state);
    signal cur_state          : state;
    signal return_state       : state;
    signal reg_data  : std_logic_vector(7 downto 0) := (others => '0');
    Shared variable addr_read  : std_logic_vector(23 downto 1):=(others => '0');
    signal sclk	   	: std_logic:= '0';
    shared variable clk_divider      : integer range 0 to 3 := 0;
    shared variable cycle_count      : integer range 0 to 50000000 := 0; -- 
    signal stage              : integer range 0 to 5 := 0;
    signal command_data       : std_logic_vector(15 downto 0) := (others => '0');
    signal address_data       : std_logic_vector(23 downto 1):= (others => '0');
    signal addr_write           : std_logic_vector(23 downto 1) := (others => '0');
	signal read_complete		: std_logic := '0';
	signal state_sig          : std_logic_vector(5 downto 0) := (others => '0');
	signal last               : std_logic_vector(15 downto 0) := (others => '0');
	signal one_second         : integer range 0 to 26000000 := 0;
	signal read_flag          : std_logic := '0';
	signal do_next 			  :std_logic;
	signal WE_sig				  :std_logic;
	signal OE_sig				  :std_logic;
	signal CE_sig				  :std_logic;
	signal mode_sel			  :std_logic;
begin   

--Data_bpm_out <= std_logic_vector(to_unsigned(cycle_count, Data_bpm_out'length));
Data <= command_data when (WE_sig = '0' or OE_sig ='0') else (others => 'Z');
do_next <= rgBtn(1);
mode_sel <= sw_in(0);
led_out(5 downto 0) <= state_sig(5 downto 0);
WE <= WE_sig;
OE <= OE_sig;
CE <= CE_sig;
process(clock)
begin
       if(clock'event and clock = '1') then
        	clk_divider := clk_divider + 1;
        	if (clk_divider = 3) then
            	clk_divider := 0;
            	sclk <= not sclk;
        	end if;
    	end if;
end process;

process(sclk,rgBtn(0))
begin
	if rgBtn(0) = '1' then
        --reset all signals
		  cur_state <= init_mem;
        Addr_out <= (others => 'Z');
        Data <= (others => 'Z');  
    elsif (rising_edge(sclk)) then
        case cur_state is  
        
            when init_mem =>
               CE_sig <= '1';
                WE_sig <= '1';
                OE_sig <= '1';                
                MT_CE <= '1';
                RP <= '1';
                Data <= (others => 'Z');
                Addr_out <= (others => 'Z');
                cur_state <= erase_mem;
                stage <= 0;
                state_sig <= "000000";
                if(cycle_count < 12500000) then
                    RP <= '0';
                    cycle_count := cycle_count+1;
                    cur_state <= init_mem;
                end if;
                
            when erase_mem =>
                cycle_count := 0;
                return_state <= erase_mem;
                CE_sig <= '1';
                WE_sig <= '1';
                OE_sig <= '1';                
                MT_CE <= '1';
                RP <= '1';
                stage <= stage + 1;
                if(stage = 0) then
						  state_sig <= "000001";
                    if(STS = '0') then
                        stage <= 0;
                    end if;
                elsif(stage = 1) then
                    state_sig <= "000010";
                    address_data <= (others => 'Z');
                    command_data <= x"0020"; --s5/s6
                    cur_state <= write_cycle;
				elsif(stage = 2) then  
							state_sig <= "000011";				
					if(STS = '1') then        
                        cur_state <= wait_state;   
                        stage <= 3;            --s7
					else    
						stage <= 2;  
                    end if;          
                elsif(stage = 3) then
                    state_sig <= "000100";
                    address_data <= (others => '0');
                    command_data <= x"00D0"; --s8
                    cur_state <= write_cycle;  --s9/s10
                elsif(stage = 4) then 
                    state_sig <= "000101";
                    if(STS = '1') then        
                        cur_state <= idle_mem;   
                        stage <= 0;
							else    
							stage <= stage;
                    --else
                    end if;
                --if(stage = 4) then 
                    --state_sig <= "000100";
                    --address_data <= (others => 'Z');
                    --command_data <= (others => 'Z');                    
                    --cur_state <= wait_cycle;     
                end if;
                
            when idle_mem =>
                state_sig <= "000110";
                CE_sig <= '1';
                WE_sig <= '1';
                OE_sig <= '1';                
                MT_CE <= '1';
                RP <= '1';
				stage <= 0;
                if(do_next = '1') then
                    --Write mode
                    --if(mode_sel = '0') then
                        cur_state <= write_mem;
                   -- else
                        --cur_state <= read_mem;
                    --end if;
                end if;
                
                                
                
            when write_mem =>
				cycle_count := 0;
                return_state <= write_mem;
                OE_sig <= '1';                
                MT_CE <= '1';
                RP <= '1';
                stage <= stage + 1;
                if(stage = 0) then
                    state_sig <= "000111";
                    Addr_out <= addr_write;
                    command_data <= x"0040"; --s11
                    cur_state <= write_cycle; --s12
				elsif(stage = 1) then
						state_sig <= "001000";
                    if(STS = '1') then        
                        cur_state <= wait_state;   
                        stage <= 2;            --s7
					else    
						stage <= stage;  
                    end if; 						 
                elsif(stage = 2) then
                    state_sig <= "001001";
                    Addr_out <= addr_write;
                    --Data <= (others => '0');
                    command_data <= "0000000000000111";
                    cur_state <= write_cycle;
                elsif(stage = 3) then
                    state_sig <= "001010";
                    if(STS = '1') then     
                        cur_state <= idle_mem;   
                        stage <= 0;
                    else    
						stage <= stage;
                    --else
                    end if;
					 end if;
					 
            when read_mem =>
				cycle_count := 0;
                return_state <= read_mem;
                WE_sig <= '1';               
                MT_CE <= '1';
                RP <= '1';
                stage <= stage + 1;
                if(stage = 1) then
					     --enter read array
                    state_sig <= "001011";
                    address_data <= (others => 'Z');
                    command_data <= x"00FF";
                    cur_state <= write_cycle;
                elsif(stage = 2 ) then
					     state_sig <= "001100";
					     if(STS = '1') then     
                        cur_state <= wait_state;   
                        stage <= 3;
                    else    
							   stage <= stage;
                    end if;    
                elsif(stage = 3) then	
					     address_data <= addr_read; 
					     command_data <= (others => 'Z');						  
						  state_sig <= "001110";					 
						  cur_state <= read_cycle;							  
					 elsif( stage = 4) then
						  address_data <= addr_read;  							  
						  cur_state <= read_cycle;						 
                    state_sig <= "001111";                    						  
					 elsif(stage = 5) then	
					     reg_data <= Data (7 downto 0);				     
						  CE_sig <= '1';
						  OE_sig <= '1';
						  address_data <= addr_read; 
						  stage <= 0;
                    cur_state <= idle_mem;                     
                end if;           
                
            when write_cycle =>
                --Data <= command_data;
					 --Addr_out <= address_data;
                CE_sig <= '0';
                WE_sig <= '0';     
                --state_sig <= "110000";	
				    cycle_count := cycle_count +1;
				    cur_state <= write_cycle;
				if(cycle_count = 1) then                     
					WE_sig <= '1'; 
					CE_sig <= '1';
					cur_state <= return_state;
				end if;
                
            when read_cycle =>
                --Data <= command_data;
                Addr_out <= address_data;
                CE_sig <= '0';
                OE_sig <= '0'; 
                cur_state <= return_state; 
					 
				when wait_state =>
                    CE_sig <= '1';
                    WE_sig <= '1';
                    OE_sig <= '1';                
                    MT_CE <= '1';
                    RP <= '1';
                    Addr_out <= (others => 'Z');
                    Data <= (others => 'Z');
					cur_state <= return_state;
					 
			when others => 
				state_sig <= "011111";
				null;
        end case;
end if;
end process;
end Behavioral;
