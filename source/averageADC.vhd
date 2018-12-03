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
	signal ADCcount :integer;
	signal horiz :unsigned(31 downto 0);
	
begin
	ADCcount<=to_integer(unsigned(data_in(11 downto 5)));
	
--	process(clk)
--	begin
--	if ADCcount>=500 then
--		data_out<=to_unsigned(619,data_out'length);
--	elsif ADCcount<=20 then
--		data_out<=to_unsigned(20,data_out'length);
--	else
--		data_out<=to_unsigned(ADCcount,data_out'length);
--	end if;
--		
--	end process;
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
	horiz<=to_unsigned(625*ADCcount,horiz'length);
	sum<=shift_right(horiz,7);
	data_out<=sum(10 downto 0)+20;
	
--	data_out<=to_unsigned(0+((600-0)/(255-0))*(ADCcount-0)+20,data_out'length);
--	data_out<=to_unsigned(to_integer(shift_right(x"258",12))*ADCcount+20,data_out'length);
--	data_out<=to_unsigned((0.14652*ADCcount)+20,data_out'length);

end architecture RTL;