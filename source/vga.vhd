library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity VGA is
	
	port(
		clk    : in std_logic;
		reset  : in std_logic;
		adv    : in std_logic;
        VGA_B  : out std_logic_vector(3 downto 0) := (others => '0');
        VGA_G  : out std_logic_vector(3 downto 0) := (others => '0');
        VGA_HS : out std_logic 					  := '0';
        VGA_R  : out std_logic_vector(3 downto 0) := (others => '0');
        VGA_VS : out std_logic 					  := '0'
	);


end entity VGA;


architecture rtl of VGA is
	
	type VStateType is (V_FRONT_PORCH, V_SYNC, V_BACK_PORCH, DATA);
	type HStateType is (H_FRONT_PORCH, H_SYNC, H_BACK_PORCH, DATA);

	signal currentStateV, nextStateV : VStateType;
	signal currentStateH, nextStateH : HStateType;

	constant V_FRONT_PIXELS : integer := 8000;
	constant V_SYNC_PIXELS : integer := 1600;
	constant V_BACK_PIXELS : integer := 26400;
	constant V_LINES : integer := 480;

	constant H_FRONT_PIXELS : integer := 16;
	constant H_SYNC_PIXELS : integer := 96;
	constant H_BACK_PIXELS : integer := 48;
	constant H_PIXELS : integer := 640;

	signal pixelCount : integer := 0;
	signal nextPixelCount : integer := 0;
	signal pixelCountV : integer := 0;
	signal nextPixelCountV : integer := 0;
	signal lineCount : integer := 0;
	signal nextLineCount : integer := 0;

	constant RED : std_logic_vector(11 downto 0) := X"F00";
	constant DRED : std_logic_vector(11 downto 0) := X"800";
	constant GREEN : std_logic_vector(11 downto 0) := X"0F0";
	constant DGREEN : std_logic_vector(11 downto 0) := X"080";
	constant BLUE : std_logic_vector(11 downto 0) := X"00F";
	constant DBLUE : std_logic_vector(11 downto 0) := X"008";
	constant WHITE : std_logic_vector(11 downto 0) := X"FFF";
	constant Black : std_logic_vector(11 downto 0) := X"000";
	constant ORANGE : std_logic_vector(11 downto 0) := X"F80";
	constant YELLOW : std_logic_vector(11 downto 0) := X"FF0";

	signal leftColor : std_logic_vector(11 downto 0);
	signal midColor : std_logic_vector(11 downto 0);
	signal rightColor : std_logic_vector(11 downto 0);

	type COUNTRY is (FRANCE, ITALY, IRELAND, BELGIUM, MALI, CHAD, NIGERIA, IVORY_COAST);
	signal active_country, next_country : COUNTRY := FRANCE;

	type button_state is (IDLE, PRE_PUSH, PUSH, POST_PUSH, POST_RELEASE);
	signal current_button_state, next_button_state : button_state;
	constant MaxDebounceAcc : integer := 20000;
	signal debounceAcc : integer := 0;


