library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Bricks is
	
	port(
		hPos : in unsigned(10 downto 0);
        vPos : in unsigned(9 downto 0);
		brick_status : out std_logic_vector(1 downto 0)
	);


end entity Bricks;


architecture rtl of Bricks is

	type BRICK_ROW is array (0 to 639) of std_logic;
	type BRICK_GRID is array (0 to 479) of BRICK_ROW;

	signal grid : BRICK_GRID := (others => (others => '0'));

begin

	process(hPos, vPos)

		variable hIndex : unsigned(6 downto 0) := (others => '0');
		variable vIndex : unsigned(5 downto 0) := (others => '0');

	begin

		hIndex := resize(hPos srl 4, hIndex'length);
		vIndex := resize(vPos srl 3, vIndex'length);

		if vPos >= 239 then
			brick_status <= "00";
		else

			if vIndex(0) = '0' then
				-- Even Row
				if (vPos AND "111") /= "111" AND (hPos AND "1111") /= "1111" then
					brick_status <= "01";
				else
					brick_status <= "10";
				end if;
			else
				-- Odd Row
				if (vPos AND "111") /= "111" AND ((hPos + 8) AND "1111") /= "1111" then
					brick_status <= "01";
				else
					brick_status <= "10";
				end if;
			end if;

		end if;

	end process;
	
end architecture rtl;
