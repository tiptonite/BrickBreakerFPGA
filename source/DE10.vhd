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
		HEX5   : out std_logic_vector(7 downto 0);
		ARDUINO_IO : out std_logic_vector(15 downto 0)
	);


end entity DE10;


architecture rtl of DE10 is

    component pll is
     	port (
			inclk0	: IN STD_LOGIC;
			c0		: OUT STD_LOGIC
     	);
    end component pll;

    component pll_audio is
     	port (
			inclk0	: IN STD_LOGIC;
			c0		: OUT STD_LOGIC
     	);
    end component pll_audio;

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
			Pos_out :out std_logic_vector(11 downto 0);
			BCv :in unsigned(9 downto 0);
			BCh :in unsigned(10 downto 0);
			PaddleHit :out std_logic

		);
	end component paddle;
	
    component Bricks is
        port (
            clk             : in  std_logic;
            hPos            : in  unsigned(10 downto 0);
            vPos            : in  unsigned(9 downto 0);
            brick_status    : out std_logic_vector(1 downto 0);
            BCh             : in  unsigned(10 downto 0);
            BCv             : in  unsigned(9 downto 0);
            hit             : out std_logic;
            hit_side        : out std_logic_vector(3 downto 0);
            ball_update_clk : in  std_logic
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
			go    :in std_logic;
			die_sound :out std_logic;
			BC_V :out unsigned(9 downto 0);
			BC_H :out unsigned(10 downto 0);
			PaddleHit :in std_logic
	
		);
	end component Ball;

    component Tone is
        port (
            clk 			   : in std_logic;
			clk_audio 		   : in std_logic;
            play_bounce_wall   : in  std_logic;
            play_bounce_brick  : in  std_logic;
            play_bounce_paddle : in  std_logic;
            play_die           : in  std_logic;
            out_signal         : out std_logic
        );
    end component Tone;    
  
    signal clockVGA : std_logic := '0';
    signal hPos : unsigned(10 downto 0);
    signal vPos : unsigned(9 downto 0);
	 signal BV :unsigned(9 downto 0);
	 signal BH :unsigned(10 downto 0);
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
	signal PaddleBallHit :std_logic;
    signal audio_clk : std_logic := '0';
    signal audio_signal : std_logic := '0';
	signal play_bounce_wall_sound   : std_logic := '0';
    signal play_bounce_brick_sound  : std_logic := '0';
    signal play_bounce_paddle_sound : std_logic := '0';
    signal play_die_sound           : std_logic := '0';

    signal ballCh : unsigned(10 downto 0) := (others => '0');
    signal ballCv : unsigned(9 downto 0) := (others => '0');
    signal wall_hit : std_logic := '0';
    signal wall_hit_side : std_logic_vector(3 downto 0) := "0000";
    signal ball_update_clk : std_logic := '0';


begin

	pll1 : pll
		port map (
			inclk0 => MAX10_CLK1_50,
			c0 => clockVGA
		);

	pll2 : pll_audio
		port map (
			inclk0 => MAX10_CLK1_50,
			c0 => audio_clk
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
			Pos_out =>Paddle_Pos,
			BCv=>BV,
			BCh=>BH,
			PaddleHit=>PaddleBallHit
		
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
		
		BallUpdate=>437500
		)
		port map(
				clk=>MAX10_CLK1_50,
				hPos=>hPos,
				vPos=>vPos,
				ball_status=>ball_status,
				lives=>livesNum,
				reset=>KEY(0),
				go=>KEY(1),
				die_sound=>play_die_sound,
				BC_V=>BV,
				BC_H=>BH,
				PaddleHit=>PaddleBallHit
				
		
		
		);

	
	
	 HEX1(7 downto 0)<=x"FF";
     HEX2(7 downto 0)<=x"FF";
	-- livesNum<=b"0101";
	 ADC_reset<=KEY(0);
	 ADC1(3 downto 0)<=Paddle_Pos(3 downto 0);
	 ADC2(3 downto 0)<=Paddle_Pos(7 downto 4);
	 ADC3(3 downto 0)<=Paddle_Pos(11 downto 8);
     
    Bricks_1 : Bricks
        port map (
            clk             => clockVGA,
            hPos            => hPos,
            vPos            => vPos,
            brick_status    => brick_status,
            BCh             => ballCh,
            BCv             => ballCv,
            hit             => wall_hit,
            hit_side        => wall_hit_side,
            ball_update_clk => ball_update_clk
        );

    Tone_1 : Tone
        port map (
            clk                => MAX10_CLK1_50,
            clk_audio		   => audio_clk,
            play_bounce_wall   => play_bounce_wall_sound,
            play_bounce_brick  => play_bounce_brick_sound,
            play_bounce_paddle => play_bounce_paddle_sound,
            play_die           => play_die_sound,
            out_signal         => audio_signal
        );

    ARDUINO_IO(7) <= audio_signal;
	
end architecture rtl;