begin

	commit : process(clk)
	begin

		if rising_edge(clk) then

			currentStateV <= nextStateV;
			currentStateH <= nextStateH;
			pixelCount <= nextPixelCount;
			pixelCountV <= nextPixelCountV;
			--lineCount <= nextLineCount;

			if currentStateH = DATA AND currentStateV = DATA then
				if pixelCount < 213 then
					VGA_R <= leftColor(11 downto 8);
					VGA_G <= leftColor(7 downto 4);
					VGA_B <= leftColor(3 downto 0);
				elsif pixelCount < 426 then
					VGA_R <= midColor(11 downto 8);
					VGA_G <= midColor(7 downto 4);
					VGA_B <= midColor(3 downto 0);
				else
					VGA_R <= rightColor(11 downto 8);
					VGA_G <= rightColor(7 downto 4);
					VGA_B <= rightColor(3 downto 0);
				end if;
				
			else
				VGA_B <= (others => '0');
				VGA_G <= (others => '0');
				VGA_R <= (others => '0');
			end if;

			if currentStateV = V_SYNC then
				VGA_VS <= '0';
			else
				VGA_VS <= '1';
			end if;

			if currentStateH = H_SYNC then
				VGA_HS <= '0';
			else
				VGA_HS <= '1';
			end if;

			if currentStateH = DATA AND nextStateH = H_FRONT_PORCH then
				if currentStateV = DATA then
					if lineCount < V_LINES then
						lineCount <= lineCount + 1;
						--nextLineCount <= lineCount + 1;
					else
						lineCount <= 0;
						--nextLineCount <= 0;
					end if;
				else
					lineCount <= 0;
					--nextLineCount <= 0;
				end if;
			end if;

		end if;

	end process;

	state : process(currentStateV, currentStateH, pixelCount, pixelCountV, lineCount)
	begin

		case currentStateV is

			when V_FRONT_PORCH =>
				if pixelCountV < V_FRONT_PIXELS then
					nextPixelCountV <= pixelCountV + 1;
					nextStateV <= V_FRONT_PORCH;
				else
					nextStateV <= V_SYNC;
					nextPixelCountV <= 0;
				end if;

			when V_SYNC =>
				if pixelCountV < V_SYNC_PIXELS then
					nextPixelCountV <= pixelCountV + 1;
					nextStateV <= V_SYNC;
				else
					nextStateV <= V_BACK_PORCH;
					nextPixelCountV <= 0;
				end if;

			when V_BACK_PORCH =>
				if pixelCountV < V_BACK_PIXELS then
					nextPixelCountV <= pixelCountV + 1;
					nextStateV <= V_BACK_PORCH;
				else
					nextStateV <= DATA;
					nextPixelCountV <= 0;
				end if;

			when DATA =>
				if lineCount < V_LINES then
					nextStateV <= DATA;
				else
					nextStateV <= V_FRONT_PORCH;
				end if;

		end case;

		case currentStateH is

			when H_FRONT_PORCH =>
				if pixelCount < H_FRONT_PIXELS then
					nextPixelCount <= pixelCount + 1;
					nextStateH <= H_FRONT_PORCH;
				else
					nextStateH <= H_SYNC;
					nextPixelCount <= 0;
				end if;

			when H_SYNC =>
				if pixelCount < H_SYNC_PIXELS then
					nextPixelCount <= pixelCount + 1;
					nextStateH <= H_SYNC;
				else
					nextStateH <= H_BACK_PORCH;
					nextPixelCount <= 0;
				end if;

			when H_BACK_PORCH =>
				if pixelCount < H_BACK_PIXELS then
					nextPixelCount <= pixelCount + 1;
					nextStateH <= H_BACK_PORCH;
				else
					nextStateH <= DATA;
					nextPixelCount <= 0;
				end if;

			when DATA =>
				if pixelCount < H_PIXELS then
					nextPixelCount <= pixelCount + 1;
					nextStateH <= DATA;
				else
					nextPixelCount <= 0;
					nextStateH <= H_FRONT_PORCH;
				end if;

		end case;

	end process;

	buttonCommit : process(clk, reset)
	begin

		if reset = '0' then
			current_button_state <= IDLE;
			active_country <= FRANCE;

		elsif rising_edge(clk) then

			if current_button_state /= next_button_state then
				debounceAcc <= 0;
			--elsif current_button_state = PRE_PUSH OR current_button_state = POST_PUSH then
			else
				debounceAcc <= debounceAcc + 1;
			end if;

			if current_button_state = PUSH then
				active_country <= next_country;
			end if;

			current_button_state <= next_button_state;

		end if;

	end process;

	buttonBounce : process(adv, current_button_state, debounceAcc)
	begin

		case current_button_state is

			when IDLE =>
				if adv = '0' then
					next_button_state <= PRE_PUSH;
				else
					next_button_state <= IDLE;
				end if;

			when PRE_PUSH =>
				if adv = '0' then
					if debounceAcc >= MaxDebounceAcc then
						next_button_state <= PUSH;
					else
						next_button_state <= PRE_PUSH;
					end if;
				else
					next_button_state <= IDLE;
				end if;

			when PUSH =>
				next_button_state <= POST_PUSH;

			when POST_PUSH =>
				if adv = '0' then
					next_button_state <= POST_PUSH;
				else
					next_button_state <= POST_RELEASE;
				end if;

			when POST_RELEASE =>
				if adv = '0' then
					next_button_state <= POST_PUSH;
				else
					if debounceAcc >= MaxDebounceAcc then
						next_button_state <= IDLE;
					else
						next_button_state <= POST_RELEASE;
					end if;
				end if;				

		end case;

	end process;

	countrySelection : process(active_country)
	begin
		case active_country is
			when FRANCE =>
				next_country <= ITALY;
				leftColor <= BLUE;
				midColor <= WHITE;
				rightColor <= RED;
			
			when ITALY =>
				next_country <= IRELAND;
				leftColor <= DGREEN;
				midColor <= WHITE;
				rightColor <= DRED;

			when IRELAND =>
				next_country <= BELGIUM;
				leftColor <= DGREEN;
				midColor <= WHITE;
				rightColor <= ORANGE;

			when BELGIUM =>
				next_country <= MALI;
				leftColor <= BLACK;
				midColor <= YELLOW;
				rightColor <= RED;
			
			when MALI =>
				next_country <= CHAD;
				leftColor <= GREEN;
				midColor <= YELLOW;
				rightColor <= DRED;

			when CHAD =>
				next_country <= NIGERIA;
				leftColor <= DBLUE;
				midColor <= YELLOW;
				rightColor <= DRED;

			when NIGERIA =>
				next_country <= IVORY_COAST;
				leftColor <= DGREEN;
				midColor <= WHITE;
				rightColor <= DGREEN;

			when IVORY_COAST =>
				next_country <= FRANCE;
				leftColor <= ORANGE;
				midColor <= WHITE;
				rightColor <= GREEN;
		end case;
	end process;
	
end architecture rtl;
