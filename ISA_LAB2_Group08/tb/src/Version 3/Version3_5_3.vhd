library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_signed.all;

entity BOOTHMUL is 
	Generic (n_op_1: integer:= 14; 
		n_op_2: integer:= 14);
	Port (	A:	in std_logic_vector(n_op_2-1 downto 0);
		B:	in std_logic_vector(n_op_2-1 downto 0);
		P:	Out std_logic_vector(n_op_2-1 downto 0));
end BOOTHMUL;

architecture mixed of BOOTHMUL is
	
	component HA 
	port ( A:	In	std_logic;
		B:	In	std_logic;
		S:	Out	std_logic;
		Co:	Out	std_logic);
  	end component; 

	component FA 
	port ( A:	In	std_logic;
		B:	In	std_logic;
		Ci:	In	std_logic;
		S:	Out	std_logic;
		Co:	Out	std_logic);
  	end component; 

	component compressor_4_2 
	port ( PP1:	In	std_logic;
		PP2:	In	std_logic;
		PP3:	In	std_logic;
		PP4:	In	std_logic;
		sum:	Out	std_logic;
		carry:	Out	std_logic);
  	end component; 

	component compressor_5_3 
	port ( a:	In	std_logic;
		b:	In	std_logic;
		c:	In	std_logic;
		d:	In	std_logic;
		cin:	In	std_logic;
		sum:	Out	std_logic;
		cout:	Out	std_logic;
		carry:	Out	std_logic);
  	end component; 
	
	component sumx is 
	generic (n1: integer:= 27;
		 n2: integer:= 27);
	port (
	    add1 : in std_logic_vector (n1-1 downto 0);
	    add2 : in std_logic_vector (n2-1 downto 0);
	    sum1: out std_logic_vector (n1-1 downto 0));
	end component;
	
	component MUX61_generic is 
	generic (n: integer);
	Port (	A:	In	std_logic_vector(n-1 downto 0); 
		B:	In	std_logic_vector(n-1 downto 0);
		C:	In	std_logic_vector(n-1 downto 0);
		D:	In	std_logic_vector(n-1 downto 0);
		E:	In	std_logic_vector(n-1 downto 0);
		S:	In	std_logic_vector(2 downto 0);
		W:	In	std_logic_vector(n-1 downto 0);
		Y:	Out	std_logic_vector(n-1 downto 0));
	end component MUX61_generic ;

	component BOOT_ENC is 
		Generic(n_op_2: integer);
		Port (	B:	In	std_logic_vector(n_op_2-1 downto 0);
			ENC:	Out	std_logic_vector(3*(n_op_2/2)-1 downto 0));	
	end component BOOT_ENC;
	
		
	type t_mux_control is array(0 to n_op_2/2-1) of std_logic_vector(2 downto 0);
	type t_muxs_out is array(0 to (n_op_2/2-1)) of std_logic_vector(n_op_1+n_op_2-1 downto 0);

	signal mux_control: t_mux_control;
	signal muxs_out: t_muxs_out;
	
	signal encoders_out: std_logic_vector(3*n_op_2/2-1 downto 0);

	-- A_shifted is a signal that extends A. It is used to prepare in parallel, at the same time, the inputs of all MUXs.
	-- A_shifted is rappresented as follow: the same number of bits of B used to extend the sign of A, the signal A, the same number of bits of B - 1 of zeros. 
	-- Since A is in 2's complement the A msb is used as a selection for a MUX to drive all bits before A msb to the same value.
	-- For exmple if A is 16 bits "1000101111111011" and B is 8 bits: A_shifted
	signal A_shifted: std_logic_vector(n_op_1+(n_op_2-1)*2 downto 0); 
	signal minus_A_shifted: std_logic_vector(n_op_1+(n_op_2-1)*2 downto 0);
	signal A_sign_ext: std_logic;

