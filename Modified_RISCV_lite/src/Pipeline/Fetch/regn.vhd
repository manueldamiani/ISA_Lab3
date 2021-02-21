library IEEE;
use IEEE.std_logic_1164.all;

entity regn is
	generic(N : integer);
	port( DIN  : in std_logic_vector(N-1 downto 0);
		  CLK  : in std_logic; 
		  RST  : in std_logic;
		  DOUT : out std_logic_vector(N-1 downto 0));
end regn;

architecture bhv of regn is
begin
	process(CLK, RST)
	begin
		if(RST = '0') then
			DOUT <= (others => '0');
		elsif(CLK = '1' and CLK'event) then
			DOUT <= DIN;
		end if;
	end process;
end bhv;
