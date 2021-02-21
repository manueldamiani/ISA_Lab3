library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.numeric_std.all;
use work.constants.all;
use work.ALU_OPs.all;

entity ALU is
	port( OP1     : in std_logic_vector(NBIT-1 downto 0);   -- coming from ID/EX pipeline reg, read data 1
		  OP2     : in std_logic_vector(NBIT-1 downto 0);   -- coming from mux after ID/EX pipeline reg, read data 2 OR immediate based on signal ALUSrc
		  ALU_OPC : in std_logic_vector(ALU_OPC_SIZE-1 downto 0); -- coming from Control Unit
		  ZERO    : out std_logic; -- Zero flag, going to EX/MEM Pipeline reg
		  ALU_RES : out std_logic_vector(NBIT-1 downto 0)); -- going to EX/MEM Pipeline reg
end ALU;

architecture bhv of ALU is
-- Component declarations
component ABS_Value is 
	port( DIN  : in std_logic_vector(NBIT-1 downto 0);
		  DOUT : out std_logic_vector(NBIT-1 downto 0));
end component;

-- Signal declarations
signal RES : std_logic_vector(NBIT-1 downto 0) := (others => '0');
signal ABSIN, ABSOUT : std_logic_vector(NBIT-1 downto 0) := (others => '0');

begin
	ZERO <= '1' when (unsigned(RES) = 0) else '0'; -- Setting the zero flag to '1' when the result is '0'
	ALU_RES <= RES;
	ABSIN <= OP1;
	ABS0 : ABS_Value port map(DIN => ABSIN, DOUT => ABSOUT);
	
	ALU_Proc: process(OP1, OP2, ALU_OPC, ABSOUT)
	begin
	RES <= (others => '0');-- Tentative solution to inferred latch problem
		case(ALU_OPC) is
			when FUNCT_SRAI => for i in 0 to NBIT-1 loop
						if(i <= to_integer(unsigned(OP2))) then
							RES(NBIT-1) <= OP1(NBIT-1);
							RES(NBIT-2-i downto 0) <= OP1(NBIT-2 downto i);
						end if;
					    end loop;

			when FUNCT_ADD => RES <= std_logic_vector(signed(OP1) + signed(OP2)); -- Operands can be signed

			when FUNCT_ANDI => RES <= OP1 and OP2;

			when FUNCT_XOR => RES <= OP1 xor OP2;

			when FUNCT_SLT => if (OP1 < OP2) then
						 	RES(NBIT-1 downto 1) <= (others => '0');
							RES(0) <= '1';
						 else
							RES <= (others => '0');
						 end if;
						 
			when FUNCT_ABS => RES <= ABSOUT;
			
			when others => RES <= (others => '0');
		end case;
	end process ALU_Proc;
end bhv;
