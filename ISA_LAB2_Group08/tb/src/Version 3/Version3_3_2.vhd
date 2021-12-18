library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_signed.all;

entity BOOTHMUL is 
	Generic (n_op_1: integer:= 14; 
		n_op_2: integer:= 14);
	Port (	A:	in std_logic_vector(n_op_1-1 downto 0);
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
	type sums_and_carrys is array(1 to 78) of std_logic;
	--type carry_out is array(3 to 29) of std_logic;

	signal S: sums_and_carrys;
	signal C: sums_and_carrys;
	--signal Co: carry_out 

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
	--}
	--STAGE 3{
	--}
	--STAGE 2{
	--}

--ALL 4-2 compressors
	--STAGE 5 to STAGE{
	-- NONE
	--}
	--STAGE 4{
	comp4_4_1: compressor_4_2 port map(muxs_out(0)(4), muxs_out(1)(4), muxs_out(2)(4), B(5), S(38), C(38));
	--}
	--STAGE 3{
	comp4_4_2: compressor_4_2 port map(muxs_out(0)(5), muxs_out(1)(5), muxs_out(2)(5), C(38), S(39), C(39));
	comp4_4_3: compressor_4_2 port map(S(12), muxs_out(2)(6),muxs_out(3)(6),B(7), S(40), C(40));
	comp4_4_4: compressor_4_2 port map(S(13), C(12),muxs_out(2)(7), muxs_out(3)(7), S(41), C(41));
	comp4_4_5: compressor_4_2 port map(S(14), S(15), C(13), B(9), S(42), C(42));
	comp4_4_6: compressor_4_2 port map(S(16), S(17), C(14), C(15), S(43), C(43));
	comp4_4_7: compressor_4_2 port map(S(18), S(19), C(16), C(17), S(44), C(44));
		
	--}
	--STAGE 2{
	--NONE
	--}
	
	
