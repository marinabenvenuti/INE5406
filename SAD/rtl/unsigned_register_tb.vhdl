library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;

entity unsigned_register_tb is
    generic (
        N : positive := 4
    );
end unsigned_register_tb;

architecture behavior of unsigned_register_tb is
    signal clk    : std_logic := '0';
    signal enable : std_logic := '0';
    signal D      : unsigned(N-1 downto 0) := (others => '0');
    signal Q      : unsigned(N-1 downto 0);
begin

    -- One-liner clock
    clk <= not clk after 5 ns;

    -- Device Under Verification (duv)
    duv : entity work.unsigned_register
        generic map (N => N)
        port map (
            clk    => clk,
            enable => enable,
            D      => D,
            Q      => Q
        );

    -- Stimulus process
    stim_proc : process
        variable number_of_errors : integer := 0;
        variable assert_result     : boolean;
        variable expected          : unsigned(N-1 downto 0);
    begin
        -- Initial conditions
        enable <= '0';
        D <= (others => '0');
        wait until falling_edge(clk);

        -- Test 1: Enable = 1, Load maximum value
        D <= to_unsigned(2**(D'length)-1, N);
        enable <= '1';
        wait until falling_edge(clk); -- Apply at rising edge, check at falling edge
        enable <= '0';
        expected := to_unsigned(2**(D'length)-1, N);
        wait until falling_edge(clk);

        assert_result := (Q = expected);
        if not assert_result then
            number_of_errors := number_of_errors + 1;
        end if;
        assert assert_result
            report "Erro. Valor esperado " & integer'image(to_integer(expected)) & " (" &
                   to_string(expected) & "). Valor obtido " &
                   integer'image(to_integer(Q)) & " (" & to_string(Q) & ")."
            severity error;

        -- Test 2: Enable = 0, change D, output must not change
        D <= (others => '0');
        enable <= '0';
        wait until falling_edge(clk);

        assert_result := (Q = expected); -- Should remain the same
        if not assert_result then
            number_of_errors := number_of_errors + 1;
        end if;
        assert assert_result
            report "Erro. Com enable=0, saída alterada inesperadamente. Valor esperado " &
                   integer'image(to_integer(expected)) & " (" & to_string(expected) &
                   "). Valor obtido " & integer'image(to_integer(Q)) & " (" & to_string(Q) & ")."
            severity error;

        report "message" severity error;
        

        -- Test 3: Enable = 1, load value 0
        D <= to_unsigned(0, N);
        enable <= '1';
        wait until falling_edge(clk);
        enable <= '0';
        expected := to_unsigned(0, N);
        wait until falling_edge(clk);

        assert_result := (Q = expected);
        if not assert_result then
            number_of_errors := number_of_errors + 1;
        end if;
        assert assert_result
            report "Erro. Valor esperado " & integer'image(to_integer(expected)) & " (" &
                   to_string(expected) & "). Valor obtido " &
                   integer'image(to_integer(Q)) & " (" & to_string(Q) & ")."
            severity error;

        -- Final simulation report
        if number_of_errors > 0 then
            report "Foram detectados erros na simulação. Verifique os e corrija os erros listados acima."
                severity failure;
        else
            report "Simulação executada sem erros."
                severity note;
        end if;

        finish; --other method to finish the testbench (only available from VHDL-2008)
    end process;

end behavior;
