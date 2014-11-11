library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity memory is
    port(
    clk        : in      std_logic; -- CLK
    reset        : in      std_logic;
    Addr_out     : out     std_logic_vector(22 downto 0); -- ADDR
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
	sw_in        : in      std_logic;
	temp         : out     std_logic_vector(15 downto 0)

    );
end memory;

architecture Behavioral of memory is
    Type state is (init_mem,reset_state, write_state, read_state,erase_state, error_state, wait_state, full_write, full_read, status_state, full_erase);
    signal cur_state          : state := full_erase;
    signal return_state       : state;
    shared variable reg_data  : std_logic_vector(7 downto 0) := (others => '0');
    Shared variable addr_sig  : std_logic_vector(22 downto 0)   :=(others => '0');
    signal sclk	   	: std_logic:= '0';
    shared variable clk_divider      : integer range 0 to 3 := 0;
    shared variable cycle_count      : integer range 0 to 20 := 0; -- Read/Write Cycle
    signal stage              : integer range 0 to 4 := 0;
    signal command_data       : std_logic_vector(15 downto 0) := (others => '0');
    signal address_data       : std_logic_vector(22 downto 0):= (others => '0');
    signal addr_sel           : std_logic_vector(22 downto 0) := (others => '0');
	signal read_complete		: std_logic := '0';
	signal state_sig          : std_logic_vector(5 downto 0) := (others => '0');
	signal last               : std_logic_vector(15 downto 0) := (others => '0');
	signal one_second         : integer range 0 to 26000000 := 0;
	signal read_flag          : std_logic := '0';
begin   

--Data_bpm_out <= std_logic_vector(to_unsigned(cycle_count, Data_bpm_out'length));
Data_bpm_out <= reg_data;
last <= Data when read_flag = '1'  else last;
temp <= last;
sclk_o <= sclk;
state_out <= state_sig;
a_out <= "00000000000000000" & state_sig;

process(clk)
begin
       if(clk'event and clk = '1') then
        	clk_divider := clk_divider + 1;
        	if (clk_divider = 3) then
            	clk_divider := 0;
            	sclk <= not sclk;
        	end if;
    	end if;
end process;

process(sclk,reset)
begin
	if reset = '1' then
        --reset all signals
		cur_state <= init_mem;
        Addr_out <= (others => 'Z');
        Data <= (others => 'Z');  
    elsif (rising_edge(sclk)) then
        case cur_state is  
        
            when init_mem =>
                CE <= '1';
                WE <= '1';
                OE <= '1';                
                MT_CE <= '1';
                RP <= '0';
                Data <= (others => 'Z');
                Addr_out <= (others => 'Z');
                cur_state <= erase_mem;
                stage <= 0;
                state_sig <= "000000";
                
                
            when erase_mem =>
                return_state <= erase_mem;
                CE <= '1';
                WE <= '1';
                OE <= '1';                
                MT_CE <= '1';
                RP <= '1';
                stage <= stage + 1;
                if(stage = 1) then
                    state_sig <= "000001";
                    address_data <= (others => 'Z');
                    command_data <= x"0020";
                    cur_state <= write_cycle;
                elsif(stage = 2) then
                    state_sig <= "000010";
                    address_data <= (others => '0');
                    command_data <= x"00D0";
                    cur_state <= write_cycle;
                elsif(stage = 3) then
                    state_sig <= "000011";
                    if(STS = 0) then
                        stage <= stage;
                    else
                        state_sig <= "000100";
                        cur_state <= wait_cycle;   
                        stage <= 0;
                    end if;
                --if(stage = 4) then 
                    --state_sig <= "000100";
                    --address_data <= (others => 'Z');
                    --command_data <= (others => 'Z');                    
                    --cur_state <= wait_cycle;     
                end if;
                
            when idle_mem =>
                state_sig <= "000101";
                CE <= '1';
                WE <= '1';
                OE <= '1';                
                MT_CE <= '1';
                RP <= '1';
                Addr_out <= addr_read;
                Data <= (others => 'Z');
                if(do_next = 1) then
                    --Write mode
                    if(mode_sel = 0) then
                        cur_state <= write_mem;
                    else
                        cur_state <= read_mem;
                    end if;
                end if;
                
                                
                
            when write_mem
                return_state <= write_mem;
                OE <= '1';                
                MT_CE <= '1';
                RP <= '1';
                stage <= stage + 1;
                if(stage = 1) then
                    state_sig <= "000110";
                    address_data <= (others => 'Z');
                    command_data <= x"0040";
                    cur_state <= write_cycle;
                elsif(stage = 2) then
                    state_sig <= "000111";
                    address_data <= addr_write;
                    command_data <= addr_write;
                    cur_state <= write_cycle;
                elsif(stage = 3) then
                    state_sig <= "001000";
                    if(STS = 1) then
                        stage <= stage;
                    else
                        state_sig <= "001001";
                        cur_state <= idle_mem;   
                        stage <= 0;
                    end if;    
                end if;
                
            when read_mem
                return_state <= read_mem;
                WE <= '1';               
                MT_CE <= '1';
                RP <= '1';
                stage <= stage + 1;
                if(stage = 1) then
                    state_sig <= "001010";
                    address_data <= (others => 'Z');
                    command_data <= x"00FF";
                    cur_state <= write_cycle;
                elsif(stage < 2 ) then
                    state_sig <= "001011";
                    address_data <= addr_read;
                    command_data <= (others => 'Z');
                    cur_state <= read_cycle;
                elsif(stage = 2) then
                    state_sig <= "001100";
                    reg_data <= Data;
                    stage <= 0;
                    cur_state <= idle_mem;                     
                end if;           
                
            when write_cycle =>
                Data <= command_data;
                Addr_out <= address_data;
                CE <= '0';
                WE <= '0'; 
                cur_state <= return_state;   
                
            when read_cycle =>
                Data <= command_data;
                Addr_out <= address_data;
                CE <= '0';
                OE <= '0'; 
                cur_state <= return_state;   
						 
			when others => 
				state_sig <= "111111";
				null;
        end case;
end if;
end process;
end Behavioral;
