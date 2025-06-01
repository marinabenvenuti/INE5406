library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity absolute_difference_tb is
    generic(
        N : positive := 8
    );
end absolute_difference_tb;

architecture behavior of absolute_difference_tb is
    signal input_a  : unsigned(N - 1 downto 0) := (others => '0');
    signal input_b : unsigned(N - 1 downto 0) := (others => '0');
    signal abs_diff  : unsigned(N - 1 downto 0);
begin

    -- Device Under Verification (duv)
    duv : entity work.absolute_difference
        generic map(N => N)
        port map(
            input_a  => input_a,
            input_b  => input_b,
            abs_diff => abs_diff
        );

    stim_proc : process
        constant step             : time    := 1 ns;
        variable number_of_errors : integer := 0;
        variable assert_result    : boolean;
        variable expected         : unsigned(N - 1 downto 0);

        type sample_array is array (natural range <>) of unsigned(N - 1 downto 0);
        constant input_a_vector  : sample_array := (
            to_unsigned(0, N),
            to_unsigned(2**N-1, N),
            to_unsigned(2**N-1, N),
            to_unsigned(0, N)
        );
        constant input_b_vector : sample_array := (
            to_unsigned(0, N),
            to_unsigned(2**N-1, N),
            to_unsigned(0, N),
            to_unsigned(2**N-1, N)
        );

    begin
        for i in input_a_vector'range loop
            -- Aplicar entradas
            input_a  <= input_a_vector(i);
            input_b <= input_b_vector(i);

            wait for step;

            -- Calcular esperado
            if input_a_vector(i) > input_b_vector(i) then
                expected := input_a_vector(i) - input_b_vector(i);
            else
                expected := input_b_vector(i) - input_a_vector(i);
            end if;

            -- Checar resultado
            assert_result := (abs_diff = expected);
            if not assert_result then
                number_of_errors := number_of_errors + 1;
            end if;
            assert assert_result
            report "Erro no teste " & integer'image(i) & ". Esperado: " & integer'image(to_integer(expected)) & " (" & to_string(expected) & "). Obtido: " & integer'image(to_integer(abs_diff)) & " (" & to_string(abs_diff) & ")."
            severity error;
        end loop;

        -- Mensagem final da simulação
        if number_of_errors > 0 then
            report "Foram detectados erros na simulação. Verifique e corrija os erros listados acima."
            severity failure;
        else
            report "Simulação executada sem erros."
            severity note;
        end if;

        wait;
    end process;

end behavior;
