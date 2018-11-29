library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity DE10 is
	
	port(
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
	
	component ADC is
		port (
			CLOCK : in  std_logic                     := 'X'; -- clk
			RESET : in  std_logic                     := 'X'; -- reset
			CH0   : out std_logic_vector(11 downto 0);        -- CH0
			CH1   : out std_logic_vector(11 downto 0);        -- CH1
			CH2   : out std_logic_vector(11 downto 0);        -- CH2
			CH3   : out std_logic_vector(11 downto 0);        -- CH3
			CH4   : out std_logic_vector(11 downto 0);        -- CH4
			CH5   : out std_logic_vector(11 downto 0);        -- CH5
			CH6   : out std_logic_vector(11 downto 0);        -- CH6
			CH7   : out std_logic_vector(11 downto 0)         -- CH7
		);
	end component ADC;
	
	component paddle is
		generic (
			PaddleUpdate : integer


		);
		port (
			clk : in std_logic;
			hPos : in unsigned(10 downto 0);
			vPos : in unsigned(9 downto 0);
			paddle_status : out std_logic;
			ADC_in :in std_logic_vector(11 downto 0)

		);
	end component paddle;
	
    signal clockVGA : std_logic := '0';
    signal hPos : unsigned(10 downto 0);
    signal vPos : unsigned(9 downto 0);
    signal pixel_status : std_logic_vector(3 downto 0);
    signal ball_status : std_logic;
    signal paddle_status : std_logic;
    signal brick_status : std_logic_vector(1 downto 0);
	signal livesNum :unsigned(3 downto 0);
	signal ADC1 :std_logic_vector(3 downto 0);
	signal ADC2 :std_logic_vector(3 downto 0);
	signal ADC3 :std_logic_vector(3 downto 0);
	signal ADC_reset :std_logic;
	signal ADC_DATA :std_logic_vector (11 downto 0);


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
			ADC_in => ADC_DATA
		
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
	
	u0 : component ADC
		port map (
			CLOCK => MAX10_CLK1_50, --      clk.clk
			RESET => ADC_reset, --    reset.reset
			CH0   => ADC_DATA,   -- readings.CH0
			CH1   => open,   --         .CH1
			CH2   => open,   --         .CH2
			CH3   => open,   --         .CH3
			CH4   => open,   --         .CH4
			CH5   => open,   --         .CH5
			CH6   => open,   --         .CH6
			CH7   => open    --         .CH7
		);
	
	
	 HEX1(7 downto 0)<=x"FF";
     HEX2(7 downto 0)<=x"FF";
	 livesNum<=b"0101";
	 ADC_reset<=not KEY(0);
	 ADC1(3 downto 0)<=ADC_DATA(3 downto 0);
	 ADC2(3 downto 0)<=ADC_DATA(7 downto 4);
	 ADC3(3 downto 0)<=ADC_DATA(11 downto 8);
     
	
end architecture rtl;
