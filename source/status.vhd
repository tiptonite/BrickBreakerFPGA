library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Status is
	
	port(
		ball_status : in std_logic_vector(3 downto 0);
		paddle_status : in std_logic;
		brick_status : in std_logic_vector(1 downto 0);
        status : out std_logic_vector(6 downto 0)  := (others => '0')
	);


end entity Status;


architecture rtl of Status is


begin

	status <= brick_status & ball_status & paddle_status;
	
end architecture rtl;
