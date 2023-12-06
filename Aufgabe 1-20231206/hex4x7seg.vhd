LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY hex4x7seg IS
   GENERIC(RSTDEF: std_logic := '0');
   PORT(rst:   IN  std_logic;                       -- reset,           active RSTDEF
        clk:   IN  std_logic;                       -- clock,           rising edge
        data:  IN  std_logic_vector(15 DOWNTO 0);   -- data input,      active high
        dpin:  IN  std_logic_vector( 3 DOWNTO 0);   -- 4 decimal point, active high
        ena:   OUT std_logic_vector( 3 DOWNTO 0);   -- 4 digit enable  signals,                active high
        seg:   OUT std_logic_vector( 7 DOWNTO 1);   -- 7 connections to seven-segment display, active high
        dp:    OUT std_logic);                      -- decimal point output,                   active high
END hex4x7seg;

ARCHITECTURE struktur OF hex4x7seg IS
  
  SIGNAL binnum : std_logic_vector (3 DOWNTO 0); 
  
  SIGNAL LFSR: std_logic_vector(13 downto 0);

BEGIN

    -- 1-aus-4-Multiplexer für BTNs
    WITH ena SELECT
        dp <=   dpin(0) WHEN "0001",
                dpin(1) WHEN "0010",
                dpin(2) WHEN "0100",
                dpin(3) WHEN OTHERS;
                
    WITH ena SELECT
        binnum <=   data(11  DOWNTO  8) WHEN "0001", --DIGIT_1 = _3 
                    data(15  DOWNTO  12) WHEN "0010", --DIGIT_2 = _4
                    data(3  DOWNTO  0) WHEN "0100", --DIGIT_3 = _1 sw 4->1
                    data(7  DOWNTO  4) WHEN "1000"; --DIGIT_4 = _2 sw 8->5

    -- 7-aus-4-Dekoder
    WITH binnum SELECT
        seg <=  "0111111" WHEN x"0",
                "0000110" WHEN x"1",
                "1011011" WHEN x"2",
                "1001111" WHEN x"3",
                "1100110" WHEN x"4",
                "1101101" WHEN x"5",
                "1111101" WHEN x"6",
                "0000111" WHEN x"7",
                "1111111" WHEN x"8",
                "1101111" WHEN x"9",
                "1110111" WHEN x"A",
                "1111100" WHEN x"B",
                "0111001" WHEN x"C",
                "1011110" WHEN x"D",
                "1111001" WHEN x"E",
                "1110001" WHEN OTHERS;

LSFR_clock: process(rst,clk) is
  begin
    IF rst=RSTDEF THEN
        LFSR <= (OTHERS => '0');
        ena <= (OTHERS => '0');
    ELSIF rising_edge(clk) THEN
        LFSR(0) <= not(LFSR(0)) xor LFSR(2) xor LFSR(4) xor LFSR(13);
        LFSR(13 downto 1) <= LFSR(12 downto 0);
        IF LFSR = "00000000000000" THEN
            IF ena = "0000" THEN
                ena <= "1000";
            ELSE
                ena <= ena(2 DOWNTO 0) & ena(3);
            END IF;
        END IF;
    END IF;
end process;

END struktur;