--------------------------------------------------
--	Author:      Ismael Seidel (entidade)
--	Created:     May 1, 2025
--
--	Project:     Exercício 6 de INE5406
--	Description: Contém a descrição da entidade `sad_bo`, que representa o
--               bloco operativo (BO) do circuito para cálculo da soma das
--               diferenças absolutas (SAD - Sum of Absolute Differences).
--               Este bloco implementa o *datapath* principal do circuito e
--               realiza operações como subtração, valor absoluto e acumulação
--               dos valores calculados. Além disso, também será feito aqui o
--               calculo de endereçamento e do sinal de controle do laço de
--               execução (menor), que deve ser enviado ao bloco de controle (i.e.,
--               menor será um sinal de status gerado no BO).
--               A parametrização é feita por meio do tipo
--               `datapath_configuration_t` definido no pacote `sad_pack`.
--               Os parâmetros incluem:
--               - `bits_per_sample`: número de bits por amostra; (uso obrigatório)
--               - `samples_per_block`: número total de amostras por bloco; (uso 
--                  opcional, útil para definição do número de bits da sad e 
--                  endereço, conforme feito no top-level, i.e., no arquivo sad.vhdl)
--               - `parallel_samples`: número de amostras processadas em paralelo.
--                  (uso opcional)
--               A arquitetura estrutural instanciará os componentes necessários
--               à implementação completa do bloco operativo.
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sad_pack.all;

-- Bloco Operativo (BO) do circuito SAD.
-- Responsável pelo processamento aritmético dos dados de entrada, incluindo
-- subtração, cálculo de valor absoluto e soma acumulada.
-- Totalmente parametrizável por meio do tipo `datapath_configuration_t`.

entity sad_bo is
    generic(
        bits_per_sample   : positive := 8;
        samples_per_block : positive := 64
    );
    port(
        clk        : in  std_logic;
        rst_a      : in  std_logic;
        commands   : in  std_logic_vector(2 downto 0);
        sample_ori : in  std_logic_vector(bits_per_sample - 1 downto 0);
        sample_can : in  std_logic_vector(bits_per_sample - 1 downto 0);
        sad_result : out std_logic_vector(
                        sad_length(bits_per_sample, samples_per_block)-1 downto 0
                     );
        status     : out std_logic_vector(1 downto 0)
    );
end entity sad_bo;

-- Não altere o nome da entidade! Como você quem irá instanciar, neste caso podes
-- mudar o nome da arquitetura, embora isso não seja necessário. 
-- A arquitetura será estrutural, composta por instâncias de componentes auxiliares.

architecture structure of sad_bo is

    constant ACC_WIDTH : positive := sad_length(bits_per_sample, samples_per_block);

    signal sample_ori_u, sample_can_u : unsigned(bits_per_sample - 1 downto 0);
    signal diff_abs                   : unsigned(bits_per_sample - 1 downto 0);
    signal acc_in, acc_out            : unsigned(ACC_WIDTH - 1 downto 0);
    signal acc_sum                    : unsigned(ACC_WIDTH downto 0); -- corrigido: N+1 bits
    signal acc_clear, acc_enable      : std_logic;
    signal acc_input                  : unsigned(ACC_WIDTH - 1 downto 0);

begin

    sample_ori_u <= unsigned(sample_ori);
    sample_can_u <= unsigned(sample_can);

    acc_clear  <= commands(1); -- clear (início do bloco)
    acc_enable <= commands(0); -- soma (leitura ativa)

    abs_inst : entity work.absolute_difference
        generic map(N => bits_per_sample)
        port map(
            input_a  => sample_ori_u,
            input_b  => sample_can_u,
            abs_diff => diff_abs
        );

    sum_inst : entity work.unsigned_adder
        generic map(N => ACC_WIDTH)
        port map(
            input_a => acc_out,
            input_b => resize(diff_abs, ACC_WIDTH),
            sum     => acc_sum
        );

    acc_input <= (others => '0') when acc_clear = '1' else acc_sum(ACC_WIDTH - 1 downto 0);

    reg_inst : entity work.unsigned_register
        generic map(N => ACC_WIDTH)
        port map(
            clk    => clk,
            enable => acc_clear or acc_enable,
            d      => acc_input,
            q      => acc_out
        );

    sad_result <= std_logic_vector(acc_out);
    status     <= (others => '0');

end architecture structure;
