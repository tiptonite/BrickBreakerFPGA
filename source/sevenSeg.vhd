--------------------------------------------------------------------------
-- Seven Segment Driver for De-lite 10
-- 
--	Nathan Tipton Copyright 2018
--
--
-- inputs:
-- num_in - single hex digit of desired value
-- dec - 0 : no decimal point, 1 : decimal point
--
-- outputs:
-- seg_out - mapping for value on single seven segment display
--
--
--
--
--
---------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sevenSeg is
	port(
		clk		:in std_logic;
		num_in	:in	unsigned(3 downto 0);
		seg_out	:out	unsigned(7 downto 0);
		dec		:in	std_logic
	
	);
	end sevenSeg;
	
	
architecture RTL of sevenSeg is
	type seven_Seg is array (0 to 15) of unsigned(7 downto 0);
	constant sevSeg: seven_Seg := (X"C0", X"F9", X"A4",X"B0",X"99",X"92",X"82",X"F8",X"80",X"98",x"88",x"83",x"C6",x"A1",x"86",x"8E");
	type sevenSeg2 is array (0 to 15) of unsigned(7 downto 0);
	constant sevSegDec: sevenSeg2 := (X"40",X"79",X"24",X"30",X"19",X"12",X"02",X"78",X"00",X"18",x"08",x"03",x"46",x"21",x"06",x"0E");
	begin

	seven :process(clk)
	begin
		if rising_edge(clk) then
			if dec='0' then
				case num_in is
						when X"0" =>
						seg_out <= sevSeg(0);
					when X"1" =>
					seg_out <= sevSeg(1);
					when X"2" =>
					seg_out <= sevSeg(2);
					when X"3" =>
					seg_out <= sevSeg(3);
					when X"4" =>
					seg_out <= sevSeg(4);
					when X"5" =>
					seg_out <= sevSeg(5);
					when X"6" =>
					seg_out <= sevSeg(6);
					when X"7" =>
					seg_out <= sevSeg(7);
					when X"8" =>
					seg_out <= sevSeg(8);
					when X"9" =>
					seg_out <= sevSeg(9);
					when X"A" =>
					seg_out <= sevSeg(10);
					when X"B" =>
					seg_out <= sevSeg(11);
					when X"C" =>
					seg_out <= sevSeg(12);
					when X"D" =>
					seg_out <= sevSeg(13);
					when X"E" =>
					seg_out <= sevSeg(14);
					when X"F" =>
					seg_out <= sevSeg(15);
					when others =>
					seg_out <= x"FF";
				end case;
			else
				case num_in is
					when X"0" =>
					seg_out <= sevSegDec(0);
					when X"1" =>
					seg_out <= sevSegDec(1);
					when X"2" =>
					seg_out <= sevSegDec(2);
					when X"3" =>
					seg_out <= sevSegDec(3);
					when X"4" =>
					seg_out <= sevSegDec(4);
					when X"5" =>
					seg_out <= sevSegDec(5);
					when X"6" =>
					seg_out <= sevSegDec(6);
					when X"7" =>
					seg_out <= sevSegDec(7);
					when X"8" =>
					seg_out <= sevSegDec(8);
					when X"9" =>
					seg_out <= sevSegDec(9);
					when X"A" =>
					seg_out <= sevSegDec(10);
					when X"B" =>
					seg_out <= sevSegDec(11);
					when X"C" =>
					seg_out <= sevSegDec(12);
					when X"D" =>
					seg_out <= sevSegDec(13);
					when X"E" =>
					seg_out <= sevSegDec(14);
					when X"F" =>
					seg_out <= sevSegDec(15);
					when others =>
					seg_out <= x"FF";
				end case;	
			end if;
		end if;		
	end process seven;	
end architecture RTL;
			