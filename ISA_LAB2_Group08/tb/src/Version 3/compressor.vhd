LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY compressor_4_2 IS
	PORT(
		PP1, PP2, PP3, PP4: IN std_logic; 
		sum, carry: OUT std_logic);
END ENTITY;

ARCHITECTURE myarch OF compressor_4_2 IS
BEGIN
	sum <= not(PP3 xor PP4);
	carry <= not( (not(PP1 or PP2)) or (not(PP3 or PP4)) );
END ARCHITECTURE;