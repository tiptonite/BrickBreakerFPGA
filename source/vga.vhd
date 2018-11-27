library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity VGA is
	
	port(
		clk    : in std_logic;
		reset  : in std_logic;
        VGA_B  : out std_logic_vector(3 downto 0) := (others => '0');
        VGA_G  : out std_logic_vector(3 downto 0) := (others => '0');
        VGA_HS : out std_logic 					  := '0';
        VGA_R  : out std_logic_vector(3 downto 0) := (others => '0');
        VGA_VS : out std_logic 					  := '0';
        hPos   : out integer;
        vPos   : out integer;
        status : in std_logic_vector(3 downto 0)  := (others => '0')
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


begin

	commit : process(clk)
	begin

		if rising_edge(clk) then

			currentStateV <= nextStateV;
			currentStateH <= nextStateH;
			pixelCount <= nextPixelCount;
			pixelCountV <= nextPixelCountV;

			if currentStateH = DATA AND currentStateV = DATA then
				-- Paddle
				if status(0) = '1' then
					VGA_B <= "0110";
					VGA_G <= "0110";
					VGA_R <= "1001";
				-- Ball
				elsif status(1) = '1' then
					VGA_B <= "1111";
					VGA_G <= "0000";
					VGA_R <= "0000";
				-- Brick
				elsif status(2) = '1' then
					VGA_B <= "0000";
					VGA_G <= "0000";
					VGA_R <= "1111";
				-- Mortar
				elsif status(3) = '1' then
					VGA_B <= "1111";
					VGA_G <= "1111";
					VGA_R <= "1111";
				-- Background
				else
					VGA_B <= "0000";
					VGA_G <= "0000";
					VGA_R <= "0000";
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
					else
						lineCount <= 0;
					end if;
				else
					lineCount <= 0;
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
	
end architecture rtl;
