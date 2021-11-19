library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_signed.all;

library std;
use std.textio.all;

entity IIR_CA is  
  port (
    CLK     : in  std_logic;
    RST_n   : in  std_logic;
	VIN     : in std_logic;
	DIN		: in  std_logic_vector(13 downto 0); --14 bit data input
	B0		: in  std_logic_vector(13 downto 0);
	B1		: in  std_logic_vector(13 downto 0);
	B2		: in  std_logic_vector(13 downto 0);
	A1		: in  std_logic_vector(13 downto 0);
	A2		: in  std_logic_vector(13 downto 0);
    VOUT    : out std_logic;
    DOUT    : out std_logic_vector(13 downto 0)); 
												  --may leads to overflow
end IIR_CA;

architecture bhv of IIR_CA is
	signal fb	: signed(13 downto 0);
	signal ff	: signed(13 downto 0);
	signal w 	: signed(13 downto 0);
	signal reg1	: signed(13 downto 0);
	signal reg2	: signed(13 downto 0);
	signal temp1: signed(27 downto 0); --If we have n bit the multiplication can leads to 2*n bits.
	signal temp2: signed(27 downto 0);
	signal temp3: signed(27 downto 0);
	signal temp4: signed(27 downto 0);
	signal temp5: signed(27 downto 0);
	signal mul1 : signed(13 downto 0);
	signal mul2 : signed(13 downto 0);
	signal mul3 : signed(13 downto 0);
	signal mul4 : signed(13 downto 0);
	signal mul5 : signed(13 downto 0);
	signal xin:  std_logic_vector(13 downto 0);
	signal DOUT_temp: std_logic_vector(13 downto 0);
begin
	temp1 <= reg1*signed(A1);--multi
	mul1  <= temp1(26 downto 13);--shift
	temp2 <= reg2*signed(A2);
	mul2  <= temp2(26 downto 13); --taking only 14 bit of MSB
	temp3 <= reg1*signed(B1);
	mul3  <= temp3(26 downto 13);
	temp4 <= reg2*signed(B2);
	mul4  <= temp4(26 downto 13);
	temp5 <= w*signed(B0);
	mul5  <= temp5(26 downto 13);
	fb <= -mul1-mul2;--feedback
	ff <= mul3+mul4;--feedforward
	w 	 <= signed(xin)+fb;
	DOUT_temp <= conv_std_logic_vector(ff+mul5,14); --Converting it to vector 14 bits
	DOUT <= DOUT_temp(13 downto 0);
	process(CLK,RST_n,VIN)
		begin
		if RST_n = '0' then -- Everything 0 if reset
			reg1 <= (others => '0');
			reg2 <= (others => '0');
			VOUT <= '0';
			xin  <= (others => '0');
		elsif CLK'event and CLK = '1' and VIN = '1' then
			VOUT <= '0';
			xin(13 downto 0) <= DIN;
			reg2 <= reg1; -- In proces this will model after a FF so no need to add an extra FF.
			reg1 <= w;
			VOUT <= '1';			
		end if;
	end process;
end bhv;
