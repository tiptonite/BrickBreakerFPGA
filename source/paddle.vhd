library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity paddle is
    generic(
        PaddleUpdate : integer


    );
    port(
            clk : in std_logic;
            hPos : in unsigned(10 downto 0);
            vPos : in unsigned(9 downto 0);
            paddle_status : out std_logic;
            ADC_in :in std_logic_vector(11 downto 0);
			Pos_out :out std_logic_vector(11 downto 0);
				BCv :in unsigned(9 downto 0);
				BCh :in unsigned(10 downto 0);
				PaddleHit :out std_logic

    );
end entity paddle;


architecture RTL of paddle is

    signal PC : unsigned(10 downto 0) :=b"00101000000"; --Center of paddle Horizontal position
    signal PL : unsigned(10 downto 0); --Upper left corner of paddle position
    signal DX : unsigned(10 downto 0);
    signal nPC : unsigned(10 downto 0);
    signal PR : unsigned(10 downto 0); --Upper right corner of paddle position
    signal count :integer :=0;
    signal update :std_logic :='0';
	signal ADC_Average : integer;
	signal ADC_count : integer :=0;
	signal ADC_in2 : unsigned(10 downto 0) :=b"00101000000";
	signal ADC_val : integer;
	signal BBh :unsigned (10 downto 0);
	signal BBv :unsigned (9 downto 0);
	signal BLh :unsigned (10 downto 0);
	signal BLv :unsigned (9 downto 0);
	signal BRh :unsigned (10 downto 0);
	signal BRv :unsigned (9 downto 0);
	signal BTh :unsigned (10 downto 0);
	signal BTv :unsigned (9 downto 0);
	
	component averageADC is
	port(
	data_in :in std_logic_vector (11 downto 0);
	data_out :out unsigned (10 downto 0);
	clk :in std_logic
	);
	end component averageADC;
    
    begin
	
	avg1 : averageADC 
	port map(
		data_in=>ADC_in,
		data_out=>PC,
		clk=>clk
	
	
	
	);



    -- Determine if pixel is part of paddle or not
    P_status:process(hPos,vPos)
    begin
        -- check for vertical position to be one of last 5 lines
        if(vPos>474) then
            if hPos>=PL and hPos<=PR then
                -- Pixel is part of paddle between left and right edges
                paddle_status<='1';
            else
                paddle_status<='0';
            end if;
        else
            paddle_status<='0';
        end if;


    end process P_status;


	HitStatus:process(BCv,BCh)
	begin
			if (BBv>474 and BBv<484) then
				if(BBh<(PR+5) and BBh>(PL-5)) then
					PaddleHit<='1';
				else
					PaddleHit<='0';
				end if;
			else
				PaddleHit<='0';
			end if;
	
	end process HitStatus;
	
	BBh<=BCh;
	BBv<=BCv+5;
	BTh<=BCh;
	BTv<=BCv-5;
	BLh<=BCh-5;
	BLv<=BCv;
	BRh<=BCh+5;
	BRv<=BCv;
    PL<=PC-20;
    PR<=PC+20;
	Pos_out(10 downto 0)<=std_logic_vector(PC(10 downto 0));
	Pos_out(11)<='0';
end architecture RTL;