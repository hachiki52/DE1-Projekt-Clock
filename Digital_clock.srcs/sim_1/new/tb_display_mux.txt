-- tb_display_mux.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_display_mux is
end entity;

architecture sim of tb_display_mux is

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

  constant CLK_PERIOD : time := 10 ns;  -- 100 MHz

  signal clk     : std_logic := '0';
  signal rst     : std_logic := '1';
  signal en      : std_logic := '0';
  signal hours   : std_logic_vector(5 downto 0) := (others => '0');
  signal minutes : std_logic_vector(5 downto 0) := (others => '0');
  signal seconds : std_logic_vector(5 downto 0) := (others => '0');
  signal seg     : std_logic_vector(6 downto 0);
  signal an      : std_logic_vector(7 downto 0);
  signal dp      : std_logic;

begin

  -- Instantiate DUT
  dut: display_mux
    port map (
      clk     => clk,
      rst     => rst,
      en      => en,
      hours   => hours,
      minutes => minutes,
      seconds => seconds,
      seg     => seg,
      an      => an,
      dp      => dp
    );

  -- Clock generator: 100 MHz
  clk <= not clk after CLK_PERIOD/2;

  -- Stimulus process
  stimuli: process
  begin
    -- 1) Сброс на 50 ns
    rst <= '1'; en <= '0';
    wait for 50 ns;
    rst <= '0';
    -- 2) Подать enable сканирования
    en <= '1';

    -- 3) Бесконечное наращивание времени
    loop
      -- Подождать один «ненулевой» период, чтобы scan_cnt прошёл 0..5
      wait for 200 ns;

      -- Инкремент секунд
      if unsigned(seconds) < 59 then
        seconds <= std_logic_vector(unsigned(seconds) + 1);
      else
        seconds <= (others => '0');
        -- Инкремент минут
        if unsigned(minutes) < 59 then
          minutes <= std_logic_vector(unsigned(minutes) + 1);
        else
          minutes <= (others => '0');
          -- Инкремент часов
          if unsigned(hours) < 23 then
            hours <= std_logic_vector(unsigned(hours) + 1);
          else
            hours <= (others => '0');
          end if;
        end if;
      end if;
    end loop;
  end process;

end architecture sim;
