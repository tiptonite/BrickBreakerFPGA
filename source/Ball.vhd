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
		ball_status : out std_logic;
		lives :out unsigned(3 downto 0);
		reset :in std_logic
	
	);
end entity Ball;

architecture RTL of Ball is
	signal BCh :unsigned (10 downto 0) :=b"00101000000";
	signal BCv :unsigned (9 downto 0) := b"0011110000";
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
	begin
	
	BallStatus:process(hPos,vPos)
	begin
		
		if vPos >= BTv and vPos <= BBv then
			if hPos >= BLh and hPos <= BRh then
				ball_status<='1';
			else
				ball_status<='0';
			end if;
		else
			ball_status<='0';
		end if;
		
		
		
		
		
	end process BallStatus;
	
	Ball_Update:process(clk)
	begin
		if rising_edge(clk) and life /= b"0000" then
			if count = BallUpdate then
				update<='1';
				count<=0;
			else
				update<='0';
				count<=count+1;
			end if;
		end if;	
	end process Ball_Update;
	
	
	BallPosition:process(update,reset)
	begin
		if reset='0' then
			life<=b"0101";
			BCv<=b"0011110000";
		elsif rising_edge(update)then
			BCv<=BCv+1;
			if BCv>485 then
				life<=life-1;
				BCv<=b"0011110000";
			end if;
		end if;
	
	
	end process BallPosition;
	
	
BBh<=BCh;
BBv<=BCv+5;
BTh<=BCh;
BTv<=BCv-5;
BLh<=BCh-5;
BLv<=BCv;
BRh<=BCh+5;
BRv<=BCv;
lives<=life;
	
	
	
end architecture RTL;