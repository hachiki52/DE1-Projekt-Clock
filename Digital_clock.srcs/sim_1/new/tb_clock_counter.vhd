-- tb_clock_counter.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_clock_counter is
end entity;

architecture sim of tb_clock_counter is

  -- Сигналы, повторяющие порты clock_counter
  signal clk      : std_logic := '0';
  signal rst      : std_logic := '1';
  signal en_1hz   : std_logic := '0';
  signal btn_set  : std_logic := '0';
  signal btn_sel  : std_logic := '0';
  signal btn_inc  : std_logic := '0';
  signal hours    : std_logic_vector(5 downto 0);
  signal minutes  : std_logic_vector(5 downto 0);
  signal seconds  : std_logic_vector(5 downto 0);

begin

  -- 1) UUT: clock_counter
  uut: entity work.clock_counter(Behavioral)
    port map(
      clk     => clk,
      rst     => rst,
      en_1hz  => en_1hz,
      btn_set => btn_set,
      btn_sel => btn_sel,
      btn_inc => btn_inc,
      hours   => hours,
      minutes => minutes,
      seconds => seconds
    );

  -- 2) Генерация основного такта 100 MHz (T=10 ns)
  clk_gen: process
  begin
    wait for 5 ns; 
    clk <= not clk;
  end process;

  -- 3) Сброс: держим rst='1' первые 20 ns, затем отпускаем
  rst_proc: process
  begin
    wait for 20 ns;
    rst <= '0';
    wait;
  end process;

  -- 4) «1 Hz» тик: en_1hz = '1' на 10 ns, каждые 100 ns
  en1hz_gen: process
  begin
    wait for 50 ns; -- даём немного покрутиться счётчику
    loop
      en_1hz <= '1';
      wait for 10 ns;
      en_1hz <= '0';
      wait for 90 ns;
    end loop;
  end process;

  -- 5) Стимулы по кнопкам: после нескольких «секунд» войти в SET,
  --    прокрутить часы и минуты, выйти из SET
  stim: process
  begin
    -- ждём 500 ns (≈5 «секунд»)
    wait for 500 ns;

    -- войти в режим настройки
    btn_set <= '1'; wait for 10 ns; btn_set <= '0';  
    wait for 50 ns;

    -- увеличить часы два раза
    btn_inc <= '1'; 
    wait for 10 ns; 
    btn_inc <= '0';
    wait for 100 ns;
    btn_inc <= '1'; 
    wait for 10 ns; 
    btn_inc <= '0';
    wait for 100 ns;

    -- переключиться на минуты
    btn_sel <= '1'; 
    wait for 10 ns; 
    btn_sel <= '0';
    wait for 50 ns;

    -- увеличить минуты один раз
    btn_inc <= '1'; 
    wait for 10 ns; 
    btn_inc <= '0';
    wait for 100 ns;

    -- выйти из режима настройки
    btn_set <= '1'; wait for 10 ns; btn_set <= '0';
    wait for 200 ns;

    -- закончить симуляцию
    report "=== End of simulation ===";
    wait;
  end process;

end architecture;
