library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Bricks is
	
	port(
		clk : in std_logic;
		hPos : in unsigned(10 downto 0);
        vPos : in unsigned(9 downto 0);
		brick_status : out std_logic_vector(1 downto 0)
	);


end entity Bricks;


architecture rtl of Bricks is

	--type BRICK_ROW is array (0 to 40) of std_logic;
	type BRICK_GRID is array (0 to 40, 0 to 30) of std_logic;

	signal grid : BRICK_GRID := (others => (others => '0'));

	signal count : integer := 0;
	signal hToAdd : integer := 0;
	signal vToAdd : integer := 0;

begin

	process(clk)
	begin
		if rising_edge(clk) then

			if (vToAdd > 4 AND count = 10000000) OR (vToAdd <= 4 AND count = 250000) then
				count <= 0;

				if hToAdd = 40 then
					hToAdd <= 0;

					if vToAdd < 30 then
						vToAdd <= vToAdd + 1;
					else
						vToAdd <= vToAdd;
					end if;

				else
					hToAdd <= hToAdd + 1;
				end if;

				grid(hToAdd, vToAdd) <= '1';
			else
				count <= count + 1;
			end if;


		end if;
	end process;

	process(hPos, vPos, grid)

		variable hIndex : integer := 0;
		variable hPosition : unsigned(10 downto 0);
		variable vIndex : integer := 0;

	begin

		vIndex := to_integer(vPos srl 3);
		if vPos(3) = '1' then
			-- Shift the odd rows over
			hIndex := to_integer((hPos + 8) srl 4);
			hPosition := hPos + 8;
		else
			hIndex := to_integer(hPos srl 4);
			hPosition := hPos;
		end if;

		if vPos >= 239 then
			brick_status <= "00";
		else

			if (vPos AND "111") /= "111" AND (hPosition AND "1111") /= "1111" then
				-- Brick
				if grid(hIndex, vIndex) = '1' then
					brick_status <= "01";
				else
					brick_status <= "00";
				end if;
			elsif (vPos AND "111") /= "111" then
				-- Vertical Mortar
				if grid(hIndex, vIndex) = '1' AND grid(hIndex + 1, vIndex) = '1' then
					brick_status <= "10";
				else
					brick_status <= "00";
				end if;
			else
				-- Horizontal Mortar
				if vPos(3) = '0' then
					if grid(hIndex, vIndex) = '1' AND grid(to_integer((hPos + 9) srl 4), vIndex + 1) = '1' then
						brick_status <= "10";
					else
						brick_status <= "00";
					end if;
				else
					if grid(hIndex, vIndex) = '1' AND grid(to_integer((hPos + 1) srl 4), vIndex + 1) = '1' then
						brick_status <= "10";
					else
						brick_status <= "00";
					end if;
				end if;
			end if;

		end if;

	end process;
	
end architecture rtl;