--Dadda tree signals
	type sums_and_carrys is array(1 to 57) of std_logic;
	type carry_out is array(5 to 32) of std_logic;

	signal S: sums_and_carrys := (others => '0');
	signal C: sums_and_carrys := (others => '0');
	signal Co: carry_out := (others => '0');

	signal flag: std_logic_vector(10 downto 0);
	
	signal final_product1: std_logic_vector(26 downto 0);
	signal final_product2: std_logic_vector(26 downto 0);
--output of the RCA
	signal P_out: std_logic_vector(27 downto 0):= (others => '0');

begin

	A_shifted(n_op_1+(n_op_2-1)*2-n_op_2 downto n_op_2-1) <= A;
	A_shifted(n_op_2-2 downto 0) <= (OTHERS => '0');	

	minus_A: process (A_shifted)
	begin		
		minus_A_shifted <= not(A_shifted);		
	end process;
	
	A_sign_ext <= A(n_op_1-1);
	shift_gen: for i in n_op_1+(n_op_2-1)*2 downto n_op_1+(n_op_2-1)*2-n_op_2+1 generate
	begin
		A_shifted(i) <= A_sign_ext;
	end generate shift_gen;

	conn0: for i in 0 to (n_op_2/2-1) generate
	begin
		mux_control(i) <= encoders_out((i+1)*3-1 downto (i+1)*3-3);
	end generate conn0;	

	Booth_enc: BOOT_ENC
		generic map(n_op_2 => n_op_2)
		port map (B => B ,ENC => encoders_out);

	mux_gen: for i in 0 to (n_op_2/2-1) generate
	begin
		mux: MUX61_generic 
			generic map(n => n_op_1+n_op_2)
			port map (A => (OTHERS => '0'),
				  B => A_shifted(n_op_1+(n_op_2-1)*2-2*i downto n_op_2-1-2*i),
				  C => minus_A_shifted(n_op_1+(n_op_2-1)*2-2*i downto n_op_2-1-2*i),
				  D => A_shifted(n_op_1+(n_op_2-1)*2-2*i-1 downto n_op_2-1-2*i-1),
				  E => minus_A_shifted(n_op_1+(n_op_2-1)*2-2*i-1 downto n_op_2-1-2*i-1),
				  W => (OTHERS => '1'),
				  S => mux_control(i), Y => muxs_out(i));
	end generate mux_gen;

	--Dadda tree adder:
--FOLLOW EXCEL SHEET TO TRACE OUT!!!!
	--a0->14 muxs_out(0)
	--b0->16 muxs_out(1)
	--c0->18 muxs_out(2)
	--d0->20 muxs_out(3)
	--e0->22 muxs_out(4)
	--f0->24 muxs_out(5)
	--g0->26 muxs_out(6)

 

