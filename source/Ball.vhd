library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ball is
	generic(
		BallUpdate :integer :=25000000
	
	
	);
	port(
		clk :in std_logic;
		hPos : in unsigned(10 downto 0);
		vPos : in unsigned(9 downto 0);
		ball_status : out std_logic_vector(3 downto 0);
		lives :out unsigned(3 downto 0);
		reset :in std_logic;
		go    :in std_logic;
		die_sound :out std_logic;
		side_sound : out std_logic;
		BC_V :out unsigned(9 downto 0);
		BC_H :out unsigned(10 downto 0);
		PaddleHit :in std_logic_vector(4 downto 0);
		WallHit :in std_logic;
		WallHitSide :in std_logic_vector(5 downto 0);
		BallClk :out std_logic
	
	);
end entity Ball;

architecture RTL of Ball is
	type GameStatus is (dead,live);
	signal PS :GameStatus := dead;
	signal NS :GameStatus;
	signal ball_hPos : unsigned(12 downto 0) := b"0010011111100";
	signal ball_vPos :unsigned (11 downto 0) := b"001111010100";
	signal BCh :unsigned (10 downto 0) :=b"00100111111";
	signal BCv :unsigned (9 downto 0) := b"0011110101";
	signal BBh :unsigned (10 downto 0);
	signal BBv :unsigned (9 downto 0);
	signal BLh :unsigned (10 downto 0);
	signal BLv :unsigned (9 downto 0);
	signal BRh :unsigned (10 downto 0);
	signal BRv :unsigned (9 downto 0);
	signal BTh :unsigned (10 downto 0);
	signal BTv :unsigned (9 downto 0);
	signal count :integer:=0;
	signal update :std_logic;
	signal life :unsigned (3 downto 0) :=b"0101";
	signal die :std_logic:='0';
	constant speedLength : integer := 3;
	signal hSpeed :unsigned((speedLength-1) downto 0) := "000";
	signal vSpeed :unsigned((speedLength-1) downto 0) := "011";
	signal paddleHits : unsigned(23 downto 0) := (others => '0');
	begin

	BCh <= ball_hPos(12 downto 2);
	BCv <= ball_vPos(11 downto 2);
	
	BallStatus:process(hPos,vPos)
		variable md : signed(11 downto 0);
		variable dh : signed(11 downto 0);
		variable dv : signed(10 downto 0);
	begin

		dh := abs(signed('0' & hPos) - signed('0' & BCh));
		dv := abs(signed('0' & vPos) - signed('0' & BCv));
		md := dh + dv;
		
		if vPos >= BTv and vPos <= BBv then
			if hPos >= BLh and hPos <= BRh then
				if (dv <= 4 AND dh <= 2) OR (dv <= 2 AND dh <= 4) OR (dv <= 3 AND dh <= 3) then
					ball_status <= "0001";
				elsif (dv <= 4 AND dh <= 3) OR (dv <= 3 AND dh <= 4) then
					ball_status <= "0010";
				elsif md <= 5 then
					ball_status <= "0010";
				elsif md <= 6 then
					ball_status <= "0100";
				else
					ball_status <= "0000";
				end if;
			else
				ball_status<="0000";
			end if;
		else
			ball_status<="0000";
		end if;
		
		
	end process BallStatus;
	
	Ball_Update:process(clk)
	begin
		if rising_edge(clk) and PS=live then
			if ((paddleHits<600) and count = BallUpdate - to_integer(paddleHits sll 9)) or (paddleHits>=600 and count>=100000) then
				update<='1';
				count<=0;
			else
				update<='0';
				count<=count+1;
			end if;
		end if;	
	end process Ball_Update;
	
	
	BallPosition:process(update,reset,PS)
	begin
		if reset='0' then
			life<=b"0101";
			ball_vPos<=b"001111010100";
			ball_hPos <= b"0010011111100";
		elsif rising_edge(update)then
			if vSpeed(speedLength-1) = '1' then
				ball_vPos <= to_unsigned(to_integer(ball_vPos) - to_integer(vSpeed(speedLength-2 downto 0)), ball_vPos'length);
			else
				ball_vPos <= to_unsigned(to_integer(ball_vPos) + to_integer(vSpeed(speedLength-2 downto 0)), ball_vPos'length);
			end if;

			if hSpeed(speedLength-1) = '1' then
				ball_hPos <= to_unsigned(to_integer(ball_hPos) - to_integer(hSpeed(speedLength-2 downto 0)), ball_hPos'length);
			else
				ball_hPos <= to_unsigned(to_integer(ball_hPos) + to_integer(hSpeed(speedLength-2 downto 0)), ball_hPos'length);
			end if;

			if BCv>485 then
				life<=life-1;
				die<='1';
				ball_vPos<=b"001111010100";
				ball_hPos <= b"0010011111100";
			end if;
		
		end if;
		if PS=dead then
			die<='0';
		end if;
	
	
	end process BallPosition;
	
	GameState : process(clk,reset)
	begin
		if reset='0' then
			PS<=dead;
		elsif rising_edge(clk) then
			PS<=NS;
		end if;
	end process GameState;
	
	BallWait:process(PS,go,life,die)
	begin
		case PS is
			when dead =>
				if go='0' and life /=b"0000" then
					NS<=live;
				else
					NS<=dead;
				end if;
			when live =>
				if life=b"0000" or die='1'then
					NS<=dead;
				else
					NS<=live;
				end if;
		end case;
		
	end process BallWait;
	
	Paddle:process(update, reset)
	begin
		if reset = '0' then
			vSpeed <= "011";
			hSpeed <= "000";
			paddleHits <= (others => '0');
		elsif rising_edge(update) then
			if BLh = 0 then
				hSpeed(speedLength-1) <= '0';
				paddleHits <= paddleHits + 1;
			elsif BRh = 639 then
				hSpeed(speedLength-1) <= '1';
				paddleHits <= paddleHits + 1;

			elsif PaddleHit="10000" then
				paddleHits <= paddleHits + 1;
				vSpeed <= "101";
				hSpeed <= "111";
				
			elsif PaddleHit="01000" then
				paddleHits <= paddleHits + 1;
				vSpeed <= "110";
				hSpeed <= "110";
				
			elsif PaddleHit="00100" then
				paddleHits <= paddleHits + 1;
				vSpeed(speedLength-1) <= '1';
				
			elsif PaddleHit="00010" then
				paddleHits <= paddleHits + 1;
				vSpeed <= "110";
				hSpeed <= "010";
				
			elsif PaddleHit="00001" then
				paddleHits <= paddleHits + 1;
				vSpeed <= "101";
				hSpeed <= "011";
				
			elsif WallHit='1' then
				paddleHits <= paddleHits + 1;
				if WallHitSide = "100000" then
					vSpeed(speedLength-1) <= '0';
				elsif WallHitSide = "010000" then
					vSpeed(speedLength-1) <= '0';
					hSpeed(speedLength-1) <= '0';
				elsif WallHitSide = "001000" then
					hSpeed(speedLength-1) <= '0';
				elsif WallHitSide = "000100" then
					hSpeed(speedLength-1) <= '1';
				elsif WallHitSide = "000010" then
					vSpeed(speedLength-1) <= '0';
					hSpeed(speedLength-1) <= '1';
				elsif WallHitSide = "000001" then
					vSpeed(speedLength-1) <= '1';
				end if;
			elsif BCv>485 then
				vSpeed <= "011";
				hSpeed <= "000";
				paddleHits <= (others => '0');
			elsif BTv=0 then
				vSpeed(speedLength-1) <= '0';
				paddleHits <= paddleHits + 1;
			end if;
		end if;
	end process Paddle;

	SIDESOUND : process(update)
	begin
		if rising_edge(update) then
			if BLh = 0 OR BRh = 639 OR BTv=0 then
				side_sound <= '1';
			else 
				side_sound <= '0';
			end if;
		end if;
	end process SIDESOUND;
	
BBh<=BCh;
BBv<=BCv+5;
BTh<=BCh;
BTv<=BCv-5;
BLh<=BCh-5;
BLv<=BCv;
BRh<=BCh+5;
BRv<=BCv;
lives<=life;
die_sound<=die;
BC_V<=BCv;
BC_H<=BCh;
BallClk<=update;	
	
	
end architecture RTL;