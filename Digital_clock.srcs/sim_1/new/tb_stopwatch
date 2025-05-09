-- tb_stopwatch.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_stopwatch is
end entity;

architecture sim of tb_stopwatch is

  -- UUT-порты
  signal clk        : std_logic := '0';
  signal rst        : std_logic := '1';
  signal btn_start  : std_logic := '0';
  signal btn_reset  : std_logic := '0';
  signal en_1hz     : std_logic := '0';
  signal hours      : std_logic_vector(5 downto 0);
  signal minutes    : std_logic_vector(5 downto 0);
  signal seconds    : std_logic_vector(5 downto 0);

  constant CLK_PERIOD : time := 10 ns;  -- 100 MHz

begin

  --------------------------------------------------------------------------
  -- 1) Инстанцируем UUT
  --------------------------------------------------------------------------
  UUT: entity work.stopwatch(Behavioral)
    port map(
      clk       => clk,
      rst       => rst,
      btn_start => btn_start,
      btn_reset => btn_reset,
      en_1hz    => en_1hz,
      hours     => hours,
      minutes   => minutes,
      seconds   => seconds
    );

  --------------------------------------------------------------------------
  -- 2) Генератор основного такта (100 MHz)
  --------------------------------------------------------------------------
  clk_gen: process
  begin
    clk <= '0';
    wait for CLK_PERIOD/2;
    clk <= '1';
    wait for CLK_PERIOD/2;
  end process;

  --------------------------------------------------------------------------
  -- 3) Синхронный сброс: держим rst='1' первые 20 ns, затем '0'
  --------------------------------------------------------------------------
  reset_proc: process
  begin
    rst <= '1';
    wait for 20 ns;
    rst <= '0';
    wait;
  end process;

  --------------------------------------------------------------------------
  -- 4) Генератор «1 Hz» такта: на 10 ns = '1', затем 90 ns = '0'
  --------------------------------------------------------------------------
  en1hz_gen: process
  begin
    wait for 30 ns;  -- подождём окончания сброса
    loop
      en_1hz <= '1';
      wait for 10 ns;
      en_1hz <= '0';
      wait for 90 ns;
    end loop;
  end process;

  --------------------------------------------------------------------------
  -- 5) Стимулы: START, PAUSE, RESET
  --------------------------------------------------------------------------
  stim_proc: process
  begin
    -- Дадим UUT «прокрутиться» на 5 тиках 1 Hz
    for i in 1 to 5 loop
      wait until en_1hz = '1';
    end loop;

    -- 5.1) Нажимаем START → RUN
    btn_start <= '1';
    wait for CLK_PERIOD;
    btn_start <= '0';

    -- 5.2) Засекаем 10 «секунд» (10 тиков en_1hz)
    for i in 1 to 10 loop
      wait until en_1hz = '1';
    end loop;

    -- 5.3) Нажимаем START → PAUSE
    btn_start <= '1';
    wait for CLK_PERIOD;
    btn_start <= '0';

    -- Подождём ещё 5 «секунд» в паузе (не будет изменений)
    for i in 1 to 5 loop
      wait until en_1hz = '1';
    end loop;

    -- 5.4) Ещё раз START → RUN
    btn_start <= '1';
    wait for CLK_PERIOD;
    btn_start <= '0';

    -- 5.5) Опять 5 «секунд»
    for i in 1 to 5 loop
      wait until en_1hz = '1';
    end loop;

    -- 5.6) Нажимаем RESET → сброс в 00:00:00
    btn_reset <= '1';
    wait for CLK_PERIOD;
    btn_reset <= '0';

    -- Хватит, завершаем
    wait for 100 ns;
    report "=== End of stopwatch simulation ===" severity note;
    wait;
  end process;
end architecture sim;
