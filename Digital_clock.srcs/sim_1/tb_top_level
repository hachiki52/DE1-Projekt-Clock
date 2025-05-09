library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top_level is
end entity;

architecture sim of tb_top_level is

  -- ускоренные «делители» для симуляции
  constant S_1HZ_COUNT  : integer := 20;  -- 20 тактов → 1 «секунда»
  constant S_1KHZ_COUNT : integer := 5;   -- 5 тактов  → 1 «миллисекунда»

  signal CLK100MHZ  : std_logic := '0';
  signal BTNC, BTNU, BTNL, BTND, BTNR : std_logic := '0';
  signal CA, CB, CC, CD, CE, CF, CG, DP : std_logic;
  signal AN : std_logic_vector(7 downto 0);

  constant CLK_PERIOD : time := 10 ns;  -- 100 MHz

begin

  ----------------------------------------------------------------------------
  -- 1) Инстанцируем DUT с подменой generics
  ----------------------------------------------------------------------------
  DUT: entity work.top_level(rtl)
    generic map(
      G_1HZ_COUNT  => S_1HZ_COUNT,
      G_1KHZ_COUNT => S_1KHZ_COUNT
    )
    port map(
      CLK100MHZ => CLK100MHZ,
      BTNC      => BTNC,
      BTNU      => BTNU,
      BTNL      => BTNL,
      BTND      => BTND,
      BTNR      => BTNR,
      CA        => CA,
      CB        => CB,
      CC        => CC,
      CD        => CD,
      CE        => CE,
      CF        => CF,
      CG        => CG,
      DP        => DP,
      AN        => AN
    );

  ----------------------------------------------------------------------------
  -- 2) Генератор 100 MHz
  ----------------------------------------------------------------------------
  clk_gen: process
  begin
    wait for CLK_PERIOD/2;
    CLK100MHZ <= not CLK100MHZ;
  end process;

  ----------------------------------------------------------------------------
  -- 3) Синхронный RESET (BTNC) - первые 5 тактов
  ----------------------------------------------------------------------------
  rst_proc: process
  begin
    BTNC <= '1';
    wait for 5 * CLK_PERIOD;
    BTNC <= '0';
    wait;
  end process;

  ----------------------------------------------------------------------------
  -- 4) Стимулы: 
  --    - даём часам «тикнуть» пару «секунд»
  --    - переключаем в секундомер, старт/пауза/сброс
  --    - возвращаемся в часы и настраиваем их
  ----------------------------------------------------------------------------
  stim: process
  begin
    -- 2 «секунды» на часах
    wait for 2 * S_1HZ_COUNT * CLK_PERIOD;

    -- → Stopwatch
    BTNR <= '1';  wait for CLK_PERIOD;  BTNR <= '0';
    wait for 5 * S_1HZ_COUNT * CLK_PERIOD;  -- пару «секунд» секундомера

    -- Start
    BTNU <= '1';  wait for CLK_PERIOD;  BTNU <= '0';
    wait for 10 * S_1HZ_COUNT * CLK_PERIOD;

    -- Pause
    BTNU <= '1';  wait for CLK_PERIOD;  BTNU <= '0';
    wait for 3 * S_1HZ_COUNT * CLK_PERIOD;

    -- Reset stopwatch
    BTND <= '1';  wait for CLK_PERIOD;  BTND <= '0';
    wait for 5 * S_1HZ_COUNT * CLK_PERIOD;

    -- ← Back to Clock
    BTNR <= '1';  wait for CLK_PERIOD;  BTNR <= '0';
    wait for 2 * S_1HZ_COUNT * CLK_PERIOD;

    -- Enter SET (Clock)
    BTNU <= '1';  wait for CLK_PERIOD;  BTNU <= '0';
    wait for CLK_PERIOD * 2;

    -- INC hours twice
    BTND <= '1';  wait for CLK_PERIOD;  BTND <= '0';
    wait for CLK_PERIOD * 5;
    BTND <= '1';  wait for CLK_PERIOD;  BTND <= '0';
    wait for CLK_PERIOD * 5;

    -- SEL → Minutes
    BTNL <= '1';  wait for CLK_PERIOD;  BTNL <= '0';
    wait for CLK_PERIOD * 5;

    -- INC minutes once
    BTND <= '1';  wait for CLK_PERIOD;  BTND <= '0';
    wait for CLK_PERIOD * 5;

    -- Exit SET
    BTNU <= '1';  wait for CLK_PERIOD;  BTNU <= '0';

    report "=== End of simulation ===";
    wait;
  end process;
end architecture sim;