--ALL 5-3 compressors adders
	--STAGE 4 to STAGE{
	comp5_3_1: compressor_5_3 port map(muxs_out(0)(11), muxs_out(1)(11), muxs_out(2)(11), muxs_out(3)(11), C(3), S(5), Co(5), C(5));
	comp5_3_2: compressor_5_3 port map(muxs_out(0)(12), muxs_out(1)(12), muxs_out(2)(12), muxs_out(3)(12), Co(5), S(6), Co(6), C(6));
	comp5_3_3: compressor_5_3 port map(muxs_out(0)(13), muxs_out(1)(13), muxs_out(2)(13), muxs_out(3)(13), Co(6), S(8), Co(8), C(8));
	flag(0) <= not(muxs_out(0)(14));
	comp5_3_4: compressor_5_3 port map(flag(0), muxs_out(1)(14), muxs_out(2)(14), muxs_out(3)(14), Co(8), S(10), Co(10), C(10));
	flag(1) <= not(muxs_out(1)(15));
	comp5_3_5: compressor_5_3 port map(flag(1), muxs_out(2)(15), muxs_out(3)(15), muxs_out(4)(15), Co(10), S(12), Co(12), C(12));
	flag(2) <= not(muxs_out(1)(16));
	comp5_3_6: compressor_5_3 port map(flag(2), muxs_out(2)(16), muxs_out(3)(16), muxs_out(4)(16), Co(12), S(13), Co(13), C(13));	
	--}
	--STAGE 3{
	comp5_3_7: compressor_5_3 port map(muxs_out(0)(6), muxs_out(1)(6), muxs_out(2)(6), muxs_out(3)(6), B(7), S(18), Co(18), C(18));
	comp5_3_8: compressor_5_3 port map(muxs_out(0)(7), muxs_out(1)(7), muxs_out(2)(7), muxs_out(3)(7), Co(18), S(19), Co(19), C(19));
	comp5_3_9: compressor_5_3 port map(S(1), muxs_out(2)(8), muxs_out(3)(8), muxs_out(4)(8), Co(19), S(20), Co(20), C(20));
	comp5_3_10: compressor_5_3 port map(S(2), C(1), muxs_out(2)(9), muxs_out(3)(9), Co(20), S(21), Co(21), C(21));
	comp5_3_11: compressor_5_3 port map(S(3), S(4), C(2), muxs_out(3)(10), Co(21), S(22), Co(22), C(22));
	comp5_3_12: compressor_5_3 port map(S(5), C(4), muxs_out(4)(11), muxs_out(5)(11), Co(22), S(23), Co(23), C(23));
	comp5_3_13: compressor_5_3 port map(S(6), S(7), C(5), muxs_out(6)(12), Co(23), S(24), Co(24), C(24));
	comp5_3_14: compressor_5_3 port map(S(8), S(9), C(6), C(7), Co(24), S(25), Co(25), C(25));
	comp5_3_15: compressor_5_3 port map(S(10), S(11), C(8), C(9), Co(25), S(26), Co(26), C(26));
	comp5_3_16: compressor_5_3 port map(S(12), C(10), C(11), muxs_out(5)(15), Co(26), S(27), Co(27), C(27));
	comp5_3_17: compressor_5_3 port map(S(13), C(12), muxs_out(5)(16), muxs_out(6)(16), Co(27), S(28), Co(28), C(28));
	comp5_3_18: compressor_5_3 port map(S(14), C(10), Co(10), muxs_out(5)(17), Co(28), S(29), Co(29), C(29));
	comp5_3_19: compressor_5_3 port map(S(15), C(14), muxs_out(5)(18), muxs_out(6)(18), Co(29), S(30), Co(30), C(30));
	flag(3) <= not(muxs_out(3)(19));
	comp5_3_20: compressor_5_3 port map(C(15), flag(3), muxs_out(4)(19), muxs_out(5)(19), Co(30), S(31), Co(31), C(31));
	flag(4) <= not(muxs_out(3)(20));
	comp5_3_21: compressor_5_3 port map(flag(4), muxs_out(4)(2), muxs_out(5)(20), muxs_out(6)(20), Co(31), S(32), Co(32), C(32));
	--}
	--STAGE 2{
	--}

--ALL 4-2 compressors
	--STAGE 4 to STAGE{
	--}

	--STAGE 3{
	comp4_2_1: compressor_4_2 port map( muxs_out(0)(4), muxs_out(1)(4), muxs_out(2)(4), B(5), S(16), C(16));
	--}

	--STAGE 2{
	--}


