library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;

entity ABS_Value is 
	port( DIN  : in std_logic_vector(NBIT-1 downto 0);
		  DOUT : out std_logic_vector(NBIT-1 downto 0));
end ABS_Value;

architecture bhv of ABS_Value is
begin
	process(DIN)
	variable tmp : std_logic_vector(NBIT-1 downto 0);
	begin
		if(DIN(NBIT-1) = '0') then -- if the MSB is 0 the value is already positive
			DOUT <= DIN;
		else -- if it is negative, complement every bit and add +1
			for i in 0 to NBIT-1 loop
				tmp(i) := not(DIN(i));
			end loop;
			DOUT <= tmp + 1;
		end if;
	end process;
end bhv;