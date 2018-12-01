library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity averageADC is
	port(
	data_in :in std_logic_vector (11 downto 0);
	data_out :out unsigned (10 downto 0);
	clk :in std_logic
	
	
	
	
	);
end entity averageADC;

architecture RTL of averageADC is
	signal sum :unsigned (31 downto 0);
	signal count :integer :=0;
	
begin
	
--	process(clk)
--	begin
--	if rising_edge(clk) then
--		sum<=sum+unsigned(data_in);
--		
--		if count=65536 then
--			sum<=shift_right(sum,16);
--			data_out<=sum(10 downto 0);
--			sum<=(others=>'0');
--			count<=0;
--		else
--			count<=count+1;
--	
--		end if;
--	end if;
--	end process;
	data_out<=unsigned('0' & data_in(11 downto 2));
		
end architecture RTL;