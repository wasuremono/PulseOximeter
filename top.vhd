----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:18:08 09/08/2014 
-- Design Name: 
-- Module Name:    top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
	port(clock	 :in std_logic;
		  disp : out std_logic_vector(0 to 7);
		  seg	: out std_logic_vector(3 downto 0);
		  csel :out std_logic;
		  din1 :out std_logic;
		  dout1 :in std_logic;
		  cout: out std_logic;
		  sw_in: in std_logic_vector(7 downto 0);
		  astb : in std_logic;
		  dstb : in std_logic;
		  pwr	 : in std_logic;
		  red_on,ir_on: out std_logic;
		  pdb		: inout std_logic_vector(7 downto 0);
        pwait 	: out std_logic;
		  led_out : out std_logic_vector(7 downto 0);
		  rgLed	: out std_logic_vector(7 downto 0); 
		rgSwt	: in std_logic_vector(7 downto 0);
		rgBtn	: in std_logic_vector(4 downto 0);
		btn		: in std_logic;
		ldg		: out std_logic;
		led		: out std_logic;
		Addr_out : out std_logic_vector(22 downto 0);
		port_data: inout std_logic_vector(15 downto 0);
		OE       : out std_logic;
		WE       : out std_logic;
		MT_CE    : out std_logic;
		STS      : in std_logic;
		RP       : out std_logic;
		CE       : out std_logic
		
	);
		
end top;

architecture Behavioral of top is
component epp
	PORT(		
		mclk 	: in std_logic;
        pdb		: inout std_logic_vector(7 downto 0);
        astb 	: in std_logic;
        dstb 	: in std_logic;
        pwr 	: in std_logic;
		data_in_ppg : in std_logic_vector(7 downto 0);
		data_in_bpm : in std_logic_vector(7 downto 0);
		data_in_sat : in std_logic_vector(7 downto 0);
        pwait 	: out std_logic;
		rgLed	: out std_logic_vector(7 downto 0); 
		rgSwt	: in std_logic_vector(7 downto 0);
		rgBtn	: in std_logic_vector(4 downto 0);
		btn		: in std_logic;
		ldg		: out std_logic;
		led		: out std_logic
	

		  );
end component;
component hysteresis is
	 Port (
		clk : in std_logic;
		led_sel : in std_logic;
		led_change : in std_logic;
		data_in : in std_logic_vector(9 downto 0);
		ir_out	: out std_logic_vector(9 downto 0);
		red_out	: out std_logic_vector(9 downto 0);
		data_out : out std_logic_vector(9 downto 0)
	);
end component;
component adc_comm
	PORT(clk,rst,dout :in std_logic;
			sclk_out,cs,din :out std_logic;
			data_out		:out std_logic_vector(9 downto 0);
			count_out	:out std_logic_vector(3 downto 0)
			);
end component;
component bcd7seg
	PORT(sw_in		:in std_logic_vector(9 downto 0);
		 set_mode	:in std_logic;
		 segdisp_out	:out std_logic_vector(0 to 7);
		  clk50in	:in std_logic;
		  seg_sel	:out std_logic_vector(3 downto 0)
		  );
end component;
component LED_Control
	port( clk		:	in std_logic;
		  red_on    :	out std_logic;
		  led_change:  out std_logic;
		  ir_on		:	out std_logic;
		  adc_read  :	out std_logic
        );
end component;
component maths is
port (clk : in std_logic;
		  o_sel	: in std_logic;
        data_i : in std_logic_vector(9 downto 0);
        data_o : out std_logic_vector(9 downto 0);		
		ir_in	: in std_logic_vector(9 downto 0);
		red_in	: in std_logic_vector(9 downto 0);
		  set_mode: out std_logic;
		  sw_in : in std_logic
     );
end component;
component vrms is
    port( clock 	: in std_logic;
		  data_red	: in std_logic_vector(9 downto 0);
		  data_ir	: in std_logic_vector(9 downto 0);
		  vrms_red	: out std_logic_vector(9 downto 0);
		  vrms_ir	: out std_logic_vector(9 downto 0)
        );
end component;

