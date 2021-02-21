library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all;

entity EX_MEM is
	port( CLK          : in std_logic; 
		  RST	       : in std_logic;
		  PCext_in	   : in std_logic_vector(NBIT-1 downto 0);
		  Zero_in      : in std_logic;
		  ALU_RES_in   : in std_logic_vector(NBIT-1 downto 0);
		  RF_Data2_IN  : in std_logic_vector(NBIT-1 downto 0);
		  ADD_RD_in    : in std_logic_vector(NBIT_ADD-1 downto 0);
		  Branch_in    : in std_logic;
		  Branch_type_in : in std_logic;
		  RegWrite_in  : in std_logic;
		  MemWrite_in  : in std_logic;
		  MemRead_in   : in std_logic;
		  MemtoReg_in  : in std_logic;
		  PCext_out	   : out std_logic_vector(NBIT-1 downto 0);
		  Zero_out     : out std_logic;
		  ALU_RES_out  : out std_logic_vector(NBIT-1 downto 0);
		  RF_Data2_OUT : out std_logic_vector(NBIT-1 downto 0);
		  ADD_RD_out   : out std_logic_vector(NBIT_ADD-1 downto 0);
		  Branch_out   : out std_logic;
		  Branch_type_out : out std_logic;
		  RegWrite_out : out std_logic;
		  MemWrite_out : out std_logic;
		  MemRead_out  : out std_logic;
		  MemtoReg_out : out std_logic);
end EX_MEM;

architecture bhv of EX_MEM is
begin
	process(CLK, RST)
	begin
		if(RST = '0') then
			PCext_out <= (others => '0');
			Zero_out <= '0';
			ALU_RES_out <= (others => '0');
		  	RF_Data2_OUT <= (others => '0');
		  	ADD_RD_OUT <= (others => '0');
		  	Branch_out <= '0';
			Branch_type_out <='0';
			RegWrite_out <= '0';
			MemWrite_out <= '0';
			MemRead_out <= '0';
			MemtoReg_out <= '0';
		elsif(CLK = '1' and CLK'event) then
			PCext_OUT <= PCext_in;
			Zero_out <= Zero_in;
			ALU_RES_out <= ALU_RES_in;
		  	RF_Data2_OUT  <= RF_Data2_IN;
		  	ADD_RD_OUT <= ADD_RD_IN;
		  	Branch_out <= Branch_in;
			Branch_type_out <= Branch_type_in;
			RegWrite_out <= RegWrite_in;
			MemWrite_out <= MemWrite_in;
			MemRead_out <= MemRead_in;
			MemtoReg_out <= MemtoReg_in;
		end if;
	end process;
end bhv;
