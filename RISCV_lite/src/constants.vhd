library IEEE;
use IEEE.std_logic_1164.all;

package constants is
	constant NBIT : integer := 32; -- Instructions, data, Program Counter are on 32 bits
	constant NBIT_ADD : integer := 5; -- Address for RS1, RS2 and RD
	constant MEM_size : integer := 1024; -- Memories 1024x32 bit wide = 4kB, both data and instruction
	-- File paths for the Instruction and Data memories
	constant path_IRAM : string := "../asm/IRAM.text";
	constant path_DRAM : string := "../asm/DRAM.data"; 
	-- Base addresses for data and instruction segments
	constant BASE_ADDR_text : std_logic_vector(NBIT-1 downto 0) := x"00400000";
	constant BASE_ADDR_data : std_logic_vector(NBIT-1 downto 0) := x"10010000";

end package;
