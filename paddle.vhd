library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity paddle is
    generic(
        PaddleUpdate : integer


    );
    port(
            clk : in std_logic;
            hPos : in unsigned(10 downto 0);
            vPos : in unsigned(9 downto 0);
            paddle_status : out std_logic;
            ADC_in :in std_logic_vector(11 downto 0);

    );
end entity paddle;


architecture RTL of paddle is

    signal PC : unsigned(10 downto 0) :=320; --Center of paddle Horizontal position
    signal PL : unsigned(10 downto 0); --Upper left corner of paddle position
    signal DX : unsigned(10 downto 0);
    signal nPC : unsigned(10 downto 0);
    signal PR : unsigned(10 downto 0); --Upper right corner of paddle position
    signal count :integer :=0;
    signal update :std_logic :='0';
    
    begin



    -- Determine if pixel is part of paddle or not
    P_status:process(hPos,vPos)
    begin
        -- check for vertical position to be one of last 5 lines
        if(vPos>474) then
            if hPos>=PL and hPos<=PR then
                -- Pixel is part of paddle between left and right edges
                paddle_status<='1';
            else
                paddle_status<='0';
            end if;
        else
            paddle_status<='0';
        end if;


    end process P_status;


    --Rate at which paddle position updates
    P_update : process(clk)
    begin
        if rising_edge(clk)then
            if count = PaddleUpdate then
                count<=0;
                update<='1';
            else
                count<=count+1;
                update<='0';
            end if;
        end if;
    end process P_update;

    -- Determine rate of change of paddle position
    P_rate : process()
    begin


    end process P_rate;

    -- Update position of paddle
    P_position : process(update)
    begin
        if update='1' then
            PC<=nPC;
        end if;



    end process P_position;



    nPC<=PC+DX;
    PL<=PC-20;
    PR<=PC+20;
end architecture RTL;