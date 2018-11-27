library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity VGA_TB is
end entity VGA_TB;

architecture rtl of VGA_TB is
	
    component VGA is
        port (
            clk    : in  std_logic;
            VGA_B  : out std_logic_vector(3 downto 0) := (others => '0');
            VGA_G  : out std_logic_vector(3 downto 0) := (others => '0');
            VGA_HS : out std_logic                    := '0';
            VGA_R  : out std_logic_vector(3 downto 0) := (others => '0');
            VGA_VS : out std_logic                    := '0'
        );
    end component VGA;	

    signal clk    : std_logic                    := '0';
	signal VGA_B  : std_logic_vector(3 downto 0) := (others => '0');
	signal VGA_G  : std_logic_vector(3 downto 0) := (others => '0');
	signal VGA_HS : std_logic                    := '0';
	signal VGA_R  : std_logic_vector(3 downto 0) := (others => '0');
	signal VGA_VS : std_logic                    := '0';

	constant period : time := 39722ps;

begin

	vga1 : vga
		port map(clk, VGA_B, VGA_G, VGA_HS, VGA_R, VGA_VS);

	clkp : process
	begin
		clk <= '1';
		wait for period / 2;
		clk <= '0';
		wait for period / 2;
	end process;

end architecture rtl;
