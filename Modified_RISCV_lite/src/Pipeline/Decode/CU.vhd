-- Receives instruction, generates control signals
library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;
use work.instruction_set.all;
use work.ALU_OPs.all;

entity CU is
	port( CLK      : in std_logic; 
		  RST	   : in std_logic;
		  Bubble_in_CU : in std_logic;
		  INS_OUT  : in std_logic_vector(NBIT-1 downto 0); -- Coming from IF/ID register
		  Branch   : out std_logic; -- the instruction is a branch (BEQ or JAL)
	  	  Branch_type : out std_logic; -- if Branch_type = '1', it is a JAL instruction, if Branch_type = '0', it is a BEQ instruction
		  RegWrite : out std_logic; -- Writeback signal to regfile
		  ALUSrc1   : out std_logic; -- if '1' operand1 will be the PC, '0' operand1 comes from the regfile
		  ALUSrc2   : out std_logic_vector(1 downto 0); -- if '11' operand2 will be the immediate, '00' operand2 comes from the regfile
														-- if '01' operand2 will be 4 (used for the JAL)
		  ALUOp	   : out std_logic_vector(ALU_OPC_SIZE-1 downto 0); -- To ALU, selection of ALU operation to be performed
		  MemWrite : out std_logic; -- Write to data memory
		  MemRead  : out std_logic; -- Read from data memory
		  MemtoReg : out std_logic); -- if '1', send from data memory to regfile; if '0', take ALU output (from EX/MEM reg) to regfile
end CU;

architecture bhv of CU is

-- Signal declarations
signal CW : std_logic_vector(12 downto 0); -- Branch, Branch_type, RegWrite, ALUSrc2(1 dt 0), ALUSrc1, ALUOp(3 dt 0), MemWrite, MemRead, MemtoReg
begin

	Branch <= CW(12);
	Branch_type <= CW(11);
	RegWrite <= CW(10);
	ALUSrc2 <= CW(9 downto 8);
	ALUSrc1 <= CW(7);
	ALUOp <= CW(6 downto 3);
	MemWrite <= CW(2);
	MemRead <= CW(1);
	MemtoReg <= CW(0);
	
	process(CLK, RST, INS_OUT,Bubble_in_CU)
	begin
		if(RST = '0') then
			CW <= (others => '0');
		elsif(CLK = '1' and CLK'event) then
			if(Bubble_in_CU='1') then 
				CW <= (others => '0');
			else
				case INS_OUT(OPCODE_begin downto OPCODE_end) is
					when RType_Arith => -- ADD, XOR, SLT, ABS
						case INS_OUT(Funct3_begin downto Funct3_end) is
							when ADD_Funct3 => CW <= "001000" & FUNCT_ADD & "000";
							when XOR_Funct3 => CW <= "001000" & FUNCT_XOR & "000";
							when SLT_Funct3 => CW <= "001000" & FUNCT_SLT & "000";
							when ABS_Funct3 => CW <= "001000" & FUNCT_ABS & "000";
							when others => CW <= (others => '0');
						end case;
					when IType_Arith => -- SRAI, ADDI, ANDI
						case INS_OUT(Funct3_begin downto Funct3_end) is
							when SRAI_Funct3 => CW <= "001110" & FUNCT_SRAI & "000";
							when ADDI_Funct3 => CW <= "001110" & FUNCT_ADD & "000";
							when ANDI_Funct3 => CW <= "001110" & FUNCT_ANDI & "000";
							when others => CW <= (others => '0');
						end case;
					when LW_OP => CW <= "001110" & FUNCT_ADD & "011";
					when SW_OP => CW <= "000110" & FUNCT_ADD & "100";
					when BEQ_OP => CW <= "100000" & FUNCT_XOR & "000";
					when LUI_OP => CW <= "001110" & FUNCT_ADD & "000";
					when AUIPC_OP => CW <= "001111" & FUNCT_ADD & "000";
					when JAL_OP => CW <= "111011" & FUNCT_ADD & "000";
					when others => CW <= (others => '0');
				end case;
			end if;
		end if;
	end process;
	
end bhv;
