library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity DE10 is
	
	port(
		ADC_CLK_10 : in std_logic;
		MAX10_CLK1_50 : in std_logic;
		KEY    : in std_logic_vector(1 downto 0) := (others => '0');
        VGA_B  : out std_logic_vector(3 downto 0) := (others => '0');
        VGA_G  : out std_logic_vector(3 downto 0) := (others => '0');
        VGA_HS : out std_logic := '0';
        VGA_R  : out std_logic_vector(3 downto 0) := (others => '0');
        VGA_VS : out std_logic := '0';
		HEX0   : out std_logic_vector(7 downto 0);
		HEX1   : out std_logic_vector(7 downto 0);
		HEX2   : out std_logic_vector(7 downto 0);
		HEX3   : out std_logic_vector(7 downto 0);
		HEX4   : out std_logic_vector(7 downto 0);
		HEX5   : out std_logic_vector(7 downto 0)
	);


end entity DE10;


architecture rtl of DE10 is

    component pll is
     	port (
			inclk0	: IN STD_LOGIC;
			c0		: OUT STD_LOGIC
     	);
    end component pll;

    component VGA is
        port (
            clk    : in  std_logic;
            reset  : in  std_logic;
            VGA_B  : out std_logic_vector(3 downto 0) := (others => '0');
            VGA_G  : out std_logic_vector(3 downto 0) := (others => '0');
            VGA_HS : out std_logic                    := '0';
            VGA_R  : out std_logic_vector(3 downto 0) := (others => '0');
            VGA_VS : out std_logic                    := '0';
            hPos   : out unsigned(10 downto 0);
            vPos   : out unsigned(9 downto 0);
            status : in  std_logic_vector(3 downto 0) := (others => '0')
        );
    end component VGA;  

    component Status is
        port (
            ball_status   : in  std_logic;
            paddle_status : in  std_logic;
            brick_status  : in  std_logic_vector(1 downto 0);
            status        : out std_logic_vector(3 downto 0) := (others => '0')
        );
    end component Status;    
	
	
	component sevenSeg is
		port (
			 clk		:in std_logic;
		   num_in	:in	std_logic_vector(3 downto 0);
		   seg_out	:out	std_logic_vector(7 downto 0);
		   dec		:in	std_logic
		);
	end component sevenSeg;
	
    component ADC_COMM is
        port (
            clk       : in  std_logic;
            reset     : in  std_logic;
            adc_value : out std_logic_vector(11 downto 0)
        );
    end component ADC_COMM;	
	
	component paddle is
		generic (
			PaddleUpdate : integer
		);
		port (
			clk : in std_logic;
			hPos : in unsigned(10 downto 0);
			vPos : in unsigned(9 downto 0);
			paddle_status : out std_logic;
			ADC_in :in std_logic_vector(11 downto 0);
			Pos_out :out std_logic_vector(11 downto 0)

		);
	end component paddle;
	
	component Bricks is
        port (
            clk          : in  std_logic;
            hPos         : in  unsigned(10 downto 0);
            vPos         : in  unsigned(9 downto 0);
            brick_status : out std_logic_vector(1 downto 0)
        );
	end component Bricks;
	 
	component Ball is
		generic(
			BallUpdate :integer
		
		
		);
		port(
			clk :in std_logic;
			hPos : in unsigned(10 downto 0);
			vPos : in unsigned(9 downto 0);
			ball_status : out std_logic;
			lives :out unsigned(3 downto 0);
			reset :in std_logic;
			go    :in std_logic
		
		
		);
	end component Ball;

  
    signal clockVGA : std_logic := '0';
    signal hPos : unsigned(10 downto 0);
    signal vPos : unsigned(9 downto 0);
    signal pixel_status : std_logic_vector(3 downto 0);
	signal livesNum :unsigned(3 downto 0);
	signal ADC1 :std_logic_vector(3 downto 0);
	signal ADC2 :std_logic_vector(3 downto 0);
	signal ADC3 :std_logic_vector(3 downto 0);
	signal ADC_reset :std_logic;
	signal ADC_DATA :std_logic_vector (11 downto 0);
	signal Paddle_Pos :std_logic_vector(11 downto 0);
    signal ball_status : std_logic := '0';
    signal paddle_status : std_logic := '0';
    signal brick_status : std_logic_vector(1 downto 0) := (others => '0');


