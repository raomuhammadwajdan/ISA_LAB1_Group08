library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_signed.all;

library std;
use std.textio.all;

entity subx is  
  port (
    sub1 : in std_logic_vector (13 downto 0);
    sub2 : in std_logic_vector (13 downto 0);
    rel1: out std_logic_vector (13 downto 0));
end subx;

architecture str_sub of subx is
  --signal rel_temp:std_logic_vector (14 downto 0);
  begin
    rel1 <= - SIGNED (sub1) - SIGNED(sub2);
    --rel1 <= rel_temp (14 downto 1);
end str_sub;
