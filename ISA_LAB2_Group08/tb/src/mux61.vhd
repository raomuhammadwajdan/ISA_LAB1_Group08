library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
use ieee.std_logic_unsigned;

entity MUX61_generic is 
	generic (n: integer);
	Port (	A:	In	std_logic_vector(n-1 downto 0); 
		B:	In	std_logic_vector(n-1 downto 0);
		C:	In	std_logic_vector(n-1 downto 0);
		D:	In	std_logic_vector(n-1 downto 0);
		E:	In	std_logic_vector(n-1 downto 0);
		S:	In	std_logic_vector(2 downto 0);
		W:	In 	std_logic_vector(n-1 downto 0);
		Y:	Out	std_logic_vector(n-1 downto 0));
end MUX61_generic ;


architecture BEHAVIORAL of MUX61_generic  is

begin
	pmux: process(A,B,C,D,E,S)
	begin		
		CASE S IS
			WHEN  "000"  =>  Y <= A;
			WHEN  "001"  =>  Y <= B;
			WHEN  "010"  =>  Y <= C;
			WHEN  "011"  =>  Y <= D;
			WHEN  "100"  =>  Y <= E;
			WHEN  "101"  =>  Y <= W;
			WHEN OTHERS =>  Y <= (others => '0'); -- default 
  		END CASE;
	end process;

end BEHAVIORAL;