--ALL Full adders
	--STAGE 5 to STAGE{
	FA_1: FA port map( A=>muxs_out(2)(12), B=>muxs_out(3)(12), Ci=>muxs_out(4)(12), S=>S(4), Co=>C(4));
	FA_2: FA port map( A=>muxs_out(2)(13), B=>muxs_out(3)(13), Ci=>muxs_out(4)(13), S=>S(6), Co=>C(6));
	flag(0) <= not (muxs_out(0)(14));
	FA_3: FA port map( A=>flag(0), B=>muxs_out(1)(14), Ci=>'1', S=>S(7), Co=>C(7));
	FA_4: FA port map( A=>muxs_out(2)(14), B=>muxs_out(3)(14), Ci=>muxs_out(4)(14), S=>S(8), Co=>C(8));
	flag(1) <= not (muxs_out(1)(15));
	FA_5: FA port map( A=>flag(1), B=>muxs_out(2)(15), Ci=>muxs_out(3)(15), S=>S(9), Co=>C(9));
	flag(2) <= not (muxs_out(1)(16));
	FA_6: FA port map( A=>flag(2), B=>muxs_out(2)(16), Ci=>muxs_out(3)(16), S=>S(10), Co=>C(10));
	--}

	--STAGE 4{
	FA_7: FA port map( A=>muxs_out(0)(8), B=>muxs_out(1)(8), Ci=>muxs_out(2)(8), S=>S(14), Co=>C(14));
	FA_8: FA port map( A=>muxs_out(0)(9), B=>muxs_out(1)(9), Ci=>muxs_out(2)(9), S=>S(16), Co=>C(16));
	FA_9: FA port map( A=>S(1), B=>muxs_out(2)(10), Ci=>muxs_out(3)(10), S=>S(18), Co=>C(18));
	FA_10: FA port map( A=>muxs_out(4)(10), B=>muxs_out(5)(10), Ci=>B(11), S=>S(19), Co=>C(19));
	FA_11: FA port map( A=>S(2), B=>C(1), Ci=>muxs_out(2)(11), S=>S(20), Co=>C(20));
	FA_12: FA port map( A=>muxs_out(3)(11), B=>muxs_out(4)(11), Ci=>muxs_out(5)(11), S=>S(21), Co=>C(21));
	FA_13: FA port map( A=>S(3), B=>S(4), Ci=>C(2), S=>S(22), Co=>C(22));
	FA_14: FA port map( A=>muxs_out(5)(12), B=>muxs_out(6)(12), Ci=>B(13), S=>S(23), Co=>C(23));
	FA_15: FA port map( A=>S(5), B=>S(6), Ci=>C(3), S=>S(24), Co=>C(24));
	FA_16: FA port map( A=>C(4), B=>muxs_out(5)(13), Ci=>muxs_out(6)(13), S=>S(25), Co=>C(25));
	FA_17: FA port map( A=>S(7), B=>S(8), Ci=>C(5), S=>S(26), Co=>C(26));
	FA_18: FA port map( A=>C(6), B=>muxs_out(5)(14), Ci=>muxs_out(6)(14), S=>S(27), Co=>C(27));
	FA_19: FA port map( A=>S(9), B=>C(7), Ci=>C(8), S=>S(28), Co=>C(28));
	FA_20: FA port map( A=>muxs_out(4)(15), B=>muxs_out(5)(15), Ci=>muxs_out(6)(15), S=>S(29), Co=>C(29));
	FA_21: FA port map( A=>S(10), B=>C(9), Ci=>muxs_out(4)(16), S=>S(30), Co=>C(30));
	FA_22: FA port map( A=>muxs_out(5)(16), B=>muxs_out(6)(16), Ci=>muxs_out(1)(15), S=>S(31), Co=>C(31));
	flag(3) <= not (muxs_out(2)(17));
	FA_23: FA port map( A=>C(10), B=>flag(3), Ci=>muxs_out(3)(17), S=>S(32), Co=>C(32));
	FA_24: FA port map( A=>muxs_out(4)(17), B=>muxs_out(5)(17), Ci=>muxs_out(6)(17), S=>S(33), Co=>C(33));
	flag(4) <= not (muxs_out(2)(18));
	FA_25: FA port map( A=>flag(4), B=>muxs_out(3)(18), Ci=>muxs_out(4)(18), S=>S(34), Co=>C(34));
	FA_26: FA port map( A=>muxs_out(5)(18), B=>muxs_out(6)(18), Ci=>muxs_out(2)(17), S=>S(35), Co=>C(35));	
	flag(5) <= not (muxs_out(3)(19));
	FA_27: FA port map( A=>flag(5), B=>muxs_out(4)(19), Ci=>muxs_out(5)(19), S=>S(36), Co=>C(36));	
	flag(6) <= not (muxs_out(3)(20));
	FA_28: FA port map( A=>flag(6), B=>muxs_out(4)(20), Ci=>muxs_out(5)(20), S=>S(37), Co=>C(37));	
	--}

	--STAGE 3{
	FA_33: FA port map( A=>S(20), B=>S(21), Ci=>C(18), S=>S(45), Co=>C(45));		
	FA_34: FA port map( A=>S(22), B=>S(23), Ci=>C(20), S=>S(46), Co=>C(46));	
	FA_35: FA port map( A=>S(24), B=>S(25), Ci=>C(22), S=>S(47), Co=>C(47));
	FA_36: FA port map( A=>S(26), B=>S(27), Ci=>C(24), S=>S(48), Co=>C(48));
	FA_37: FA port map( A=>S(28), B=>S(29), Ci=>C(26), S=>S(49), Co=>C(49));
	FA_38: FA port map( A=>S(30), B=>S(31), Ci=>C(28), S=>S(50), Co=>C(50));
	FA_39: FA port map( A=>S(32), B=>S(33), Ci=>C(30), S=>S(51), Co=>C(51));
	FA_40: FA port map( A=>S(34), B=>S(35), Ci=>C(32), S=>S(52), Co=>C(52));
	FA_41: FA port map( A=>S(36), B=>C(34), Ci=>C(35), S=>S(53), Co=>C(53));		
	FA_42: FA port map( A=>S(37), B=>C(36), Ci=>muxs_out(6)(20), S=>S(54), Co=>C(54));		
	flag(7) <= not( muxs_out(4)(21));
	FA_43: FA port map( A=>C(37), B=>flag(7), Ci=>muxs_out(5)(21), S=>S(55), Co=>C(55));	
	flag(8) <= not( muxs_out(4)(22));	
	FA_44: FA port map( A=>flag(8), B=>muxs_out(5)(22), Ci=>muxs_out(6)(22), S=>S(56), Co=>C(56));			
	--}


	--STAGE 2{		
	FA_50: FA port map( A=>S(46), B=>C(45), Ci=>C(21), S=>S(65), Co=>C(65));
	FA_51: FA port map( A=>S(47), B=>C(46), Ci=>C(23), S=>S(66), Co=>C(66));
	FA_52: FA port map( A=>S(48), B=>C(47), Ci=>C(25), S=>S(67), Co=>C(67));
	FA_53: FA port map( A=>S(49), B=>C(48), Ci=>C(27), S=>S(68), Co=>C(68));	
	FA_54: FA port map( A=>S(50), B=>C(49), Ci=>C(29), S=>S(69), Co=>C(69));	
	FA_55: FA port map( A=>S(51), B=>C(50), Ci=>C(31), S=>S(70), Co=>C(70));	
	FA_56: FA port map( A=>S(52), B=>C(51), Ci=>C(33), S=>S(71), Co=>C(71));
	FA_57: FA port map( A=>S(53), B=>C(52), Ci=>muxs_out(6)(19), S=>S(72), Co=>C(72));
	FA_58: FA port map( A=>S(54), B=>C(53), Ci=>muxs_out(3)(19), S=>S(73), Co=>C(73));
	FA_59: FA port map( A=>S(55), B=>C(54), Ci=>muxs_out(6)(21), S=>S(74), Co=>C(74));
	FA_60: FA port map( A=>S(56), B=>C(55), Ci=>muxs_out(4)(21), S=>S(75), Co=>C(75));
	flag(9) <= not (muxs_out(5)(23));
	FA_61: FA port map( A=>C(56), B=>flag(9), Ci=>muxs_out(6)(23), S=>S(76), Co=>C(76));
	flag(10) <= not(muxs_out(5)(24));
	FA_62: FA port map( A=>flag(10), B=>muxs_out(6)(24), Ci=>muxs_out(5)(23), S=>S(77), Co=>C(77));
	--}