--ALL Full adders
	--STAGE 4 to STAGE{
	FA_1: FA port map( A=>muxs_out(0)(10), B=>muxs_out(1)(10), Ci=>muxs_out(2)(10), S=>S(3), Co=>C(3));
	FA_2: FA port map( A=>muxs_out(4)(14), B=>muxs_out(5)(14), Ci=>muxs_out(6)(14), S=>S(11), Co=>C(11));
	flag(5) <= not(muxs_out(2)(17));
	FA_3: FA port map( A=>flag(5), B=>muxs_out(3)(17), Ci=>muxs_out(4)(17), S=>S(14), Co=>C(14));
	flag(6) <= not(muxs_out(2)(18));
	FA_4: FA port map( A=>flag(6), B=>muxs_out(3)(18), Ci=>muxs_out(4)(18), S=>S(15), Co=>C(15));
	--}

	--STAGE 3{
	flag(7) <= not(muxs_out(4)(21));
	FA_5: FA port map( A=>flag(7), B=>muxs_out(5)(21), Ci=>muxs_out(6)(21), S=>S(33), Co=>C(33));
	flag(8) <= not(muxs_out(4)(22));
	FA_6: FA port map( A=>flag(8), B=>muxs_out(5)(22), Ci=>muxs_out(6)(22), S=>S(34), Co=>C(34));
	--}

	--STAGE 2{
	FA_7: FA port map( A=>S(16), B=>muxs_out(2)(4), Ci=>B(5), S=>S(37), Co=>C(37));
	--FA_8: FA port map( A=>S(17), B=>C(16), Ci=>muxs_out(2)(5), S=>S(38), Co=>C(38));
	FA_9: FA port map( A=>S(20), B=>C(19), Ci=>B(9), S=>S(41), Co=>C(41));
	FA_10: FA port map( A=>S(21), B=>C(20), Ci=>muxs_out(4)(9), S=>S(42), Co=>C(42));
	FA_11: FA port map( A=>S(22), B=>C(21), Ci=>B(11), S=>S(43), Co=>C(43));
	FA_12: FA port map( A=>S(24), B=>C(23), Ci=>B(13), S=>S(45), Co=>C(45));
	FA_13: FA port map( A=>S(25), B=>C(24), Ci=>muxs_out(6)(13), S=>S(46), Co=>C(46));
	FA_14: FA port map( A=>S(26), B=>C(25), Ci=>'1', S=>S(47), Co=>C(47));
	FA_15: FA port map( A=>S(27), B=>C(26), Ci=>muxs_out(6)(15), S=>S(48), Co=>C(48));
	FA_16: FA port map( A=>S(28), B=>C(27), Ci=>muxs_out(1)(15), S=>S(49), Co=>C(49));
	FA_17: FA port map( A=>S(29), B=>C(28), Ci=>muxs_out(6)(17), S=>S(50), Co=>C(50));
	FA_18: FA port map( A=>S(30), B=>C(29), Ci=>muxs_out(2)(17), S=>S(51), Co=>C(51));
	FA_19: FA port map( A=>S(31), B=>C(30), Ci=>muxs_out(6)(19), S=>S(52), Co=>C(52));
	FA_20: FA port map( A=>S(32), B=>C(31), Ci=>muxs_out(3)(19), S=>S(53), Co=>C(53));
	FA_21: FA port map( A=>S(33), B=>C(32), Ci=>Co(32), S=>S(54), Co=>C(54));
	FA_22: FA port map( A=>S(34), B=>C(33), Ci=>muxs_out(4)(21), S=>S(55), Co=>C(55));
	flag(9) <= not(muxs_out(5)(23));
	FA_23: FA port map( A=>C(34), B=>flag(9), Ci=>muxs_out(6)(23), S=>S(56), Co=>C(56));
	flag(10) <= not(muxs_out(5)(24));
	FA_24: FA port map( A=>flag(10), B=>muxs_out(6)(24), Ci=>muxs_out(5)(23), S=>S(57), Co=>C(57));
	--}

