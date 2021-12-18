library ieee;
use ieee.std_logic_1164.all;

entity compressor_tb is
end compressor_tb;

architecture tb of compressor_tb is

   component compressor is
      port(PP1, PP2, PP3, PP4: IN std_logic;
            sum, carry: out std_logic);
   end component;

   signal PP1, PP2, PP3, PP4, sum, carry: std_logic;

begin
   mapping: compressor port map(PP1, PP2, PP3, PP4, sum, carry);

   
   process
   begin

   --TEST 1
	PP1 <= '0';
    PP2 <= '0';
	PP3 <= '0';
	PP4 <= '0';
    wait for 5 ns;
	
	--TEST 2
	PP1 <= '1';
    PP2 <= '0';
	PP3 <= '0';
	PP4 <= '0';
    wait for 5 ns;
	
	--TEST 3
	PP1 <= '0';
    PP2 <= '1';
	PP3 <= '0';
	PP4 <= '0';
    wait for 5 ns;
	
	--TEST 4
	PP1 <= '1';
    PP2 <= '1';
	PP3 <= '0';
	PP4 <= '0';
    wait for 5 ns;
	
	--TEST 5
	PP1 <= '0';
    PP2 <= '0';
	PP3 <= '1';
	PP4 <= '0';
    wait for 5 ns;
	
	--TEST 6
	PP1 <= '1';
    PP2 <= '0';
	PP3 <= '1';
	PP4 <= '0';
    wait for 5 ns;
	
	--TEST 7
	PP1 <= '0';
    PP2 <= '1';
	PP3 <= '1';
	PP4 <= '0';
    wait for 5 ns;
	
	--TEST 8
	PP1 <= '1';
    PP2 <= '1';
	PP3 <= '1';
	PP4 <= '0';
    wait for 5 ns;
	
	--TEST 9
	PP1 <= '0';
    PP2 <= '0';
	PP3 <= '0';
	PP4 <= '1';
    wait for 5 ns;

	--TEST 10
	PP1 <= '1';
    PP2 <= '0';
	PP3 <= '0';
	PP4 <= '1';
    wait for 5 ns;
	
	--TEST 11
	PP1 <= '0';
    PP2 <= '1';
	PP3 <= '0';
	PP4 <= '1';
    wait for 5 ns;
	
	--TEST 12
	PP1 <= '1';
    PP2 <= '1';
	PP3 <= '0';
	PP4 <= '1';
    wait for 5 ns;
	
	--TEST 13
	PP1 <= '0';
    PP2 <= '0';
	PP3 <= '1';
	PP4 <= '1';
    wait for 5 ns;
	
	--TEST 14
	PP1 <= '1';
    PP2 <= '0';
	PP3 <= '1';
	PP4 <= '1';
    wait for 5 ns;
	
	--TEST 15
	PP1 <= '0';
    PP2 <= '1';
	PP3 <= '1';
	PP4 <= '1';
    wait for 5 ns;
	
	--TEST 16
	PP1 <= '1';
    PP2 <= '1';
	PP3 <= '1';
	PP4 <= '1';
    wait for 5 ns;
	
   end process;
end tb;

----------------------------------------------------------END