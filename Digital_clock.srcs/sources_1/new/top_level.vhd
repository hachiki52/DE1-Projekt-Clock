-- top_level.vhd
-- Топ-уровень с поддержкой настройки времени и аппаратным дебаунсом кнопок

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level is
  port (
    CLK100MHZ : in  std_logic;                      -- 100 MHz такт
    BTNC      : in  std_logic;                      -- кнопка RESET (active-high)
    BTNU      : in  std_logic;                      -- кнопка SET (вход/выход в режим настройки)
    BTNL      : in  std_logic;                      -- кнопка SEL (выбор поля H/M/S)
    BTND      : in  std_logic;                      -- кнопка INC (инкремент выбранного поля)
    CA        : out std_logic;                      -- сегмент A (active-low)
    CB        : out std_logic;                      -- сегмент B
    CC        : out std_logic;                      -- сегмент C
    CD        : out std_logic;                      -- сегмент D
    CE        : out std_logic;                      -- сегмент E
    CF        : out std_logic;                      -- сегмент F
    CG        : out std_logic;                      -- сегмент G
    DP        : out std_logic;                      -- десятичная точка (off)
    AN        : out std_logic_vector(7 downto 0)   -- аноды 8-цифр (active-low)
  );
end entity top_level;

architecture structural of top_level is

  -- Тактовые enable-сигналы
  signal en_1hz_sig  : std_logic;
  signal en_1khz_sig : std_logic;

  -- Шины времени
  signal hours_sig   : std_logic_vector(5 downto 0);
  signal minutes_sig : std_logic_vector(5 downto 0);
  signal seconds_sig : std_logic_vector(5 downto 0);

  -- Семисегментный код
  signal seg_sig     : std_logic_vector(6 downto 0);

  -- Сигналы от дебаунсера
  signal btnc_db, btnu_db, btnl_db, btnd_db : std_logic;
  signal btnc_edge, btnu_edge, btnl_edge, btnd_edge : std_logic;

  ----------------------------------------------------------------
  component debounce is
    generic (
      DB_CYCLES : integer := 2_500_000;  -- ~25 ms при 100 MHz
      SYNC_BITS : integer := 2
    );
    port (
      clk     : in  std_logic;
      btn_in  : in  std_logic;
      btn_out : out std_logic;
      edge    : out std_logic;
      rise    : out std_logic;
      fall    : out std_logic
    );
  end component;

  ----------------------------------------------------------------
  component clock_en is
    generic ( n_periods : integer );
    port(
      clk   : in  std_logic;
      rst   : in  std_logic;
      pulse : out std_logic
    );
  end component;

  ----------------------------------------------------------------
  component clock_counter is
    port(
      clk     : in  std_logic;
      rst     : in  std_logic;
      en_1hz  : in  std_logic;
      btn_set : in  std_logic;
      btn_sel : in  std_logic;
      btn_inc : in  std_logic;
      hours   : out std_logic_vector(5 downto 0);
      minutes : out std_logic_vector(5 downto 0);
      seconds : out std_logic_vector(5 downto 0)
    );
  end component;

  ----------------------------------------------------------------
  component display_mux is
    port(
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
  end component;

begin

  ----------------------------------------------------------------------------
  -- 1) Дебаунс кнопок
  ----------------------------------------------------------------------------
  dbg_btnc: debounce
    generic map(DB_CYCLES=>2_500_000, SYNC_BITS=>2)
    port map(
      clk    => CLK100MHZ,
      btn_in => BTNC,
      btn_out=> btnc_db,
      edge   => btnc_edge,
      rise   => open,
      fall   => open
    );

  dbg_btnu: debounce
    generic map(DB_CYCLES=>2_500_000, SYNC_BITS=>2)
    port map(
      clk    => CLK100MHZ,
      btn_in => BTNU,
      btn_out=> btnu_db,
      edge   => btnu_edge,
      rise   => open,
      fall   => open
    );

  dbg_btnl: debounce
    generic map(DB_CYCLES=>2_500_000, SYNC_BITS=>2)
    port map(
      clk    => CLK100MHZ,
      btn_in => BTNL,
      btn_out=> btnl_db,
      edge   => btnl_edge,
      rise   => open,
      fall   => open
    );

  dbg_btnd: debounce
    generic map(DB_CYCLES=>2_500_000, SYNC_BITS=>2)
    port map(
      clk    => CLK100MHZ,
      btn_in => BTND,
      btn_out=> btnd_db,
      edge   => btnd_edge,
      rise   => open,
      fall   => open
    );

  ----------------------------------------------------------------------------
  -- 2) Генераторы enable-импульсов
  ----------------------------------------------------------------------------
  clk_en_1hz_inst: clock_en
    generic map(n_periods => 100_000_000)  -- 100 MHz → 1 Hz
    port map(
      clk   => CLK100MHZ,
      rst   => btnc_db,      -- сброс через очищенный сигнал
      pulse => en_1hz_sig
    );

  clk_en_1khz_inst: clock_en
    generic map(n_periods => 100_000)      -- 100 MHz → ~1 kHz
    port map(
      clk   => CLK100MHZ,
      rst   => btnc_db,
      pulse => en_1khz_sig
    );

  ----------------------------------------------------------------------------
  -- 3) Счётчик времени с настройкой
  ----------------------------------------------------------------------------
  clock_counter_inst: clock_counter
    port map(
      clk     => CLK100MHZ,
      rst     => btnc_db,
      en_1hz  => en_1hz_sig,
      btn_set => btnu_edge,
      btn_sel => btnl_edge,
      btn_inc => btnd_edge,
      hours   => hours_sig,
      minutes => minutes_sig,
      seconds => seconds_sig
    );

  ----------------------------------------------------------------------------
  -- 4) Мультиплексор дисплея
  ----------------------------------------------------------------------------
  display_mux_inst: display_mux
    port map(
      clk     => CLK100MHZ,
      rst     => btnc_db,
      en      => en_1khz_sig,
      hours   => hours_sig,
      minutes => minutes_sig,
      seconds => seconds_sig,
      seg     => seg_sig,
      an      => AN,
      dp      => DP
    );

  ----------------------------------------------------------------------------
  -- 5) Подключение сегментов
  ----------------------------------------------------------------------------
  CA <= seg_sig(6);
  CB <= seg_sig(5);
  CC <= seg_sig(4);
  CD <= seg_sig(3);
  CE <= seg_sig(2);
  CF <= seg_sig(1);
  CG <= seg_sig(0);

end architecture structural;
