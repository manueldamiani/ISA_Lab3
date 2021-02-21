-- From the instruction coming from the IF stage, its type is derived (R , I , U, SB, UJ ,S)
library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;
use work.instruction_set.all;

entity instruction_type is
	port( INST_IN : in std_logic_vector(NBIT-1 downto 0); -- instruction to be split into the various fields coming from IF/ID register pipe
		  Rtype   : out std_logic;
		  Itype   : out std_logic;
		  Utype   : out std_logic;
		  Btype  : out std_logic;
		  Jtype  : out std_logic;
		  Stype   : out std_logic);
end instruction_type;

architecture bhv of instruction_type is 

-- Signal declarations
signal opcode : std_logic_vector(OPCODE_size-1 downto 0);
begin
	opcode <= INST_IN(OPCODE_size-1 downto 0); --extract the opcode from the intruction

	inst_type : process(opcode)
	begin
		Rtype <= '0';
		Itype <= '0';
		Utype <= '0';
		Btype <= '0';
		Jtype <= '0';
		Stype <= '0'; 

		case opcode is
			when ADD_OP  =>  Rtype <= '1'; -- ADD_OP == XOR_OP == SLT_OP
			
			when LW_OP  =>  Itype <= '1';
			when SRAI_OP =>  Itype <= '1'; -- SRAI_OP == ADDI_OP == ANDI_OP

			when SW_OP =>  Stype <= '1';
			
			when BEQ_OP =>  Btype <= '1';

			when LUI_OP | AUIPC_OP =>  Utype <= '1';

			when JAL_OP =>  Jtype <= '1';

			when others =>  Rtype <= '0';
							Itype <= '0';
							Stype <= '0';
							Btype <= '0';
							Utype <= '0';
							Jtype <= '0';
		end case;
	end process inst_type;				
end bhv;
