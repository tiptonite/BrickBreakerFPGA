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
			Pos_out :out std_logic_vector(11 downto 0)

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


--	process(clk)
--	begin
--		if rising_edge(clk) then
--		ADC_val<=to_integer(unsigned(ADC_in));
--		if ADC_count=100 then
--			ADC_Average<=ADC_Average/100;
--			ADC_in2<=to_unsigned(ADC_Average,ADC_in2'length);
--		else
--			ADC_count<=ADC_count+1;
--			ADC_Average<=ADC_Average+ADC_val;
--		end if;
--		end if;
--	end process;
	
--    process(clk)
--    begin
--		if rising_edge(clk) then
--			PC<=unsigned('0'&'0' & ADC_in(11 downto 3));
--		
--		end if;
--    end process;

--    --Rate at which paddle position updates
--    P_update : process(clk)
--    begin
--        if rising_edge(clk)then
--            if count = PaddleUpdate then
--                count<=0
--                update<='1';
--            else
--                count<=count+1;
--                update<='0';
--            end if;
--        end if;
--    end process P_update;
--

    PL<=PC-20;
    PR<=PC+20;
	Pos_out(10 downto 0)<=std_logic_vector(PC(10 downto 0));
	Pos_out(11)<='0';
end architecture RTL;