-- clock_counter.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_counter is
  port (
    clk      : in  std_logic;                       -- 100 MHz
    rst      : in  std_logic;                       -- sync reset, active-high
    en_1hz   : in  std_logic;                       -- 1 Hz enable pulse
    btn_set  : in  std_logic;                       -- SET (enter/exit config)
    btn_sel  : in  std_logic;                       -- SEL (choose H/M/S)
    btn_inc  : in  std_logic;                       -- INC (increment field)
    hours    : out std_logic_vector(5 downto 0);    -- 0-23
    minutes  : out std_logic_vector(5 downto 0);    -- 0-59
    seconds  : out std_logic_vector(5 downto 0)    -- 0-59
  );
end entity;

architecture Behavioral of clock_counter is

  -- Режимы работы
  type mode_t is (RUN, SET_H, SET_M, SET_S);
  signal mode      : mode_t := RUN;

  -- Внутренние счётчики
  signal sec_count : unsigned(5 downto 0) := (others => '0');
  signal min_count : unsigned(5 downto 0) := (others => '0');
  signal hr_count  : unsigned(5 downto 0) := (others => '0');


begin

  ----------------------------------------------------------------------------
  -- 1) FSM переключения режимов (SET / SEL)
  ----------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        mode <= RUN;

      elsif btn_set = '1' then
        -- вход/выход из режима настройки
        if mode = RUN then
          mode <= SET_H;
        else
          mode <= RUN;
        end if;

      elsif mode /= RUN and btn_sel = '1' then
        -- переключение между часами/минутами/секундами
        case mode is
          when SET_H => mode <= SET_M;
          when SET_M => mode <= SET_S;
          when SET_S => mode <= SET_H;
          when others => mode <= RUN;
        end case;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------------
  -- 2) Счёт времени и настройка
  ----------------------------------------------------------------------------
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        hr_count  <= (others => '0');
        min_count <= (others => '0');
        sec_count <= (others => '0');

      elsif mode = RUN then
        -- обычный режим: тик каждую секунду
        if en_1hz = '1' then
          if sec_count = to_unsigned(59, sec_count'length) then
            sec_count <= (others => '0');
            if min_count = to_unsigned(59, min_count'length) then
              min_count <= (others => '0');
              if hr_count = to_unsigned(23, hr_count'length) then
                hr_count <= (others => '0');
              else
                hr_count <= hr_count + 1;
              end if;
            else
              min_count <= min_count + 1;
            end if;
          else
            sec_count <= sec_count + 1;
          end if;
        end if;

      else
        -- режим настройки: при btn_inc инкремент выбранного поля
        if btn_inc = '1' then
          case mode is
            when SET_H =>
              if hr_count = to_unsigned(23, hr_count'length) then
                hr_count <= (others => '0');
              else
                hr_count <= hr_count + 1;
              end if;

            when SET_M =>
              if min_count = to_unsigned(59, min_count'length) then
                min_count <= (others => '0');
              else
                min_count <= min_count + 1;
              end if;

            when SET_S =>
              if sec_count = to_unsigned(59, sec_count'length) then
                sec_count <= (others => '0');
              else
                sec_count <= sec_count + 1;
              end if;

            when others =>
              null;
          end case;
        end if;
      end if;
    end if;
  end process;

  ----------------------------------------------------------------------------
  -- 4) Вывод значений наружу
  ----------------------------------------------------------------------------
  hours   <= std_logic_vector(hr_count);
  minutes <= std_logic_vector(min_count);
  seconds <= std_logic_vector(sec_count);

end architecture Behavioral;