--ALL Half adders
	--STAGE 5 to STAGE{
	HA_1: HA port map( A=>muxs_out(0)(10), B=>muxs_out(1)(10), S=>S(1), Co=>C(1));
	HA_2: HA port map( A=>muxs_out(0)(11), B=>muxs_out(1)(11), S=>S(2), Co=>C(2));
	HA_3: HA port map( A=>muxs_out(0)(12), B=>muxs_out(1)(12), S=>S(3), Co=>C(3));
	HA_4: HA port map( A=>muxs_out(0)(13), B=>muxs_out(1)(13), S=>S(5), Co=>C(5));
	--}

	--STAGE 4{
	HA_5: HA port map( A=>muxs_out(0)(6), B=>muxs_out(1)(6), S=>S(12), Co=>C(12));
	HA_6: HA port map( A=>muxs_out(0)(7), B=>muxs_out(1)(7), S=>S(13), Co=>C(13));
	HA_7: HA port map( A=>muxs_out(3)(8), B=>muxs_out(4)(8), S=>S(15), Co=>C(15));
	HA_8: HA port map( A=>muxs_out(3)(9), B=>muxs_out(4)(9), S=>S(17), Co=>C(17));
	--}

	--STAGE 3{
	--- NONE
	--}

	--STAGE 2{
	HA_9: HA port map( A=>muxs_out(0)(2), B=>muxs_out(1)(2), S=>S(57), Co=>C(57));
	HA_10: HA port map( A=>muxs_out(0)(3), B=>muxs_out(0)(3), S=>S(58), Co=>C(58));
	HA_11: HA port map(A=>S(45), B=>C(44), S=>S(64), Co=>C(64));
	--}
	
	
	
	
--- STAGE 1 - LAST STAGE which uses the fast adder
	final_product1(0) <= muxs_out(0)(0); --a0
	final_product1(1) <= muxs_out(0)(1); --a1
	final_product1(2) <= S(57);
	final_product1(3) <= S(58);
	final_product1(4) <= S(38);
	final_product1(5) <= S(39);
	final_product1(6) <= S(40); 
	final_product1(7) <= S(41); 
	final_product1(8) <= S(42); 
	final_product1(9) <= S(43); 
	final_product1(10) <= S(44);
	final_product1(11) <= S(64);
	final_product1(12) <= S(65);
	final_product1(13) <= S(66);
	final_product1(14) <= S(67);
	final_product1(15) <= S(68);
	final_product1(16) <= S(69);
	final_product1(17) <= S(70);
	final_product1(18) <= S(71);
	final_product1(19) <= S(72);
	final_product1(20) <= S(73);
	final_product1(21) <= S(74);
	final_product1(22) <= S(75);
	final_product1(23) <= S(76);
	final_product1(24) <= S(77);
	final_product1(25) <= C(77);
	final_product1(26) <= not(muxs_out(6)(26)); --g26'
	
	final_product2(0) <= B(1); --x1
	final_product2(1) <= '0';
	final_product2(2) <= B(3); --x3
	final_product2(3) <= C(57);
	final_product2(4) <= C(58);
	final_product2(5) <= '0';
	final_product2(6) <= C(39); 
	final_product2(7) <= C(40);
	final_product2(8) <= C(41);
	final_product2(9) <= C(42); 
	final_product2(10) <= C(43); 
	final_product2(11) <= C(19); 
	final_product2(12) <= C(64); 
	final_product2(13) <= C(65); 
	final_product2(14) <= C(66); 
	final_product2(15) <= C(67); 
	final_product2(16) <= C(68); 
	final_product2(17) <= C(69); 
	final_product2(18) <= C(70); 
	final_product2(19) <= C(71); 
	final_product2(20) <= C(72); 
	final_product2(21) <= C(73); 
	final_product2(22) <= C(74); 
	final_product2(23) <= C(75); 
	final_product2(24) <= C(76); 
	final_product2(25) <= not(muxs_out(6)(25)); -- g25'
	final_product2(26) <= muxs_out(6)(25); -- g25

	--Calculating the final products using FAST ADDER
	Partial_products_sum: sumx port map(final_product1, final_product2, P_out(26 downto 0));

	HA_final:HA port map( A=> muxs_out(6)(26) ,B=>muxs_out(6)(25) ,Co=>P_out(27));
	--Truncate the final value 
	P <= P_out(26 downto 13);

end architecture mixed;
