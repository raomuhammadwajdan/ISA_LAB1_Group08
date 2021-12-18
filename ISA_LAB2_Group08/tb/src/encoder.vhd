
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity ENCODER is 	
	Port (	B:	In	std_logic_vector(2 downto 0);
		Vp:	Out	std_logic_vector(2 downto 0));
end ENCODER;

architecture behavioral of ENCODER is 
begin
	process(B)
	begin		
		CASE B IS
			WHEN  "000"  =>  Vp <= "000" ; -- 0
			WHEN  "001"  =>  Vp <= "001" ; -- +A
			WHEN  "010"  =>  Vp <= "001" ; -- +A
			WHEN  "011"  =>  Vp <= "011" ; -- +2A
			WHEN  "100"  =>  Vp <= "100" ; -- -2A
			WHEN  "101"  =>  Vp <= "010" ; -- -A
			WHEN  "110"  =>  Vp <= "010" ; -- -A
			WHEN  "111"  =>  Vp <= "101" ; -- 0
			when others  =>  Vp <= "ZZZ";
  		END CASE;
	end process;

end architecture behavioral; 