library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity BOOT_ENC is 
	Generic(n_op_2: integer);
	Port (	B:	In	std_logic_vector(n_op_2-1 downto 0);
		ENC:	Out	std_logic_vector(3*(n_op_2/2)-1 downto 0));		
end BOOT_ENC;

architecture structural of BOOT_ENC is 

component ENCODER is 
	Port (	B:	In	std_logic_vector(2 downto 0);
		Vp:	Out	std_logic_vector(2 downto 0));
end component ENCODER;

type t_enc is array (0 to n_op_2/2) of std_logic_vector(2 downto 0);
signal enc_in: t_enc;

begin
	enc_in(0)(2) <= B(1);
	enc_in(0)(1) <= B(0);
	enc_in(0)(0) <= '0';

	conn_in: for i in 1 to n_op_2/2-1 generate
	begin 
		enc_in(i)(2) <= B(2*i+1);
		enc_in(i)(1) <= B(2*i);
		enc_in(i)(0) <= B(2*i-1);
	end generate;

	gen_enc: for i in 0 to n_op_2/2-1 generate
	begin 
--	if1:	if i = 0 generate
--		encx: ENCODER 
--			generic map(3)
--			port map(B => enc_in(0), Vp => ENC(2 downto 0));
--		end generate;
	encx: ENCODER 
		port map(B => enc_in(i), Vp => ENC((i+1)*3-1 downto (i+1)*3-3));
	end generate;

end architecture structural; 


