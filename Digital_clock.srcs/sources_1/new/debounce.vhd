-- https://stackoverflow.com/questions/61630181/vhdl-button-debouncing-or-not-as-the-case-may-be

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

entity debounce is
    generic (
        DB_CYCLES : integer := 2_500_000;  -- ≈25 ms @ 100 MHz
        SYNC_BITS : integer := 2           -- глубина синхронизационного буфера (минимум 2)
    );
    port (
        clk     : in    std_logic;
        btn_in  : in    std_logic; -- Asynchronous and noisy input
        btn_out : out   std_logic; -- Synchronised, debounced and filtered output
        edge    : out   std_logic;
        rise    : out   std_logic;
        fall    : out   std_logic
    );
end entity debounce;

architecture v1 of debounce is

    signal sync_buffer : std_logic_vector(SYNC_BITS - 1 downto 0);
    alias  sync_input  : std_logic is sync_buffer(SYNC_BITS - 1);
    signal sig_count   : integer range 0 to  DB_CYCLES := 0;
    signal sig_btn     : std_logic;

begin
    p_debounce : process (clk) is
        variable edge_internal : std_logic;
        variable rise_internal : std_logic;
        variable fall_internal : std_logic;

    begin
        if rising_edge(clk) then
            -- Synchronise the asynchronous input
            -- MSB of sync_buffer is the synchronised input
            sync_buffer <= sync_buffer(SYNC_BITS - 2 downto 0) & btn_in;

            edge <= '0';
            rise <= '0';
            fall <= '0';

            -- If successfully debounced, notify what happened, and reset the sig_count
            if sync_input /= sig_btn then
                if sig_count < DB_CYCLES then
                    sig_count <= sig_count + 1;
                else
                    sig_btn   <= sync_input;  -- принимаем новое стабильное состояние
                    sig_count <= 0;           -- и сбрасываем счётчик
                end if;
            else
                sig_count <= 0;             -- уровень не меняется — сбрасываем счётчик
            end if;

        end if;

        -- Edge detection
        edge_internal := sync_input xor sig_btn;
        rise_internal := sync_input and not sig_btn;
        fall_internal := not sync_input and sig_btn;
        edge    <= edge_internal;
        rise    <= rise_internal;
        fall    <= fall_internal;
        btn_out       <= sig_btn;

    end process p_debounce;

end architecture v1;