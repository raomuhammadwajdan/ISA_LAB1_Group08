library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_signed.all;

library std;
use std.textio.all;

entity sumx is  
  port (
    add1 : in std_logic_vector (13 downto 0);
    add2 : in std_logic_vector (13 downto 0);
    sum1: out std_logic_vector (13 downto 0));
end sumx;

architecture str of sumx is
  --signal sum_temp:std_logic_vector (14 downto 0);
  begin
    sum1 <= SIGNED (add1)+ SIGNED(add2);
    --sum1 <= sum_temp (14 downto 1);
end str;
