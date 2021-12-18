library ieee;
use ieee.std_logic_1164.all;

entity compressor_5_3_tb is
end compressor_5_3_tb;

architecture tb of compressor_5_3_tb is

   component compressor_5_3 is
      port(a, b, c, d, cin: IN std_logic;
            sum, cout, carry: OUT std_logic);
   end component;

   signal a, b, c, d, cin, sum, cout, carry: std_logic;

begin
   mapping: compressor_5_3 port map(a, b, c, d, cin, sum, cout, carry);
   
   process
   begin

   --TEST 1
	a <= '0';
	b <= '0';
	c <= '0';
	d <= '0';
	cin <= '0';
    wait for 5 ns;
	
	--TEST 2
	a <= '1';
    	b <= '0';
	c <= '0';
	d <= '0';
	cin <= '0';
    wait for 5 ns;
	
	--TEST 3
	a <= '0';
    	b <= '1';
	c <= '0';
	d <= '0';
	cin <= '0';
    wait for 5 ns;
	
	--TEST 4
	a <= '1';
    	b <= '1';
	c <= '0';
	d <= '0';
	cin <= '0';
    wait for 5 ns;
	
	--TEST 5
	a <= '0';
    	b <= '0';
	c <= '1';
	d <= '0';
	cin <= '0';
    wait for 5 ns;
	
	--TEST 6
	a <= '1';
    	b <= '0';
	c <= '1';
	d <= '0';
	cin <= '0';
    wait for 5 ns;
	
	--TEST 7
	a <= '0';
    	b <= '1';
	c <= '1';
	d <= '0';
	cin <= '0';
    wait for 5 ns;
	
	--TEST 8
	a <= '1';
    	b <= '1';
	c <= '1';
	d <= '0';
	cin <= '0';
    wait for 5 ns;
	
	--TEST 9
	a <= '0';
   	b <= '0';
	c <= '0';
	d <= '1';
	cin <= '0';
    wait for 5 ns;

	--TEST 10
	a <= '1';
    	b <= '0';
	c <= '0';
	d <= '1';
	cin <= '0';
    wait for 5 ns;
	
	--TEST 11
	a <= '0';
    	b <= '1';
	c <= '0';
	d <= '1';
	cin <= '0';
    wait for 5 ns;
	
	--TEST 12
	a <= '1';
    	b <= '1';
	c <= '0';
	d <= '1';
	cin <= '0';
    wait for 5 ns;
	
	--TEST 13
	a <= '0';
    	b <= '0';
	c <= '1';
	d <= '1';
	cin <= '0';
    wait for 5 ns;
	
	--TEST 14
	a <= '1';
    	b <= '0';
	c <= '1';
	d <= '1';
	cin <= '0';
    wait for 5 ns;
	
	--TEST 15
	a <= '0';
    	b <= '1';
	c <= '1';
	d <= '1';
	cin <= '0';
    wait for 5 ns;
	
	--TEST 16
	a <= '1';
    	b <= '1';
	c <= '1';
	d <= '1';
	cin <= '0';
    wait for 5 ns;

   	--TEST 17
	a <= '0';
    	b <= '0';
	c <= '0';
	d <= '0';
	cin <= '1';
    wait for 5 ns;
	
	--TEST 18
	a <= '1';
    	b <= '0';
	c <= '0';
	d <= '0';
	cin <= '1';
    wait for 5 ns;
	
	--TEST 19
	a <= '0';
    	b <= '1';
	c <= '0';
	d <= '0';
	cin <= '1';
    wait for 5 ns;
	
	--TEST 20
	a <= '1';
    	b <= '1';
	c <= '0';
	d <= '0';
	cin <= '1';
    wait for 5 ns;
	
	--TEST 21
	a <= '0';
    	b <= '0';
	c <= '1';
	d <= '0';
	cin <= '1';
    wait for 5 ns;
	
	--TEST 22
	a <= '1';
    	b <= '0';
	c <= '1';
	d <= '0';
	cin <= '1';
    wait for 5 ns;
	
	--TEST 23
	a <= '0';
    	b <= '1';
	c <= '1';
	d <= '0';
	cin <= '1';
    wait for 5 ns;
	
	--TEST 24
	a <= '1';
    	b <= '1';
	c <= '1';
	d <= '0';
	cin <= '1';
    wait for 5 ns;
	
	--TEST 25
	a <= '0';
    	b <= '0';
	c <= '0';
	d <= '1';
	cin <= '1';
    wait for 5 ns;

	--TEST 26
	a <= '1';
    	b <= '0';
	c <= '0';
	d <= '1';
	cin <= '1';
    wait for 5 ns;
	
	--TEST 27
	a <= '0';
    	b <= '1';
	c <= '0';
	d <= '1';
	cin <= '1';
    wait for 5 ns;
	
	--TEST 28
	a <= '1';
    	b <= '1';
	c <= '0';
	d <= '1';
	cin <= '1';
    wait for 5 ns;
	
	--TEST 29
	a <= '0';
    	b <= '0';
	c <= '1';
	d <= '1';
	cin <= '1';
    wait for 5 ns;
	
	--TEST 30
	a <= '1';
    	b <= '0';
	c <= '1';
	d <= '1';
	cin <= '1';
    wait for 5 ns;
	
	--TEST 31
	a <= '0';
    	b <= '1';
	c <= '1';
	d <= '1';
	cin <= '1';
    wait for 5 ns;
	
	--TEST 32
	a <= '1';
    	b <= '1';
	c <= '1';
	d <= '1';
	cin <= '1';
    wait for 5 ns;
	
   end process;
end tb;

----------------------------------------------------------END