library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Status is
	
	port(
		ball_status : in std_logic_vector(3 downto 0);
		paddle_status : in std_logic;
		brick_status : in std_logic_vector(1 downto 0);
        status : out std_logic_vector(6 downto 0)  := (others => '0');
		 gameOver :in std_logic
	);


end entity Status;


architecture rtl of Status is


begin
	with gameOver select
		status <= brick_status & ball_status & paddle_status when '0',
																 "0000000" when '1';
	
end architecture rtl;
