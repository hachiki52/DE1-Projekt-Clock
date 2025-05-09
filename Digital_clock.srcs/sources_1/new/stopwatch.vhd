library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stopwatch is
  port (
    clk       : in  std_logic;                        -- 100 MHz
    rst       : in  std_logic;                        -- synchr. reset
    btn_start : in  std_logic;                        -- edge: start/stop
    btn_reset : in  std_logic;                        -- edge: reset
    en_1hz    : in  std_logic;                        -- 1 Hz tick
    hours     : out std_logic_vector(5 downto 0);     -- 0-23
    minutes   : out std_logic_vector(5 downto 0);     -- 0-59
    seconds   : out std_logic_vector(5 downto 0)      -- 0-59
  );
end entity;

architecture Behavioral of stopwatch is
  type st_t is (IDLE, RUN, PAUSE);
  signal state : st_t := IDLE;
  signal hr_ct, min_ct, sec_ct : unsigned(5 downto 0) := (others=>'0');
begin

  p_fsm: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state  <= IDLE;
        hr_ct  <= (others=>'0');
        min_ct <= (others=>'0');
        sec_ct <= (others=>'0');
      else
        case state is
          when IDLE =>
            if btn_start='1' then state <= RUN; end if;
          when RUN =>
            if en_1hz='1' then
              if sec_ct = to_unsigned(59,6) then
                sec_ct <= (others=>'0');
                if min_ct = to_unsigned(59,6) then
                  min_ct <= (others=>'0');
                  if hr_ct = to_unsigned(23,6) then hr_ct <= (others=>'0');
                  else hr_ct <= hr_ct + 1;
                  end if;
                else min_ct <= min_ct + 1;
                end if;
              else sec_ct <= sec_ct + 1;
              end if;
            end if;
            if btn_start='1' then state <= PAUSE;
            elsif btn_reset='1' then
              state <= IDLE;
              hr_ct<= (others=>'0'); min_ct<= (others=>'0'); sec_ct<= (others=>'0');
            end if;
          when PAUSE =>
            if btn_start='1' then state <= RUN;
            elsif btn_reset='1' then
              state <= IDLE;
              hr_ct<= (others=>'0'); min_ct<= (others=>'0'); sec_ct<= (others=>'0');
            end if;
        end case;
      end if;
    end if;
  end process;

  hours   <= std_logic_vector(hr_ct);
  minutes <= std_logic_vector(min_ct);
  seconds <= std_logic_vector(sec_ct);

end architecture;
