-- Once the type is derived, the RS1, RS2, RD and IMM fields are extracted
library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;
use work.instruction_set.all;

entity instruction_decomposition is
	port( INST_IN : in std_logic_vector(NBIT-1 downto 0); -- instruction to be split into the various fields coming from IF/ID register pipe
		  Rtype   : in std_logic;
		  Itype   : in std_logic;
		  Utype   : in std_logic;
		  Btype  : in std_logic;
		  Jtype  : in std_logic;
		  Stype   : in std_logic;
		  ADD_RS1 : out std_logic_vector(NBIT_ADD-1 downto 0); -- sent to regfile
		  ADD_RS2 : out std_logic_vector(NBIT_ADD-1 downto 0); -- sent to regfile
		  ADD_RD  : out std_logic_vector(NBIT_ADD-1 downto 0); -- sent to intermediate reg in ID stage, to be used in writeback
		  IMM     : out std_logic_vector(NBIT-1 downto 0); -- sent to intermediate reg in ID stage
		  RS1     : out std_logic; -- sent to regfile
		  RS2     : out std_logic); -- sent to regfile
end instruction_decomposition;

architecture bhv of instruction_decomposition is

begin
	
	inst_decomp : process(INST_IN, Rtype, Itype, Utype, Btype, Jtype, Stype)
	variable func3 : std_logic_vector(Funct3_begin downto Funct3_end) := (others => '0');
	begin

		ADD_RS1 <= (others => '0');
		ADD_RS2 <= (others => '0');
		ADD_RD <= (others => '0');
		IMM <= (others => '0');
		RS1 <= '0';     
		RS2 <= '0';      

		if (Rtype = '1') then
			ADD_RS1 <= INST_IN(RS1_begin downto RS1_end);
			ADD_RS2 <= INST_IN(RS2_begin downto RS2_end);
			ADD_RD <= INST_IN(RD_begin downto RD_end);
			
			RS1 <= '1';     
			RS2 <= '1'; 

		elsif (Itype = '1') then
			ADD_RS1 <= INST_IN(RS1_begin downto RS1_end);
			ADD_RD <= INST_IN(RD_begin downto RD_end);
			
			RS1 <= '1';     
			RS2 <= '0';

			func3 := INST_IN(Funct3_begin downto Funct3_end); -- Extract the Funct3 fields from the instruction
			if (func3 = SRAI_Funct3) then
				IMM <= (NBIT-1 downto 5 => '0') & INST_IN(IMM12_end+4 downto IMM12_end); -- SRAI instruction
			else
				IMM <= (NBIT-1 downto IMM12_size => INST_IN(IMM12_begin)) & INST_IN(IMM12_begin downto IMM12_end); -- ADDI, LW, ANDI instructions
			end if;

		elsif (Utype = '1') then
			ADD_RD <= INST_IN(RD_begin downto RD_end);
			
			RS1 <= '0';     
			RS2 <= '0';

			IMM <= INST_IN(IMM20_begin downto IMM20_end) & (IMM20_end-1 downto 0 => '0'); -- AUIPC, LUI instructions
		elsif (Btype='1') then
			ADD_RS1 <= INST_IN(RS1_begin downto RS1_end);
			ADD_RS2 <= INST_IN(RS2_begin downto RS2_end);
			
			RS1 <= '1';     
			RS2 <= '1';

			IMM <= (NBIT-1 downto IMM12_size => INST_IN(IMM7_begin)) & INST_IN(IMM7_begin) & INST_IN(IMM5_end) & INST_IN(IMM7_begin-1 downto IMM7_end) & INST_IN(IMM5_begin downto IMM5_end+1); -- BEQ instruction
		elsif (Jtype = '1') then
			ADD_RD <= INST_IN(RD_begin downto RD_end);

			RS1 <= '0';     
			RS2 <= '0';

			IMM <= (NBIT-1 downto IMM20_size => INST_IN(IMM20_begin)) & INST_IN(IMM20_begin) & INST_IN(IMM20_size-1 downto IMM20_end) & INST_IN(IMM20_size) & INST_IN(IMM20_begin-1 downto IMM20_size+1); -- JAL instruction

		elsif (Stype = '1') then
			ADD_RS1 <= INST_IN(RS1_begin downto RS1_end);
			ADD_RS2 <= INST_IN(RS2_begin downto RS2_end);
			
			RS1 <= '1';     
			RS2 <= '1'; 

			IMM <= (NBIT-1 downto IMM12_size => INST_IN(IMM7_begin)) & INST_IN(IMM7_begin downto IMM7_end) & INST_IN(IMM5_begin downto IMM5_end); -- SW instruction

		end if;

	end process inst_decomp;

end bhv;



