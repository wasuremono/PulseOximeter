library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package seven_segment_pkg is

    -- Return a std_logic_vector ready for driving a number of 7-segment displays.
    function unsigned_to_seven_segment(
        value: unsigned;
        number_of_digits: integer;
        value_is_bcd: boolean
    ) return std_logic_vector;

end;

package body seven_segment_pkg is

    function seven_seg_from_bcd_digit(bcd_digit: std_logic_vector(3 downto 0)) 
        return std_logic_vector 
    is begin
        case bcd_digit is
            --                   abcdefg
            when x"0" => return "0111111";
            when x"1" => return "0000110";
            when x"2" => return "1011011";
            when x"3" => return "1001111";
            when x"4" => return "1100110";
            when x"5" => return "1101101";
            when x"6" => return "1111101";
            when x"7" => return "0000111";
            when x"8" => return "1111111";
            when x"9" => return "1101111";
            when x"a" => return "1110111";
            when x"b" => return "1111100";
            when x"c" => return "0111001";
            when x"d" => return "1011110";
            when x"e" => return "1111001";
            when x"f" => return "1110001";
            when others => return "0000000";
        end case;
    end;

    -- Return a vector ready for driving a series of 7-segment displays.
    function unsigned_to_seven_segment(
        value: unsigned;
        -- Number of 7-segment displays (determines output vector width: W = 7*N)
        number_of_digits: integer;
        -- When true, treat the input value as a BCD number where every 4 bits hold one
        -- digit from 0 to A. When false, treat the input number as an unsigned integer.       
        value_is_bcd: boolean
    ) return std_logic_vector is

        variable segments: std_logic_vector(number_of_digits*7-1 downto 0);
        variable bcd_quotient: unsigned(value'range);
        variable bcd_remainder: unsigned(3 downto 0);
    begin

        if value_is_bcd then
            for i in 0 to number_of_digits-1 loop
                segments(i*7+6 downto i*7) := seven_seg_from_bcd_digit(
                    std_logic_vector(value(i*4+3 downto i*4))
                );
            end loop;
        else
            bcd_quotient := value;
            for i in 0 to number_of_digits-1 loop
                bcd_remainder := resize(bcd_quotient mod 10, 4);
                bcd_quotient := bcd_quotient / 10;
                segments(i*7+6 downto i*7) := seven_seg_from_bcd_digit(
                    std_logic_vector(bcd_remainder)
                );
            end loop;

        end if;

        return segments;
    end;

end;