--ALL Half adders
	--STAGE 4 to STAGE{
	HA_1: HA port map( A=>muxs_out(0)(8), B=>muxs_out(1)(8), S=>S(1), Co=>C(1));
	HA_2: HA port map( A=>muxs_out(0)(9), B=>muxs_out(1)(9), S=>S(2), Co=>C(2));
	HA_3: HA port map( A=>muxs_out(3)(10), B=>muxs_out(4)(10), S=>S(4), Co=>C(4));
	HA_4: HA port map( A=>muxs_out(4)(12), B=>muxs_out(5)(12), S=>S(7), Co=>C(7));
	HA_5: HA port map( A=>muxs_out(4)(13), B=>muxs_out(5)(13), S=>S(9), Co=>C(9));
	--}

	--STAGE 3{
	--HA_6: HA port map( A=>muxs_out(0)(4), B=>muxs_out(1)(4), S=>S(16), Co=>C(16));
	HA_7: HA port map( A=>muxs_out(0)(5), B=>muxs_out(1)(5), S=>S(17), Co=>C(17));
	--}

	--STAGE 2{
	HA_8: HA port map( A=>muxs_out(0)(2), B=>muxs_out(1)(2), S=>S(35), Co=>C(35));
	HA_9: HA port map( A=>muxs_out(0)(3), B=>muxs_out(1)(3), S=>S(36), Co=>C(36));
	HA_10: HA port map( A=>S(18), B=>C(17), S=>S(39), Co=>C(39));
	HA_11: HA port map( A=>S(19), B=>C(18), S=>S(40), Co=>C(40));
	HA_12: HA port map( A=>S(23), B=>C(22), S=>S(44), Co=>C(44));
	HA_6: HA port map( A=>S(17), B=>C(16), S=>S(38), Co=>C(38));
	--}


	--STAGE 1 --LAST STAGE which is using a fast adder
	final_product1(0) <= muxs_out(0)(0);
	final_product1(1) <= muxs_out(0)(1);
	final_product1(2) <= S(35);
	final_product1(3) <= S(36);
	final_product1(4) <= S(37);
	final_product1(5) <= S(38);
	final_product1(6) <= S(39); 
	final_product1(7) <= S(40); 
	final_product1(8) <= S(41); 
	final_product1(9) <= S(42); 
	final_product1(10) <= S(43);
	final_product1(11) <= S(44);
	final_product1(12) <= S(45);
	final_product1(13) <= S(46);
	final_product1(14) <= S(47);
	final_product1(15) <= S(48);
	final_product1(16) <= S(49);
	final_product1(17) <= S(50);
	final_product1(18) <= S(51);
	final_product1(19) <= S(52);
	final_product1(20) <= S(53);
	final_product1(21) <= S(54);
	final_product1(22) <= S(55);
	final_product1(23) <= S(56);
	final_product1(24) <= S(57);
	final_product1(25) <= C(57);
	final_product1(26) <= not(muxs_out(6)(26)); --g26'
	
	final_product2(0) <= B(1);
	final_product2(1) <= '0';
	final_product2(2) <= B(3);
	final_product2(3) <= C(35);
	final_product2(4) <= C(36);
	final_product2(5) <= muxs_out(2)(5);
	final_product2(6) <= C(38); 
	final_product2(7) <= C(39);
	final_product2(8) <= C(40);
	final_product2(9) <= C(41); 
	final_product2(10) <= C(42); 
	final_product2(11) <= C(43); 
	final_product2(12) <= C(44); 
	final_product2(13) <= C(45); 
	final_product2(14) <= C(46); 
	final_product2(15) <= C(47); 
	final_product2(16) <= C(48); 
	final_product2(17) <= C(49); 
	final_product2(18) <= C(50); 
	final_product2(19) <= C(51); 
	final_product2(20) <= C(52); 
	final_product2(21) <= C(53); 
	final_product2(22) <= C(54); 
	final_product2(23) <= C(55); 
	final_product2(24) <= C(56); 
	final_product2(25) <= not(muxs_out(6)(25)); -- g25'
	final_product2(26) <= muxs_out(6)(25); -- g25

	--Calculating the final products using FAST ADDER
	Partial_products_sum: sumx port map(final_product1, final_product2, P_out(26 downto 0));

	HA_final:HA port map( A=> muxs_out(6)(26) ,B=>muxs_out(6)(25) ,Co=>P_out(27));
	--Truncate the final value 
	P <= P_out(26 downto 13);


end architecture mixed;
