library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.constants.all;

entity registerfile is
	port( CLK     : in std_logic;
		  RST     : in std_logic;
		  ENABLE  : in std_logic;
		  RS1     : in std_logic; 
		  RS2     : in std_logic; 
		  WR      : in std_logic;
		  ADD_WR  : in std_logic_vector(NBIT_ADD-1 downto 0); -- coming from MEM/WB pipeline reg
		  ADD_RS1 : in std_logic_vector(NBIT_ADD-1 downto 0); -- extracted from the instruction
		  ADD_RS2 : in std_logic_vector(NBIT_ADD-1 downto 0); -- extracted from the instruction
		  DATAIN  : in std_logic_vector(NBIT-1 downto 0); -- data coming from the output mux after the MEM/WB reg
		  OUT1    : out std_logic_vector(NBIT-1 downto 0); -- sent to ID/EX pipeline reg
		  OUT2    : out std_logic_vector(NBIT-1 downto 0)); -- sent to ID/EX pipeline reg
end registerfile;

architecture bhv of registerfile is
      
    subtype REG_ADDR is natural range 0 to (2**NBIT_ADD - 1); -- using natural type
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(NBIT-1 downto 0); 
	signal REGISTERS : REG_ARRAY; 
	
begin 

	proc: process(CLK,RST)
	begin
		if(RST = '0') then -- Asynchronous, active low
			REGISTERS <= (others => (others => '0')); -- The whole array is reset to zero
		elsif(CLK = '1' and CLK'event) then
			if(ENABLE = '1') then -- Enable active high, read and write can be simultaneous
				if(WR = '1') then -- write to register
					REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN;
				end if;

				if(RS1 = '1') then -- read from register, port 1
					if (WR = '1') and (ADD_WR = ADD_RS1) then
						OUT1 <= DATAIN; --if the data to be written is needed as a source for the current instruction,
								-- it is directly provided to the output of the register file
					else
						OUT1 <= REGISTERS(to_integer(unsigned(ADD_RS1)));
					end if;
				end if;

				if(RS2 = '1') then -- read from register, port 2
					if (WR = '1') and (ADD_WR = ADD_RS2) then
						OUT2 <= DATAIN;--if the data to be written is needed as a source for the current instruction,
								-- it is directly provided to the output of the register file
					else
						OUT2 <= REGISTERS(to_integer(unsigned(ADD_RS2)));
					end if;
				end if;
			end if;
		end if;
	end process proc;

end bhv;
