library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Bricks is
	
	port(
		clk : in std_logic;
		hPos : in unsigned(10 downto 0);
        vPos : in unsigned(9 downto 0);
		brick_status : out std_logic_vector(1 downto 0);
		BCh : in unsigned(10 downto 0);
		BCv : in unsigned(9 downto 0);
		hit : out std_logic;
		hit_side : out std_logic_vector(3 downto 0);
		ball_update_clk : in std_logic
	);

end entity Bricks;


architecture rtl of Bricks is

	type BRICK_GRID is array (0 to 40, 0 to 30) of std_logic;

	signal grid : BRICK_GRID := (others => (others => '1'));

	signal count : integer := 0;
	signal hToAdd : integer := 0;
	signal vToAdd : integer := 0;

	signal BBh :unsigned (10 downto 0);
	signal BBv :unsigned (9 downto 0);
	signal BLh :unsigned (10 downto 0);
	signal BLv :unsigned (9 downto 0);
	signal BRh :unsigned (10 downto 0);
	signal BRv :unsigned (9 downto 0);
	signal BTh :unsigned (10 downto 0);
	signal BTv :unsigned (9 downto 0);

	signal next_hit : std_logic := '0';
	signal next_hit_side : std_logic_vector(3 downto 0) := "0000";

begin

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

	process(ball_update_clk, BCh, BCv, BBh, BBv, BLh, BLv, BRh, BRv, BTh, BTv)

		variable bTopIndexH : integer := 0;
		variable bTopIndexV : integer := 0;
		variable bBottomIndexH : integer := 0;
		variable bBottomIndexV : integer := 0;
		variable bLeftIndexH : integer := 0;
		variable bLeftIndexV : integer := 0;
		variable bRightIndexH : integer := 0;
		variable bRightIndexV : integer := 0;

	begin

		bTopIndexV := to_integer(BTv srl 3);
		if BTv(3) = '1' then
			-- Shift the odd rows over
			bTopIndexH := to_integer((BTh + 8) srl 4);
		else
			bTopIndexH := to_integer(BTh srl 4);
		end if;

		bBottomIndexV := to_integer(BBv srl 3);
		if BBv(3) = '1' then
			-- Shift the odd rows over
			bBottomIndexH := to_integer((BBh + 8) srl 4);
		else
			bBottomIndexH := to_integer(BBh srl 4);
		end if;

		bLeftIndexV := to_integer(BLv srl 3);
		if BLv(3) = '1' then
			-- Shift the odd rows over
			bLeftIndexH := to_integer((BLh + 8) srl 4);
		else
			bLeftIndexH := to_integer(BLh srl 4);
		end if;

		bRightIndexV := to_integer(BRv srl 3);
		if BRv(3) = '1' then
			-- Shift the odd rows over
			bRightIndexH := to_integer((BRh + 8) srl 4);
		else
			bRightIndexH := to_integer(BRh srl 4);
		end if;


		if BTv <= 239 then
			if grid(bTopIndexH, bTopIndexV) = '1' then
				next_hit <= '1';
				next_hit_side <= "1000";
			elsif BCv <= 239 AND grid(bLeftIndexH, bLeftIndexV) = '1' then
				next_hit <= '1';
				next_hit_side <= "0100";
			elsif BCv <= 239 AND grid(bRightIndexH, bRightIndexV) = '1' then
				next_hit <= '1';
				next_hit_side <= "0010";
			elsif BBv <= 239 AND grid(bBottomIndexH, bBottomIndexV) = '1' then
				next_hit <= '1';
				next_hit_side <= "0001";
			else 
				next_hit <= '0';
				next_hit_side <= "0000";
			end if;
		else
			next_hit <= '0';
			next_hit_side <= "0000";
		end if;

		if rising_edge(ball_update_clk) then
			hit <= next_hit;
			hit_side <= next_hit_side;

			if next_hit = '1' then
				if next_hit_side = "1000" then
					grid(bTopIndexH, bTopIndexV) <= '0';
				elsif next_hit_side = "0100" then
					grid(bLeftIndexH, bLeftIndexV) <= '0';
				elsif next_hit_side = "0010" then
					grid(bRightIndexH, bRightIndexV) <= '0';
				elsif next_hit_side = "0001" then
					grid(bBottomIndexH, bBottomIndexV) <= '0';
				end if;
			end if;
		end if;

	end process;

	BBh<=BCh;
	BBv<=BCv+5;
	BTh<=BCh;
	BTv<=BCv-5;
	BLh<=BCh-5;
	BLv<=BCv;
	BRh<=BCh+5;
	BRv<=BCv;
	
end architecture rtl;
