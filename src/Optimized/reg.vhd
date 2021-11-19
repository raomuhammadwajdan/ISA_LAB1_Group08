library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_signed.all;
ENTITY reg IS PORT(
	RST_n   : in  std_logic;
	VIN     : in  std_logic;	
	d   : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
	CLK : IN STD_LOGIC; -- clock.
	q   : OUT STD_LOGIC_VECTOR(13 DOWNTO 0) -- output
);
END reg;

ARCHITECTURE description OF reg IS

BEGIN
    process(RST_n,VIN,CLK)
    begin
	if RST_n = '0' then
		q <= (others => '0');
	elsif CLK'event and CLK = '1' and VIN = '1' then
      q <= d;
	end if;
    end process;
END description;
