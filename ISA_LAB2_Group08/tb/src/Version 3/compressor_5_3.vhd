LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY compressor_5_3 IS
	PORT(
		a, b, c, d, cin: IN std_logic; 
		sum, cout, carry: OUT std_logic);
END ENTITY;

architecture BEHAVIORAL of compressor_5_3 is

begin

  sum <= a xor b xor C xor d xor cin;
  cout <= ((a xor b) and c) or (not(a xor b) and a);
  carry <= ((a xor b xor C xor d) and cin) or (not(a xor b xor C xor d) and d);
end BEHAVIORAL;
