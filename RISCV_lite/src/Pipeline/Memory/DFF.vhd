library IEEE;
use IEEE.std_logic_1164.all;

entity DFF is
	port( D   : in std_logic;
		  CLK : in std_logic; 
		  RST : in std_logic;
		  Q   : out std_logic);
end DFF;

architecture bhv of DFF is
begin
	process(CLK, RST)
	begin
		if(RST = '0') then
			Q <= '0';
		elsif(CLK = '1' and CLK'event) then
			Q <= D;
		end if;
	end process;
end bhv;
