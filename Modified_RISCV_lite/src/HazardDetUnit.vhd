library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all;
use work.instruction_set.all;
use work.ALU_OPs.all;


entity HazardDetUnit is
	port( 	RST : in std_logic;
			RS1_IFID : in std_logic_vector(NBIT_ADD-1 downto 0);
			RS2_IFID : in std_logic_vector(NBIT_ADD-1 downto 0);
			RD_IDEX : in std_logic_vector(NBIT_ADD-1 downto 0);
			MemRead_IDEX : in std_logic;
			INS_INPUT: in std_logic_vector(NBIT-1 downto 0);
			PC_INPUT : in std_logic_vector(NBIT-1 downto 0);
			Bubble_out: out std_logic;
			INS_OUTPUT_HDU: out std_logic_vector(NBIT-1 downto 0);
			PC_OUPUT_HDU : out std_logic_vector(NBIT-1 downto 0);
			PC_inc_HDU : out std_logic_vector(NBIT-1 downto 0));-- Bubble ='1' if there is a stall  
end HazardDetUnit;

architecture bhv of HazardDetUnit is
begin

	INS_OUTPUT_HDU <= INS_INPUT;
	PC_OUPUT_HDU <= PC_INPUT;
	PC_inc_HDU <= PC_INPUT + 4;
	
	process(RST,RS1_IFID,RS2_IFID,RD_IDEX,MemRead_IDEX)
	begin
		Bubble_out <= '0';
		if(RST = '0') then
			Bubble_out <='0';
		elsif(MemRead_IDEX='1') then
			if(RD_IDEX = RS1_IFID OR RD_IDEX = RS2_IFID) then
				Bubble_out <='1';
			else
				Bubble_out <='0';
			end if;
		end if;
	end process;
end bhv;
