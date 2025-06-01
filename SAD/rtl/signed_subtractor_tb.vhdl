library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signed_subtractor_tb is
    generic(
        N : positive := 8
    );
end signed_subtractor_tb;

architecture behavior of signed_subtractor_tb is
    signal input_a  : signed(N - 1 downto 0) := (others => '0');
    signal input_b : signed(N - 1 downto 0) := (others => '0');
    signal result  : signed(N-1 downto 0); -- has the same number of bits as the inputs
begin

    -- Device Under Verification (duv)
    duv : entity work.signed_subtractor
        generic map(N => N)
        port map(
            input_a  => input_a,
            input_b  => input_b,
            difference => result
        );

    stim_proc : process
        constant step             : time    := 1 ns;
        variable number_of_errors : integer := 0;
        variable assert_result    : boolean;
        variable expected         : signed(N-1 downto 0);

        type sample_array is array (natural range <>) of integer;
        constant input_a_vector  : sample_array := (0, 2**(N-1)-1, 2**(N-1)-1, 0);
        constant input_b_vector : sample_array := (0, 2**(N-1)-1, 0, 2**(N-1)-1);

    begin
        for i in input_a_vector'range loop
            -- Aplicar entradas
            input_a  <= to_signed(input_a_vector(i), N);
            input_b <= to_signed(input_b_vector(i), N);
            wait for step;

            --
            expected := to_signed(input_a_vector(i)-input_b_vector(i), N);

            -- Checar resultado
            assert_result := (result = expected);
            if not assert_result then
                number_of_errors := number_of_errors + 1;
            end if;
            assert assert_result
            report "Erro no teste " & integer'image(i) & ". Esperado: " & integer'image(to_integer(expected)) & " (" & to_string(expected) & "). Obtido: " & integer'image(to_integer(result)) & " (" & to_string(result) & ")."
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
