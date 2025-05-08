-- display_mux.vhd
-- Модуль мультиплексного управления 7-сегментным индикатором
-- С помощью bin2seg декодирует BCD-цифру в сегменты (active-low),
-- а затем циклически переключает аноды (active-low) для отображения HH:MM:SS.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_mux is
  port (
    clk     : in  std_logic;                      
    rst     : in  std_logic;                      
    en      : in  std_logic;                      
    hours   : in  std_logic_vector(5 downto 0);   
    minutes : in  std_logic_vector(5 downto 0);   
    seconds : in  std_logic_vector(5 downto 0);   
    seg     : out std_logic_vector(6 downto 0);   
    an      : out std_logic_vector(7 downto 0);   
    dp      : out std_logic                      
  );
end entity display_mux;

architecture Behavioral of display_mux is

  -- счётчик сканирования цифр (0…5)
  signal scan_cnt : integer range 0 to 5 := 0;

  -- BCD для каждого разряда
  signal h_tens, h_ones     : std_logic_vector(3 downto 0);
  signal m_tens, m_ones     : std_logic_vector(3 downto 0);
  signal s_tens, s_ones     : std_logic_vector(3 downto 0);
  signal digit              : std_logic_vector(3 downto 0);

begin

 
  -- 1) Разбиение входных 6-бит на две BCD цифры
  process(hours, minutes, seconds)
    variable hv, mv, sv : integer;
  begin
    hv := to_integer(unsigned(hours));
    mv := to_integer(unsigned(minutes));
    sv := to_integer(unsigned(seconds));
    h_tens  <= std_logic_vector(to_unsigned(hv / 10, 4));
    h_ones  <= std_logic_vector(to_unsigned(hv mod 10, 4));
    m_tens  <= std_logic_vector(to_unsigned(mv / 10, 4));
    m_ones  <= std_logic_vector(to_unsigned(mv mod 10, 4));
    s_tens  <= std_logic_vector(to_unsigned(sv / 10, 4));
    s_ones  <= std_logic_vector(to_unsigned(sv mod 10, 4));
  end process;


  -- 2) Сканирующий счётчик: переключается на каждом «en»
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        scan_cnt <= 0;
      elsif en = '1' then
        if scan_cnt = 5 then
          scan_cnt <= 0;
        else
          scan_cnt <= scan_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  -- 3) Выбор цифры и анода по scan_cnt
  with scan_cnt select
    digit <= s_ones when 0,
             s_tens when 1,
             m_ones when 2,
             m_tens when 3,
             h_ones when 4,
             h_tens when 5,
             (others => '0') when others;

  with scan_cnt select
    an <= "11111110" when 0,  -- digit0 on
          "11111101" when 1,
          "11111011" when 2,
          "11110111" when 3,
          "11101111" when 4,
          "11011111" when 5,
          "11111111" when others;

  -- точка ON (LOW) после HH и после MM

  dp <= '0' when (scan_cnt = 4 or scan_cnt = 2) else
        '1';

  -- 5) Декодер BCD→7-seg (active-low) - используем bin2seg
  bin2seg_inst: entity work.bin2seg(behavioral)
    port map (
      clear => rst,     
      bin   => digit,   
      seg   => seg     
    );

end architecture Behavioral;