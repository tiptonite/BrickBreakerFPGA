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
        VGA_VS : out std_logic := '0'
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

    component Bricks is
        port (
            clk          : in  std_logic;
            hPos         : in  unsigned(10 downto 0);
            vPos         : in  unsigned(9 downto 0);
            brick_status : out std_logic_vector(1 downto 0)
        );
    end component Bricks;    

    signal clockVGA : std_logic := '0';
    signal hPos : unsigned(10 downto 0);
    signal vPos : unsigned(9 downto 0);
    signal pixel_status : std_logic_vector(3 downto 0);
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

    Bricks_1 : Bricks
        port map (
            clk          => clockVGA,
            hPos         => hPos,
            vPos         => vPos,
            brick_status => brick_status
        );        
	
end architecture rtl;
