library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.constants.all;

entity FWD_Unit is
	port (	RST 		   : in std_logic;
			RS1 		   : in std_logic_vector(NBIT_ADD-1 downto 0); -- Ex stage RS1
			RS2 		   : in std_logic_vector(NBIT_ADD-1 downto 0); -- Ex stage RS2
			RD_EXMEM	   : in std_logic_vector(NBIT_ADD-1 downto 0); -- Mem stage RD
			RD_MEMWB       : in std_logic_vector(NBIT_ADD-1 downto 0); -- WB stage RD
			RegWrite_EXMEM : in std_logic; -- Mem stage RegWrite
			RegWrite_MEMWB : in std_logic; -- WB stage RegWrite
			ForwardA 	   : out std_logic_vector(1 downto 0); -- 00 OP1 from RF, 10 OP1 forwarded from EXMEM, 01 OP1 from MEMWB
			ForwardB 	   : out std_logic_vector(1 downto 0));  -- 00 OP2 from RF, 10 OP2 forwarded from EXMEM, 01 OP2 from MEMWB
end FWD_Unit;

architecture bhv of FWD_Unit is
begin
	process(RST, RS1, RS2, RD_EXMEM, RD_MEMWB, RegWrite_EXMEM, RegWrite_MEMWB)
	begin
		ForwardA <= "11";
		ForwardB <= "11";

		if (RST = '0') then
		ForwardA <= (others => '0');
		ForwardB <= (others => '0');
		else

			if(RS1 = RD_EXMEM) then
				if(RegWrite_EXMEM = '1' and RD_EXMEM /=  "00000") then
					ForwardA <= "10";
				end if;
			elsif((RS1 = RD_MEMWB) AND (RD_EXMEM /= RS1 OR RegWrite_EXMEM = '0')) then
				if(RegWrite_MEMWB = '1' and RD_MEMWB /=  "00000") then
					ForwardA <= "01";
				end if;
			else
				ForwardA <= "00";
			end if;

			if(RS2 = RD_EXMEM) then
				if(RegWrite_EXMEM = '1' and RD_EXMEM /=  "00000") then
					ForwardB <= "10";
				end if;
			elsif((RS2 = RD_MEMWB) AND (RD_EXMEM /= RS2 OR RegWrite_EXMEM = '0')) then
				if(RegWrite_MEMWB = '1' and RD_MEMWB /=  "00000") then
					ForwardB <= "01";
				end if;
			else
				ForwardB <= "00";
			end if;
		end if;
	end process;

end bhv;
