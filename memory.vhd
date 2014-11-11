----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    07:48:51 10/23/2014 
-- Design Name: 
-- Module Name:    memory - behaviour 
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
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;


entity memory is
    port(clock           : in    std_logic; -- CLK
         address         : out   std_logic_vector(23 downto 0); -- ADDR
         data            : inout std_logic_vector(15 downto 0); -- DATA
         data_bpm_in     : in    std_logic_vector( 7 downto 0);
         output_enable   : in    std_logic; -- OE
         write_enable    : in    std_logic; -- WE
         ram_chip_enable : in    std_logic; -- MT-CE
         status          : in    std_logic; -- ST
         reset           : in    std_logic := '1'; -- RP -- Don't want to reset 
         chip_enable     : in    std_logic; -- CE
        );
end memory;

architecture behaviour of memory is
    type state is (reset_state, read_array, read_status, write_state, erase_state, increment_state error_state);
    signal current_state               : state := reset_state;
    signal next_state, meta_next_state : state;
begin
    process(clock, data)
    begin
        if reset = '0' then
            current_state <= reset_state;
            next_state <= reset_state;
        elsif clock'event and clock = '1' then
            if current_state /= reset_state then
                if output_enable = '1' then
                    next_state <= read_status;
                elsif write_enable = '1' then
                    next_state <= write_state;
                else
                    next_state <= erase_state;
                end if;
            end if;
        end if;
    end process;
    
    process
    begin
        -- check that the chip isn't busy before doing anything!
        if status = '0' then
            address <= (others => 'Z'); -- this needs to go elsewhere
            data    <= (others => 'Z'); -- this needs to go elsewhere
            
            case current_state is
                when reset_state => -- reset state / first state
                    address <= (others => '0');
                when read_array  =>
                    -- meaningful things here
                    
                    meta_next_state <= read_array;
                    next_state <= increment_state;
                when read_status =>
                    -- yeah, this line needs to be fixed
                    -- Shivam made it quite clear that this section needs to happen
                    -- so don't get rid of it
                    if errors happened then
                        next_state <= error_state;
                    else
                        next_state <= read_array;
                    end if;
                when write_state =>
                    -- for some reason 0x00FF is change to read array mode when in write state
                    if data = X"00FF" then
                        next_state <= read_array;
                    elsif status = '0' then
                        -- write at address
                        data <= data_bpm_in;
                        -- increment address
                        meta_next_state <= read_status;
                        next_state      <= increment_state;
                        
                    end if;
                when erase_state =>
                    if status = '0' and chip_enable = '1' then
                        -- erase at address
                        next_state <= read_status;
                    end if;
                when increment_state =>
                    -- if we reach end of memory, reset
                    -- otherwise, just increment address
                    if address = X"3FFFFF" then
                        next_state <= reset_state;
                    else
                        address <= address + 1;
                    end if;
                    
                    next_state <= meta_next_state;
                when error_state =>
                    -- TODO: handle errors
                    -- again, Shivam said this is an extremely important part of memory!!
                    next_state <= read_array;
            end case;
            
            current_state <= next_state;
        end if;
    end process;
end behaviour;
