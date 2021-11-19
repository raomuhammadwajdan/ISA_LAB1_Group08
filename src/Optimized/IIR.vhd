--file edited by wajdan on 05/11/2021
--Edited by Talha on 06/11/2021
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_signed.all;

library std;
use std.textio.all;

entity IIR_ADV is  
  port (
    	CLK     : in  std_logic;
	RST_n   : in  std_logic;
	VIN     : in  std_logic;
	DIN	: in  std_logic_vector(13 downto 0);
	B0	: in  std_logic_vector(13 downto 0);
	B1	: in  std_logic_vector(13 downto 0);
	B2	: in  std_logic_vector(13 downto 0);
	B3	: in  std_logic_vector(13 downto 0);
	A1	: in  std_logic_vector(13 downto 0);
	A2	: in  std_logic_vector(13 downto 0);
    	VOUT    : out std_logic;
    	DOUT    : out std_logic_vector(13 downto 0));
end IIR_ADV;

architecture bhv of IIR_ADV is

component reg 
port(
    RST_n   : in  std_logic;
    VIN     : in  std_logic;
    d   : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    CLK : IN STD_LOGIC; -- clock.
    q   : OUT STD_LOGIC_VECTOR(13 DOWNTO 0) -- output
);
END component;

component mulx
port (
    mult1 : in std_logic_vector (13 downto 0);
    mult2 : in std_logic_vector (13 downto 0);
    prod: out std_logic_vector (13 downto 0));
end component;

component sumx
port (
    add1 : in std_logic_vector (13 downto 0);
    add2 : in std_logic_vector (13 downto 0);
    sum1: out std_logic_vector (13 downto 0));
end component;

component subx  
  port (
    sub1 : in std_logic_vector (13 downto 0);
    sub2 : in std_logic_vector (13 downto 0);
    rel1: out std_logic_vector (13 downto 0));
end component;

	signal 	fb	: STD_LOGIC_VECTOR(13 downto 0);
	signal 	ff	: STD_LOGIC_VECTOR(13 downto 0);
	signal 	w 	: STD_LOGIC_VECTOR(13 downto 0);
	signal 	reg2	: STD_LOGIC_VECTOR(13 downto 0);
	signal 	reg3	: STD_LOGIC_VECTOR(13 downto 0);
	signal 	reg4	: STD_LOGIC_VECTOR(13 downto 0);
	signal 	reg5	: STD_LOGIC_VECTOR(13 downto 0);
	signal 	reg6	: STD_LOGIC_VECTOR(13 downto 0);
	signal 	reg7	: STD_LOGIC_VECTOR(13 downto 0);
	signal 	reg1_reg	: std_logic_vector(13 downto 0);
	signal 	reg2_reg	: std_logic_vector(13 downto 0);
	signal 	reg3_reg	: std_logic_vector(13 downto 0);
	signal 	reg4_reg	: std_logic_vector(13 downto 0);
	signal	temp1	: STD_LOGIC_VECTOR(13 downto 0);
	signal 	temp2	: STD_LOGIC_VECTOR(13 downto 0);  
	signal 	temp3	: STD_LOGIC_VECTOR(13 downto 0);  
	signal 	temp4	: STD_LOGIC_VECTOR(13 downto 0);
	signal 	temp5	: STD_LOGIC_VECTOR(13 downto 0);
	signal 	temp6	: STD_LOGIC_VECTOR(13 downto 0);
	signal 	mul1_reg 	: std_logic_vector(13 downto 0);
	signal 	mul2_reg 	: std_logic_vector(13 downto 0);
	signal 	mul3_reg 	: std_logic_vector(13 downto 0);
	signal 	mul4_reg 	: std_logic_vector(13 downto 0);
	signal 	xin		: std_logic_vector(13 downto 0);
	signal sig_ff1: std_logic_vector(13 downto 0);
  	signal sig_ff2: std_logic_vector(13 downto 0);
begin	


	
	REGISTER1: reg port map (RST_n,VIN,w,CLK,reg1_reg); 
	p6: mulx port map(reg1_reg, B0, temp1);
	REG1_1: reg port map (RST_n,VIN,temp1,CLK,mul1_reg);  --After the register which is after B0 coefficient 
	                                                      
	REGISTER2: reg port map (RST_n,VIN,reg2, CLK ,reg2_reg); 
	p7: mulx port map(reg2_reg, B1, temp2);		
	REG2_1: reg port map (RST_n,VIN,temp2,CLK,mul2_reg);   --After the register which is after B1 coefficient
	
	REGISTER3: reg port map (RST_n,VIN,reg3,CLK,reg3_reg); 
	p8: mulx port map(reg3_reg, B2, temp3);				
	REG3_1: reg port map (RST_n,VIN,temp3,CLK,mul3_reg);   --After the register which is after B2 coefficient
	
	REGISTER4: reg port map (RST_n,VIN,reg5,CLK,reg4_reg); 
	p9: mulx port map(reg4_reg, B3, temp4);
	REG4_1: reg port map (RST_n,VIN,temp4,CLK, mul4_reg);
	 
	p11: mulx port map(reg2, A1, temp6);
	p10: mulx port map(reg4,A2, temp5); 
	SUB1: subx port map(reg6,reg7,fb);
 
	s6:sumx port map(mul1_reg,mul2_reg,sig_ff1);
	s7:sumx port map(mul3_reg,mul4_reg,sig_ff2);
	s8:sumx port map(sig_ff1,sig_ff2, ff);
	s9: sumx port map(fb,xin,w);
	DOUT <= ff;
	
	REG11: reg port map (RST_n,VIN,w,CLK,reg2); 
   	REG21: reg port map (RST_n,VIN,reg2,CLK,reg3); 
  	REG31: reg port map (RST_n,VIN,reg2,CLK,reg4); 
  	REG41: reg port map (RST_n,VIN,reg4,CLK,reg5); 
   	REG51: reg port map (RST_n,VIN,temp5,CLK,reg6); 
   	REG61: reg port map (RST_n,VIN,temp6,CLK,reg7); 

	process(CLK,RST_n,VIN)
		begin
		if RST_n = '0' then
			VOUT <= '0';
			xin  <= (others => '0');
		elsif CLK'event and CLK = '1' and VIN = '1' then
			VOUT <= '0';
			xin(13 downto 0) <= DIN;
			VOUT <= '1';	
		end if;
	end process;
end bhv;
