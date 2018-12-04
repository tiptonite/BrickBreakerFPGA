library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Tone is
	
	port(
		clk : in std_logic;
		clk_audio : in std_logic;
		play_bounce_wall : in std_logic;
		play_bounce_brick : in std_logic;
		play_bounce_paddle : in std_logic;
		play_die : in std_logic;
		out_signal : out std_logic
	);

end entity Tone;


architecture rtl of Tone is

	type AUDIO_TONE is (NONE, BWALL, BBRICK, BPADDLE, DIE);
	signal current_tone, next_tone : AUDIO_TONE := NONE;
	signal current_count, next_count, target_count : integer := 0;
	signal current_tone_length, next_tone_length, target_tone_length : integer := 0;
	signal current_state, next_state : std_logic := '0';

begin

	out_signal <= current_state;

	process(clk)
	begin
		if rising_edge(clk_audio) then
			current_tone <= next_tone;
		end if;
	end process;

	process(clk_audio)
	begin
		if rising_edge(clk_audio) then

			current_count <= next_count;
			current_tone_length <= next_tone_length;
			current_state <= next_state;

		end if;
	end process;

	process(current_tone, current_count, current_tone_length, current_state, play_bounce_wall, play_bounce_brick, play_bounce_paddle, play_die, target_tone_length, target_count)
	begin
		
		case current_tone is

			when NONE =>
				if play_bounce_wall = '1' then
					next_tone <= BWALL;
				elsif play_bounce_brick = '1' then
					next_tone <= BBRICK;
				elsif play_bounce_paddle = '1' then
					next_tone <= BPADDLE;
				elsif play_die = '1' then
					next_tone <= DIE;
				else
					next_tone <= NONE;
				end if;

				next_count <= 0;
				next_tone_length <= 0;
				next_state <= '0';

			when others =>
				if current_count = target_count then
					next_count <= 0;
					next_state <= not current_state;
				else
					next_count <= current_count + 1;
					next_state <= current_state;
				end if;

				if current_tone_length = target_tone_length then
					next_tone_length <= 0;
					next_tone <= NONE;
				else
					next_tone_length <= current_tone_length + 1;
					next_tone <= current_tone;
				end if;
		end case;
	end process;

	process(current_tone)
	begin
		case current_tone is
			when NONE =>
				target_count <= 0;
				target_tone_length <= 0;

			when BWALL =>
				target_count <= 4;
				target_tone_length <= 1000;

			when BBRICK =>
				target_count <= 5;
				target_tone_length <= 1000;

			when BPADDLE =>
				target_count <= 8;
				target_tone_length <= 1000;
				
			when DIE =>
				target_count <= 10;
				target_tone_length <= 1000;
		end case;


	end process;
	
end architecture rtl;
