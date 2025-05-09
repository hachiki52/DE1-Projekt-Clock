library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level is
  generic (
    G_1HZ_COUNT  : integer := 100_000_000;  -- 100 MHz→1 Hz
    G_1KHZ_COUNT : integer :=   100_000   -- 100 MHz→1 kHz
  );
  port (
    CLK100MHZ : in  std_logic;                       -- 100 MHz
    BTNC      : in  std_logic;                       -- RESET (active-high)
    BTNU      : in  std_logic;                       -- SET (Clock) / START (Stopwatch)
    BTNL      : in  std_logic;                       -- SEL (Clock)
    BTND      : in  std_logic;                       -- INC (Clock) / RESET (Stopwatch)
    BTNR      : in  std_logic;                       -- MODE (Clock↔Stopwatch)
    CA, CB, CC, CD, CE, CF, CG : out std_logic;       -- 7-seg сегменты (active-low)
    DP        : out std_logic;                       -- точка (между HH:MM и MM:SS)
    AN        : out std_logic_vector(7 downto 0)     -- аноды 8-цифр (active-low)
  );
end entity;

architecture rtl of top_level is

  -- «Enable» пульсы для делителей
  signal en_1hz_sig  : std_logic;
  signal en_1khz_sig : std_logic;

  -- Сигналы от нового debounce
  signal btnc_clean, btnu_clean, btnl_clean, btnd_clean, btnr_clean : std_logic;
  signal btnc_pos,   btnu_pos,   btnl_pos,   btnd_pos,   btnr_pos   : std_logic;

  -- Режим: '0'=Clock, '1'=Stopwatch
  signal mode_sel   : std_logic := '0';

  -- Gate-сигналы для разных режимов
  signal gate_set, gate_sel, gate_inc    : std_logic;
  signal gate_start, gate_reset          : std_logic;

  -- Выходы подсистем
  signal hr_clk, min_clk, sec_clk : std_logic_vector(5 downto 0);
  signal hr_sw,  min_sw,  sec_sw  : std_logic_vector(5 downto 0);

  -- Что в итоге на дисплей
  signal disp_h, disp_m, disp_s : std_logic_vector(5 downto 0);
  signal seg_sig                : std_logic_vector(6 downto 0);

  ------------------------------------------------------------------------
  -- Component declarations
  ------------------------------------------------------------------------

  component debounce is
    port(
      clk      : in  std_logic;  -- главный такт
      rst      : in  std_logic;  -- синхр. сброс (active-high)
      en       : in  std_logic;  -- тактовый enable
      bouncey  : in  std_logic;  -- «грязный» вход
      clean    : out std_logic;  -- очищенный уровень
      pos_edge : out std_logic;  -- импульс на фронте
      neg_edge : out std_logic   -- импульс на спаде (не используем)
    );
  end component;

  component clock_en is
    generic(n_periods : integer);
    port(clk   : in std_logic;
         rst   : in std_logic;
         pulse : out std_logic);
  end component;

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

  component stopwatch is
    port(
      clk       : in  std_logic;
      rst       : in  std_logic;
      btn_start : in  std_logic;
      btn_reset : in  std_logic;
      en_1hz    : in  std_logic;
      hours     : out std_logic_vector(5 downto 0);
      minutes   : out std_logic_vector(5 downto 0);
      seconds   : out std_logic_vector(5 downto 0)
    );
  end component;

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
  -- 1) Debounce всех кнопок новым FSM-дебаунсером
  ----------------------------------------------------------------------------
  D_C: debounce
    port map(
      clk      => CLK100MHZ,
      rst      => BTNC,
      en       => en_1khz_sig,
      bouncey  => BTNC,
      clean    => btnc_clean,
      pos_edge => btnc_pos,
      neg_edge => open
    );

  D_U: debounce
    port map(
      clk      => CLK100MHZ,
      rst      => BTNC,
      en       => en_1khz_sig,
      bouncey  => BTNU,
      clean    => btnu_clean,
      pos_edge => btnu_pos,
      neg_edge => open
    );

  D_L: debounce
    port map(
      clk      => CLK100MHZ,
      rst      => BTNC,
      en       => en_1khz_sig,
      bouncey  => BTNL,
      clean    => btnl_clean,
      pos_edge => btnl_pos,
      neg_edge => open
    );

  D_D: debounce
    port map(
      clk      => CLK100MHZ,
      rst      => BTNC,
      en       => en_1khz_sig,
      bouncey  => BTND,
      clean    => btnd_clean,
      pos_edge => btnd_pos,
      neg_edge => open
    );

  D_R: debounce
    port map(
      clk      => CLK100MHZ,
      rst      => BTNC,
      en       => en_1khz_sig,
      bouncey  => BTNR,
      clean    => btnr_clean,
      pos_edge => btnr_pos,
      neg_edge => open
    );

  ----------------------------------------------------------------------------
  -- 2) Генераторы «делителей» 1 Hz и 1 kHz
  ----------------------------------------------------------------------------
  C1Hz: clock_en
    generic map(n_periods => G_1HZ_COUNT)  -- 100 MHz → 1 Hz
    port map(clk => CLK100MHZ, rst => btnc_clean, pulse => en_1hz_sig);

  C1kHz: clock_en
    generic map(n_periods =>   G_1KHZ_COUNT)   -- 100 MHz → 1 kHz
    port map(clk => CLK100MHZ, rst => btnc_clean, pulse => en_1khz_sig);

  ----------------------------------------------------------------------------
  -- 3) FSM режима Clock (0) / Stopwatch (1)
  ----------------------------------------------------------------------------
  process(CLK100MHZ)
  begin
    if rising_edge(CLK100MHZ) then
      if btnc_clean = '1' then
        mode_sel <= '0';              -- RESET возвращает в режим часов
      elsif btnr_pos = '1' then
        mode_sel <= not mode_sel;     -- по кнопке MODE переключаем режим
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------------
  -- 4) Gate-логика: какие кнопки что делают в каждом режиме
  ----------------------------------------------------------------------------
  gate_set   <= btnu_pos when mode_sel = '0' else '0';  -- SET часов
  gate_sel   <= btnl_pos when mode_sel = '0' else '0';  -- SEL часов
  gate_inc   <= btnd_pos when mode_sel = '0' else '0';  -- INC часов
  gate_start <= btnu_pos when mode_sel = '1' else '0';  -- START секундомера
  gate_reset <= btnd_pos when mode_sel = '1' else '0';  -- RESET секундомера

  ----------------------------------------------------------------------------
  -- 5) Подсистема: часы с настройкой
  ----------------------------------------------------------------------------
  CC_inst : clock_counter
    port map(
      clk     => CLK100MHZ,
      rst     => btnc_clean,
      en_1hz  => en_1hz_sig,
      btn_set => gate_set,
      btn_sel => gate_sel,
      btn_inc => gate_inc,
      hours   => hr_clk,
      minutes => min_clk,
      seconds => sec_clk
    );

  ----------------------------------------------------------------------------
  -- 6) Подсистема: секундомер
  ----------------------------------------------------------------------------
  SW_inst : stopwatch
    port map(
      clk       => CLK100MHZ,
      rst       => btnc_clean,
      btn_start => gate_start,
      btn_reset => gate_reset,
      en_1hz    => en_1hz_sig,
      hours     => hr_sw,
      minutes   => min_sw,
      seconds   => sec_sw
    );

  ----------------------------------------------------------------------------
  -- 7) Выбор что выводить на дисплей
  ----------------------------------------------------------------------------
  disp_h <= hr_clk when mode_sel = '0' else hr_sw;
  disp_m <= min_clk when mode_sel = '0' else min_sw;
  disp_s <= sec_clk when mode_sel = '0' else sec_sw;

  ----------------------------------------------------------------------------
  -- 8) Мультиплексор 7-сег. дисплея
  ----------------------------------------------------------------------------
  DM_inst : display_mux
    port map(
      clk     => CLK100MHZ,
      rst     => btnc_clean,
      en      => en_1khz_sig,
      hours   => disp_h,
      minutes => disp_m,
      seconds => disp_s,
      seg     => seg_sig,
      an      => AN,
      dp      => DP
    );

  ----------------------------------------------------------------------------
  -- 9) Распиновка сегментов
  ----------------------------------------------------------------------------
  CA <= seg_sig(6);
  CB <= seg_sig(5);
  CC <= seg_sig(4);
  CD <= seg_sig(3);
  CE <= seg_sig(2);
  CF <= seg_sig(1);
  CG <= seg_sig(0);

end architecture rtl;
