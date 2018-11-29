library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ADC_COMM is
		
	port(
		clk : in std_logic;
		reset : in std_logic;
        adc_value : out std_logic_vector(11 downto 0)
	);

end entity ADC_COMM;

architecture behavioral of ADC_COMM is
    
    component adc is
        port (
            clk_clk                    : in  std_logic                     := 'X';             -- clk
            clk_out_clk                : out std_logic;                                        -- clk
            adc_command_valid          : in  std_logic                     := 'X';             -- valid
            adc_command_channel        : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- channel
            adc_command_startofpacket  : in  std_logic                     := 'X';             -- startofpacket
            adc_command_endofpacket    : in  std_logic                     := 'X';             -- endofpacket
            adc_command_ready          : out std_logic;                                        -- ready
            adc_response_valid         : out std_logic;                                        -- valid
            adc_response_channel       : out std_logic_vector(4 downto 0);                     -- channel
            adc_response_data          : out std_logic_vector(11 downto 0);                    -- data
            adc_response_startofpacket : out std_logic;                                        -- startofpacket
            adc_response_endofpacket   : out std_logic;                                        -- endofpacket
            reset_reset_n              : in  std_logic                     := 'X'              -- reset_n
        );
    end component adc;

    signal adc_data : std_logic_vector(11 downto 0) := (others => '0');
    signal adc_valid : std_logic := '0';
    signal adc_sop : std_logic := '0';
    signal adc_eop : std_logic := '0';
    signal clk_10M : std_logic := '0';
    signal resp_sop : std_logic := '0';
    signal resp_eop : std_logic := '0';
    signal resp_valid : std_logic := '0';
    
    type STATE is (IDLE, REQ, RD);
    signal current_state, next_state : STATE;
    signal count, next_count : integer;

begin 
    

    adc_1 : adc
        port map (
            clk_clk                    => clk,
            clk_out_clk                => clk_10M,
            adc_command_valid          => adc_valid,
            adc_command_channel        => "00001",
            adc_command_startofpacket  => adc_sop,
            adc_command_endofpacket    => adc_eop,
            adc_command_ready          => open,
            adc_response_valid         => resp_valid,
            adc_response_channel       => open,
            adc_response_data          => adc_data,
            adc_response_startofpacket => resp_sop,
            adc_response_endofpacket   => resp_eop,
            reset_reset_n              => reset
        );

    process(clk_10M, reset)
    begin

        if reset = '0' then
            current_state <= IDLE;
            count <= 0;

        elsif rising_edge(clk) then

            current_state <= next_state;
            count <= next_count;

            if current_state = RD then
                adc_value <= adc_data;
            end if;

            if current_state = REQ then
                adc_valid <= '1';
                adc_sop <= '1';
                adc_eop <= '1';
            else
                adc_valid <= '0';
                adc_sop <= '0';
                adc_eop <= '0';
            end if;

        end if;

    end process;


    process(current_state, count, resp_valid)
    begin

        case current_state is

            when IDLE =>
                if count < 499998 then
                    next_state <= IDLE;
                    next_count <= count + 1;
                else
                    next_state <= REQ;
                    next_count <= 0;
                end if;

            when REQ =>
                if resp_valid = '1' then
                    next_state <= RD;
                    next_count <= 0;
                else
                    next_state <= REQ;
                end if;

            when RD => 
                next_state <= IDLE;
                next_count <= 0;

        end case;


    end process;
    
	
end architecture behavioral;
