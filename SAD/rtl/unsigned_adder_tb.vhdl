library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity unsigned_adder_tb is
    generic(
        N : positive := 8
    );
end unsigned_adder_tb;

architecture behavior of unsigned_adder_tb is
    signal input_a  : unsigned(N - 1 downto 0) := (others => '0');
    signal input_b : unsigned(N - 1 downto 0) := (others => '0');
    signal sum  : unsigned(N downto 0); -- has one bit more than the inputs
begin

    -- Device Under Verification (duv)
    duv : entity work.unsigned_adder
        generic map(N => N)
        port map(
            input_a  => input_a,
            input_b  => input_b,
            sum => sum
        );

    stim_proc : process
        constant step             : time    := 1 ns;
        variable number_of_errors : integer := 0;
        variable assert_result    : boolean;
        variable expected         : unsigned(N downto 0);

        type sample_array is array (natural range <>) of natural;
        constant input_a_vector  : sample_array := (0, 2**N-1, 2**N-1, 0);
        constant input_b_vector : sample_array := (0, 2**N-1, 0, 2**N-1);

    begin
        for i in input_a_vector'range loop
            -- Aplicar entradas
            input_a  <= to_unsigned(input_a_vector(i), N);
            input_b <= to_unsigned(input_b_vector(i), N);
            wait for step;

            --
            expected := to_unsigned(input_a_vector(i)+input_b_vector(i), N+1);

            -- Checar resultado
            assert_result := (sum = expected);
            if not assert_result then
                number_of_errors := number_of_errors + 1;
            end if;
            assert assert_result
            report "Erro no teste " & integer'image(i) & ". Esperado: " & integer'image(to_integer(expected)) & " (" & to_string(expected) & "). Obtido: " & integer'image(to_integer(sum)) & " (" & to_string(sum) & ")."
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