component memory is
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
	 sw_in        : in      std_logic;
	 a_out		  : out     std_logic_vector (22 downto 0);
	 temp         : out     std_logic_vector(15 downto 0)
    );
end component;


signal data_in:std_logic_vector(9 downto 0);
signal count:std_logic_vector(3 downto 0);
signal d :std_logic;
signal adc_read: std_logic;
signal data_o: std_logic_vector(9 downto 0);
signal set_mode: std_logic;
signal piss: std_logic_vector(9 downto 0);
signal red_sig : std_logic_vector(9 downto 0);
signal ir_sig : std_logic_vector(9 downto 0);
signal led_change_sig : std_logic;
signal data_out_ppg: std_logic_vector(9 downto 0) := "0000000000";
signal data_out_bpm: std_logic_vector(9 downto 0) := "0000000000";
signal data_out_sat: std_logic_vector(9 downto 0) := "0000000000";
signal led_sel: std_logic;
signal val_sel : std_logic_vector(9 downto 0) := "0000000000";
signal mem_test_bpm : std_logic_vector(7 downto 0) := "00000000";
signal mem_extend_bpm : std_logic_vector(9 downto 0) := "0000000000";
signal mem_out_last   : std_logic_vector(15 downto 0) := (others => '0');
signal memcount		 : std_logic_vector(22 downto 0) := (others => '0');
begin
	mem_extend_bpm <= "00" & mem_test_bpm;
	red_on <=  led_sel;
	val_sel <= data_out_sat when sw_in(0) = '0' else data_out_bpm;
	led_out <= memcount(7 downto 0);
   --led_out(7) <= '0';
   --led_out(6) <= '1' when data_out_ppg > "1011101110" else '0';
   --led_out(5) <= '1' when data_out_ppg > "1010001010" else '0';	
	--led_out(4) <= '1' when data_out_ppg > "1000100110" else '0';	
	--led_out(3) <= '1' when data_out_ppg > "0111000010" else '0';
	--led_out(2) <= '1' when data_out_ppg > "0101011110" else '0';
	--led_out(1) <= '1' when data_out_ppg > "0011111010" else '0';
	--led_out(0) <= '1' when data_out_ppg > "0010010110" else '0';
   epp1: epp PORT MAP(mclk => clock, pdb => pdb, astb => astb,data_in_ppg => data_out_ppg(9 downto 2), data_in_bpm => data_out_bpm (7 downto 0), data_in_sat => data_out_sat(7 downto 0), dstb => dstb, pwr => pwr, pwait => pwait, rgLed => rgLed, rgSwt => rgSwt, rgBtn =>rgBtn, btn =>btn, ldg=>ldg, led=>led) ;
	bcd: bcd7seg PORT MAP (sw_in => mem_out_last (9 downto 0),segdisp_out => disp,clk50in => clock, seg_sel =>seg,set_mode => sw_in(0));
	adc: adc_comm PORT MAP (clk => clock,rst =>'0',cs => csel,sclk_out => cout,din => din1,dout => dout1, data_out => data_out_ppg, count_out => count);
	--led_out <= data_in(9 downto 2);
	control: LED_Control PORT MAP(clk => clock,led_change => led_change_sig,adc_read=>adc_read, red_on => led_sel, ir_on=> ir_on);
   math: maths PORT MAP(clk => clock,o_sel => sw_in(7), data_i => data_in, data_o => data_out_sat,red_in => red_sig, ir_in => ir_sig, set_mode => set_mode,sw_in => sw_in(0));
	hysteresi: hysteresis PORT MAP(clk => clock,led_sel =>led_sel,led_change=>led_change_sig, data_in => data_out_ppg,ir_out=>ir_sig,red_out=>red_sig,data_out => data_out_bpm);					
	memory1: memory PORT MAP(a_out =>memcount,clk => clock, reset=> sw_in(4), Addr_out => Addr_out, Data => port_data, Data_bpm => data_out_bpm (7 downto 0), Data_bpm_out => mem_test_bpm, OE => OE, WE => WE, MT_CE => MT_CE, STS => STS, CE => CE, RP => RP, sw_in => sw_in(6), temp => mem_out_last );
end Behavioral;

