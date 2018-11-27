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
            reset  : in std_logic;
            adv    : in std_logic;
            VGA_B  : out std_logic_vector(3 downto 0) := (others => '0');
            VGA_G  : out std_logic_vector(3 downto 0) := (others => '0');
            VGA_HS : out std_logic                    := '0';
            VGA_R  : out std_logic_vector(3 downto 0) := (others => '0');
            VGA_VS : out std_logic                    := '0'
        );
    end component VGA;    

    signal clockVGA : std_logic := '0';

begin

	pll1 : pll
		port map (
			inclk0 => MAX10_CLK1_50,
			c0 => clockVGA
		);

    vga1 : VGA
        port map(clockVGA, KEY(0), KEY(1), VGA_B, VGA_G, VGA_HS, VGA_R, VGA_VS);

	
end architecture rtl;
