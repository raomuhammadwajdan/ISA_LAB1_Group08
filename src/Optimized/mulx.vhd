library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_signed.all;

library std;
use std.textio.all;

entity mulx is  
  port (
    mult1 : in std_logic_vector (13 downto 0);
    mult2 : in std_logic_vector (13 downto 0);
    prod: out std_logic_vector ( 13 downto 0));
end mulx;

architecture str1 of mulx is
signal temp:std_logic_vector (27 downto 0);
begin
    temp <= SIGNED (mult1)*SIGNED(mult2);
    prod <= temp(26 downto 13);
end str1;
