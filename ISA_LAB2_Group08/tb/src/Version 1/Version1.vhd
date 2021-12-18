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
	
	component sumx is 
	generic (n1: integer:= 27;
		 n2: integer:= 27);
	port (
	    add1 : in std_logic_vector (n1-1 downto 0);
	    add2 : in std_logic_vector (n2-1 downto 0);
	    sum1: out std_logic_vector (n1-1 downto 0));
	end component;
	
	component MUX61_generic is 
	generic (n: integer:= 28);
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
	type starter is array(0 to 6) of std_logic;
	
	signal X: starter;
		
	signal S: sums_and_carrys;
	signal C: sums_and_carrys;

	signal flag: std_logic_vector(11 downto 0);
	
	signal final_product1: std_logic_vector(26 downto 0);
	signal final_product2: std_logic_vector(26 downto 0);
--output of the RCA
	signal P_out: std_logic_vector(27 downto 0):= (others => '0');

begin

	A_shifted(n_op_1+(n_op_2-1)*2-n_op_2 downto n_op_2-1) <= A;
	A_shifted(n_op_2-2 downto 0) <= (OTHERS => '0');	

	complement_1s: process (A_shifted)
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
			port map (A => (OTHERS => '0'),							--multiply by 0	 --000
				  B => A_shifted(n_op_1+(n_op_2-1)*2-2*i downto n_op_2-1-2*i),		--multiply by 1	 --001
				  C => minus_A_shifted(n_op_1+(n_op_2-1)*2-2*i downto n_op_2-1-2*i),	--multiply by -1 --010
				  D => A_shifted(n_op_1+(n_op_2-1)*2-2*i-1 downto n_op_2-1-2*i-1),	--multiply by 2	--011
				  E => minus_A_shifted(n_op_1+(n_op_2-1)*2-2*i-1 downto n_op_2-1-2*i-1),--multiply by -2 --100
				  W => (OTHERS => '1'),							--multiply by -0 --101
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

 

--ALL Full adders
	--STAGE 5 to STAGE{
	FA_1: FA port map( A=>muxs_out(2)(12), B=>muxs_out(3)(12), Ci=>muxs_out(4)(12), S=>S(4), Co=>C(4));
	FA_2: FA port map( A=>muxs_out(2)(13), B=>muxs_out(3)(13), Ci=>muxs_out(4)(13), S=>S(6), Co=>C(6));
	flag(0) <= not( muxs_out(0)(14));
	FA_3: FA port map( A=>flag(0), B=>muxs_out(1)(14), Ci=>'1', S=>S(7), Co=>C(7));
	FA_4: FA port map( A=> muxs_out(2)(14), B=>muxs_out(3)(14), Ci=>muxs_out(4)(14), S=>S(8), Co=>C(8));
	flag(1) <= not( muxs_out(1)(15));
	FA_5: FA port map( A=> flag(1), B=>muxs_out(2)(15), Ci=>muxs_out(3)(15), S=>S(9), Co=>C(9));
	flag(2) <= not( muxs_out(1)(16));
	FA_6: FA port map( A=> flag(2), B=>muxs_out(2)(16), Ci=>muxs_out(3)(16), S=>S(10), Co=>C(10));
	--}
	--STAGE 4{
	FA_7: FA port map( A=>muxs_out(0)(8), B=>muxs_out(1)(8), Ci=>muxs_out(2)(8), S=>S(13), Co=>C(13));
	FA_8: FA port map( A=> muxs_out(0)(9), B=>muxs_out(1)(9), Ci=>muxs_out(2)(9), S=>S(15), Co=>C(15));
	FA_9: FA port map( A=> S(1), B=> muxs_out(2)(10), Ci=>muxs_out(3)(10), S=>S(17), Co=>C(17));
	X(5) <= B(11);
	FA_10: FA port map( A=> muxs_out(4)(10), B=>muxs_out(5)(10), Ci=>X(5), S=>S(18), Co=>C(18));
	FA_11: FA port map( A=> S(2),B=> C(1), Ci=>muxs_out(2)(11), S=>S(19), Co=>C(19));
	FA_12: FA port map( A=> muxs_out(3)(11), B=>muxs_out(4)(11), Ci=>muxs_out(5)(11), S=>S(20), Co=>C(20));
	FA_13: FA port map( A=> S(3), B=>S(4), Ci=>C(2), S=>S(21), Co=>C(21));
	X(6) <= B(13);
	FA_14: FA port map( A=> muxs_out(5)(12), B=>muxs_out(6)(12), Ci=>X(6), S=>S(22), Co=>C(22));
	FA_15: FA port map( A=> S(5), B=>S(6), Ci=>C(3), S=>S(23), Co=>C(23));
	FA_16: FA port map( A=> C(4), B=>muxs_out(5)(13), Ci=>muxs_out(6)(13), S=>S(24), Co=>C(24));
	FA_17: FA port map( A=> S(7), B=>S(8), Ci=>C(5), S=>S(25), Co=>C(25));
	FA_18: FA port map( A=> C(6), B=>muxs_out(5)(14), Ci=>muxs_out(6)(14), S=>S(26), Co=>C(26));
	FA_19: FA port map( A=> S(9), B=>C(7), Ci=>C(8), S=>S(27), Co=>C(27));
	FA_20: FA port map( A=> muxs_out(4)(15), B=>muxs_out(5)(15), Ci=>muxs_out(6)(15), S=>S(28), Co=>C(28));
	FA_21: FA port map( A=> S(10), B=>C(9), Ci=>muxs_out(4)(16), S=>S(29), Co=>C(29));
	FA_22: FA port map( A=> muxs_out(5)(16), B=>muxs_out(6)(16), Ci=>muxs_out(1)(15), S=>S(30), Co=>C(30));
	flag(3) <= not (muxs_out(2)(17));
	FA_23: FA port map( A=> C(10), B=>flag(3), Ci=>muxs_out(3)(17), S=>S(31), Co=>C(31));
	FA_24: FA port map( A=> muxs_out(4)(17), B=>muxs_out(5)(17), Ci=>muxs_out(6)(17), S=>S(32), Co=>C(32));
	flag(4) <= not(muxs_out(2)(18));
	FA_25: FA port map( A=> flag(4), B=>muxs_out(3)(18), Ci=>muxs_out(4)(18), S=>S(33), Co=>C(33));
	FA_26: FA port map( A=> muxs_out(5)(18), B=>muxs_out(6)(18), Ci=>muxs_out(2)(17), S=>S(34), Co=>C(34));
	flag(5) <= not(muxs_out(3)(19));
	FA_27: FA port map( A=> flag(5), B=>muxs_out(4)(19), Ci=>muxs_out(5)(19), S=>S(35), Co=>C(35));
	flag(6) <= not(muxs_out(3)(20));
	FA_28: FA port map( A=> flag(6), B=>muxs_out(4)(20), Ci=>muxs_out(5)(20), S=>S(36), Co=>C(36));
	--}
	--STAGE 3{
	FA_30: FA port map( A=> S(11), B=>muxs_out(2)(6), Ci=>muxs_out(3)(6), S=>S(39), Co=>C(39));
	FA_31: FA port map( A=> S(12), B=>C(11), Ci=>muxs_out(2)(7), S=>S(40), Co=>C(40));
	FA_32: FA port map( A=> S(13), B=>S(14), Ci=>C(12), S=>S(41), Co=>C(41));
	FA_33: FA port map( A=> S(15), B=>S(16), Ci=>C(13), S=>S(42), Co=>C(42));
	FA_34: FA port map( A=> S(17), B=>S(18), Ci=>C(15), S=>S(43), Co=>C(43));
	FA_35: FA port map( A=> S(19), B=>S(20), Ci=>C(17), S=>S(44), Co=>C(44));
	FA_36: FA port map( A=> S(21), B=>S(22), Ci=>C(19), S=>S(45), Co=>C(45));
	FA_37: FA port map( A=> S(23), B=>S(24), Ci=>C(21), S=>S(46), Co=>C(46));
	FA_38: FA port map( A=> S(25), B=>S(26), Ci=>C(23), S=>S(47), Co=>C(47));
	FA_39: FA port map( A=> S(27), B=>S(28), Ci=>C(25), S=>S(48), Co=>C(48));
	FA_40: FA port map( A=> S(29), B=>S(30), Ci=>C(27), S=>S(49), Co=>C(49));
	FA_41: FA port map( A=> S(31), B=>S(32), Ci=>C(29), S=>S(50), Co=>C(50));
	FA_42: FA port map( A=> S(33), B=>S(34), Ci=>C(31), S=>S(51), Co=>C(51));
	FA_43: FA port map( A=> S(35), B=>C(33), Ci=>C(34), S=>S(52), Co=>C(52));
	FA_44: FA port map( A=> S(36), B=>C(35), Ci=>muxs_out(6)(20), S=>S(53), Co=>C(53));
	flag(7) <= not(muxs_out(4)(21));
	FA_45: FA port map( A=> C(36), B=>flag(7), Ci=>muxs_out(5)(21), S=>S(54), Co=>C(54));
	flag(8) <= not(muxs_out(4)(22));
	FA_46: FA port map( A=> flag(8), B=>muxs_out(5)(22), Ci=>muxs_out(6)(22), S=>S(55), Co=>C(55));
	--}
	--STAGE 2{
	X(2) <= B(5);
	FA_48: FA port map( A=> S(37), B=>muxs_out(2)(4), Ci=>X(2), S=>S(58), Co=>C(58));
	FA_49: FA port map( A=> S(38), B=>C(37), Ci=>muxs_out(2)(5), S=>S(59), Co=>C(59));
	X(3) <= B(7);
	FA_50: FA port map( A=> S(39), B=>C(38), Ci=>X(3), S=>S(60), Co=>C(60));
	FA_51: FA port map( A=> S(40), B=>C(39), Ci=>muxs_out(3)(7), S=>S(61), Co=>C(61));
	X(4) <= B(9);
	FA_52: FA port map( A=> S(41), B=>C(40), Ci=>X(4), S=>S(62), Co=>C(62));
	FA_53: FA port map( A=> S(42), B=>C(41), Ci=>C(14), S=>S(63), Co=>C(63));
	FA_54: FA port map( A=> S(43), B=>C(42), Ci=>C(16), S=>S(64), Co=>C(64));
	FA_55: FA port map( A=> S(44), B=>C(43), Ci=>C(18), S=>S(65), Co=>C(65));
	FA_56: FA port map( A=> S(45), B=>C(44), Ci=>C(20), S=>S(66), Co=>C(66));
	FA_57: FA port map( A=> S(46), B=>C(45), Ci=>C(22), S=>S(67), Co=>C(67));
	FA_58: FA port map( A=> S(47), B=>C(46), Ci=>C(24), S=>S(68), Co=>C(68));
	FA_59: FA port map( A=> S(48), B=>C(47), Ci=>C(26), S=>S(69), Co=>C(69));
	FA_60: FA port map( A=> S(49), B=>C(48), Ci=>C(28), S=>S(70), Co=>C(70));
	FA_61: FA port map( A=> S(50), B=>C(49), Ci=>C(30), S=>S(71), Co=>C(71));
	FA_62: FA port map( A=> S(51), B=>C(50), Ci=>C(32), S=>S(72), Co=>C(72));
	FA_63: FA port map( A=> S(52), B=>C(51), Ci=>muxs_out(6)(19), S=>S(73), Co=>C(73));
	FA_64: FA port map( A=> S(53), B=>C(52), Ci=>muxs_out(3)(19), S=>S(74), Co=>C(74));
	FA_65: FA port map( A=> S(54), B=>C(53), Ci=>muxs_out(6)(21), S=>S(75), Co=>C(75));
	FA_66: FA port map( A=> S(55), B=>C(54), Ci=>muxs_out(4)(21), S=>S(76), Co=>C(76));
	flag(9) <= not(muxs_out(5)(23));
	FA_67: FA port map( A=> C(55), B=>flag(9), Ci=>muxs_out(6)(23), S=>S(77), Co=>C(77));
	flag(10) <= not(muxs_out(5)(24));
	FA_68: FA port map( A=> flag(9), B=>muxs_out(6)(24), Ci=>muxs_out(5)(23), S=>S(78), Co=>C(78));
	--}

--ALL Half adders
	--STAGE 5{
	HA_1: HA port map( A=> muxs_out(0)(10),B=>muxs_out(1)(10) ,S=>S(1) ,Co=>C(1) );
	HA_2: HA port map( A=> muxs_out(0)(11),B=>muxs_out(1)(11) ,S=>S(2) ,Co=>C(2) );
	HA_3: HA port map( A=> muxs_out(0)(12),B=>muxs_out(1)(12) ,S=>S(3) ,Co=>C(3) );
	HA_11: HA port map( A=> muxs_out(0)(13),B=>muxs_out(1)(13) ,S=>S(5) ,Co=>C(5) );
	--}	
	--STAGE 4{
	HA_4:HA port map( A=> muxs_out(0)(6),B=>muxs_out(1)(6) ,S=>S(11) ,Co=>C(11) );
	HA_5:HA port map( A=> muxs_out(0)(7),B=>muxs_out(1)(7) ,S=>S(12) ,Co=>C(12));
	HA_6:HA port map( A=> muxs_out(3)(8), B=> muxs_out(4)(8), S=>S(14) ,Co=>C(14));
	HA_12:HA port map( A=> muxs_out(3)(9), B=> muxs_out(4)(9), S=>S(16) ,Co=>C(16));
	--}
	--STAGE 3{
	HA_7:HA port map( A=> muxs_out(0)(4), B=>muxs_out(1)(4), S=>S(37), Co=>C(37));
	HA_8:HA port map( A=> muxs_out(0)(5), B=>muxs_out(1)(5), S=>S(38), Co=>C(38));
	--}
	--STAGE 2{
	HA_9:HA port map( A=> muxs_out(0)(2),B=>muxs_out(1)(2) ,S=>S(56) ,Co=>C(56));
	HA_10:HA port map( A=> muxs_out(0)(3) ,B=>muxs_out(1)(3) ,S=>S(57) ,Co=>C(57));
	--}

	--STAGE 1 --LAST STAGE which is using a fast adder
	final_product1(0) <= muxs_out(0)(0); --a0
	final_product1(1) <= muxs_out(0)(1); --a1
	final_product1(2) <= S(56); 
	final_product1(3) <= S(57); 
	final_product1(4) <= S(58); 
	final_product1(5) <= S(59); 
	final_product1(6) <= S(60); 
	final_product1(7) <= S(61); 
	final_product1(8) <= S(62); 
	final_product1(9) <= S(63); 
	final_product1(10) <= S(64);
	final_product1(11) <= S(65);
	final_product1(12) <= S(66);
	final_product1(13) <= S(67);
	final_product1(14) <= S(68);
	final_product1(15) <= S(69);
	final_product1(16) <= S(70);
	final_product1(17) <= S(71);
	final_product1(18) <= S(72);
	final_product1(19) <= S(73);
	final_product1(20) <= S(74);
	final_product1(21) <= S(75);
	final_product1(22) <= S(76);
	final_product1(23) <= S(77);
	final_product1(24) <= S(78);
	final_product1(25) <= C(78);
	final_product1(26) <= not(muxs_out(6)(26)); --g26ط
	
	X(0) <= B(1);
	final_product2(0) <= X(0);
	final_product2(1) <= '0';
	X(1) <= B(3);
	final_product2(2) <= X(1); 
	final_product2(3) <= C(56);
	final_product2(4) <= C(57);
	final_product2(5) <= C(58);
	final_product2(6) <= C(59);
	final_product2(7) <= C(60);
	final_product2(8) <= C(61);
	final_product2(9) <= C(62);
	final_product2(10) <= C(63); 
	final_product2(11) <= C(64); 
	final_product2(12) <= C(65); 
	final_product2(13) <= C(66); 
	final_product2(14) <= C(67); 
	final_product2(15) <= C(68); 
	final_product2(16) <= C(69); 
	final_product2(17) <= C(70); 
	final_product2(18) <= C(71); 
	final_product2(19) <= C(72); 
	final_product2(20) <= C(73); 
	final_product2(21) <= C(74); 
	final_product2(22) <= C(75); 
	final_product2(23) <= C(76); 
	final_product2(24) <= C(77); 
	final_product2(25) <= not(muxs_out(6)(25)); -- g25'
	final_product2(26) <= muxs_out(6)(25); -- g26

	--Calculating the final products using FAST ADDER
	Partial_products_sum: sumx port map(final_product1, final_product2, P_out(26 downto 0));

	HA_final:HA port map( A=> muxs_out(6)(26) ,B=>muxs_out(6)(25) ,Co=>P_out(27));
	--Truncate the final value 
	P <= P_out(26 downto 13);


end architecture mixed;
