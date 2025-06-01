library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux_2to1_tb is
    generic(
        N : positive := 4
    );
end mux_2to1_tb;

architecture testbench of mux_2to1_tb is
    signal sel  : std_logic                        := '0';
    signal in_0 : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal in_1 : std_logic_vector(N - 1 downto 0) := (others => '0');
    signal y    : std_logic_vector(N - 1 downto 0);
begin

    -- Device Under Verification (duv)
    duv : entity work.mux_2to1
        generic map(N => N)
        port map(
            sel  => sel,
            in_0 => in_0,
            in_1 => in_1,
            y    => y
        );

    stim_proc : process
        constant step             : time    := 1 ns;
        variable number_of_errors : integer := 0;
        variable assert_result    : boolean;
        variable expected         : std_logic_vector(N - 1 downto 0);

        function make_half_zero_half_one(NBits : natural; lower_half : std_logic) return std_logic_vector is
            variable result : std_logic_vector(NBits - 1 downto 0);
        begin
            result(result'length / 2 - 1 downto 0) := (others => lower_half);
            result(result'length - 1 downto N / 2) := (others => not lower_half);
            return result;
        end function;

        type vector_array is array (natural range <>) of std_logic_vector(N - 1 downto 0);
        constant test_in0 : vector_array := (
            make_half_zero_half_one(N, '1'),
            (others => '0'),
            (others => '1')
        );
        constant test_in1 : vector_array := (
            make_half_zero_half_one(N, '0'),
            (others => '1'),
            (others => '0')
        );
    begin
        for i in test_in0'range loop
            -- Apply inputs
            in_0 <= test_in0(i);
            in_1 <= test_in1(i);

            -- Test sel = '0'
            sel           <= '0';
            wait for step;
            expected      := in_0;
            assert_result := (y = expected);
            if not assert_result then
                number_of_errors := number_of_errors + 1;
            end if;
            assert assert_result
            report "Erro. Teste " & integer'image(i) & " - Seleção=0. Esperado: " & to_string(expected) & ". Obtido: " & to_string(y)
            severity error;

            -- Test sel = '1'
            sel           <= '1';
            wait for step;
            expected      := in_1;
            assert_result := (y = expected);
            if not assert_result then
                number_of_errors := number_of_errors + 1;
            end if;
            assert assert_result
            report "Erro. Teste " & integer'image(i) & " - Seleção=1. Esperado: " & to_string(expected) & ". Obtido: " & to_string(y)
            severity error;
        end loop;

        -- Final simulation report
        if number_of_errors > 0 then
            report "Foram detectados erros na simulação com (N=" & positive'image(N) & "). Verifique os e corrija os erros listados acima."
            severity failure;
        else
            report "Simulação executada sem erros."
            severity note;
        end if;

        wait;
    end process;

end testbench;
