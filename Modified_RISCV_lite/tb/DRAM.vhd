library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use work.constants.all;

entity DRAM is
	port( CLK          : in std_logic;
		  RST          : in std_logic;
		  DATA_ADDR_in : in std_logic_vector(NBIT-1 downto 0);
		  DATA_in      : in std_logic_vector(NBIT-1 downto 0);
		  MemWrite     : in std_logic;
		  MemRead      : in std_logic;
		  DATA_out     : out std_logic_vector(NBIT-1 downto 0));
end DRAM;

architecture bhv of DRAM is

signal DATA_ADDR_masked : std_logic_vector(NBIT-1 downto 0);
signal DATA_ADDR : std_logic_vector(9 downto 0); -- 1024 addressable by 10-bit address
-- Memory array definition
type datamem is array (0 to MEM_size-1) of std_logic_vector(NBIT-1 downto 0);
signal DRAMmem : datamem;

begin

	DATA_ADDR_masked <= std_logic_vector((unsigned(DATA_ADDR_in) - unsigned(BASE_ADDR_data)));
	DATA_ADDR <= DATA_ADDR_masked(11 downto 2);

	process(RST, CLK)
	file mem_fp: text;
	variable data_line : line;
	variable index : integer;
	variable tmp : std_logic_vector(NBIT-1 downto 0);
	begin 
		if (RST = '0') then
			DATA_out <= (others => '0');
			file_open(mem_fp, path_DRAM, READ_MODE);
			index := 0;
			while (not endfile(mem_fp)) loop
				readline(mem_fp, data_line);
				hread(data_line, tmp);
				DRAMmem(index) <= tmp;       
				index := index + 1;
			end loop;
			file_close(mem_fp);
		elsif falling_edge(CLK) then
			if (MemRead = '1') then -- Load
				DATA_out <= DRAMmem(to_integer(unsigned(DATA_ADDR)));
			elsif	(MemWrite = '1') then -- Store
				DRAMmem(to_integer(unsigned(DATA_ADDR))) <= DATA_in;
			end if;
		end if;
	end process;

end bhv;