begin

	pll1 : pll
		port map (
			inclk0 => MAX10_CLK1_50,
			c0 => clockVGA
		);

    VGA_1 : VGA
        port map (
            clk    => clockVGA,
            reset  => KEY(0),
            VGA_B  => VGA_B,
            VGA_G  => VGA_G,
            VGA_HS => VGA_HS,
            VGA_R  => VGA_R,
            VGA_VS => VGA_VS,
            hPos   => hPos,
            vPos   => vPos,
            status => pixel_status
        );

    Status_1 : Status
        port map (
            ball_status   => ball_status,
            paddle_status => paddle_status,
            brick_status  => brick_status,
            status        => pixel_status
        );

	lives: sevenSeg
		port map(
			clk => MAX10_CLK1_50,
			num_in (3 downto 0) => std_logic_vector(livesNum(3 downto 0)),
			seg_out(7 downto 0) =>HEX0(7 downto 0),
			dec => '0'
		);
		
	paddle_1 : paddle
		generic map(
			PaddleUpdate => 25000000
		
		)
		port map(
			clk =>MAX10_CLK1_50,
			hPos => hPos,
			vPos => vPos,
			paddle_status => paddle_status,
			ADC_in => ADC_DATA,
			Pos_out =>Paddle_Pos
		
		);
	
	ADCcount1: sevenSeg
		port map(
			clk => MAX10_CLK1_50,
			num_in (3 downto 0) => ADC1(3 downto 0),
			seg_out(7 downto 0) =>HEX3(7 downto 0),
			dec => '0'
		);
	 
	ADCcount2: sevenSeg
		port map(
			clk => MAX10_CLK1_50,
			num_in (3 downto 0) => ADC2(3 downto 0),
			seg_out(7 downto 0) =>HEX4(7 downto 0),
			dec => '0'
		);
	
	ADCcount3: sevenSeg
		port map(
			clk => MAX10_CLK1_50,
			num_in (3 downto 0) => ADC3(3 downto 0),
			seg_out(7 downto 0) =>HEX5(7 downto 0),
			dec => '0'
		);

    ADC_COMM_1 : ADC_COMM
        port map (
            clk       => MAX10_CLK1_50,
            reset     => ADC_reset,
            adc_value => ADC_DATA
        );
	 Ball1 : Ball
		generic map(
		
		BallUpdate=>1750000
		)
		port map(
				clk=>MAX10_CLK1_50,
				hPos=>hPos,
				vPos=>vPos,
				ball_status=>ball_status,
				lives=>livesNum,
				reset=>KEY(0),
				go=>KEY(1)
				
		
		
		);
	
	--u0 : component ADC
	--	port map (
	--		CLOCK => MAX10_CLK1_50, --      clk.clk
	--		CH0   => ADC_DATA,   -- readings.CH0
	--		CH1   => open,   --         .CH1
	--		CH2   => open,   --         .CH2
	--		CH3   => open,   --         .CH3
	--		CH4   => open,   --         .CH4
	--		CH5   => open,   --         .CH5
	--		CH6   => open,   --         .CH6
	--		CH7   => open,    --         .CH7
	--		RESET => ADC_reset --    reset.reset
	--	);
	
	
	 HEX1(7 downto 0)<=x"FF";
     HEX2(7 downto 0)<=x"FF";
	-- livesNum<=b"0101";
	 ADC_reset<=KEY(0);
	 ADC1(3 downto 0)<=Paddle_Pos(3 downto 0);
	 ADC2(3 downto 0)<=Paddle_Pos(7 downto 4);
	 ADC3(3 downto 0)<=Paddle_Pos(11 downto 8);
     
    Bricks_1 : Bricks
        port map (
            clk          => clockVGA,
            hPos         => hPos,
            vPos         => vPos,
            brick_status => brick_status
        );        
	
end architecture rtl;
