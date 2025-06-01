--------------------------------------------------
--	Author:      Ismael Seidel (entity)
--	Created:     May 1, 2025
--
--	Project:     Exercício 6 de INE5406
--	Description: Contém a descrição da entidade sad (que é o top-level). Tal
--               Entidade calcula a Soma das Diferenças Absolutas (SAD) entre
--               duas matrizes (blocos) de amostras, chamadas de bloco original
--               e bloco candidato. Ambos os blocos estão armazenados em memórias 
--               externas: o bloco original está em uma memória chamada de Mem_A
--               e o bloco candidato está em uma memória chamada de Mem_B. As
--               memórias são lidas de maneira assíncrona, através de um sinal
--               de endereço (address) e um sinal que habilita a leitura (read_mem).
--               O valor lido de Mem_A fica disponível na entrada sample_ori, 
--               enquanto que o valor lido de Mem_B fica fisponível na entrada
--               sample_can. O número de bits de cada amostra é parametrizado
--               através do generic bits_per_sample, que tem valor padrão 8. Os
--               valores de cada amostra são números inteiros sem sinal. Além 
--               disso, o número total de amostras por bloco também é parametrizável
--               através do generic samples_per_block. Porém, neste exercício você
--               pode assumir que esse valor não será modificado e será sempre 64.
--               Com 64 amostras em um bloco, podemos assumir que nossa arquitetura
--               será capaz de calcular a SAD entre dois blocos com tamanho 8x8 (cada).
--               Outro parâmetro da entidade é parallel_samples, que define o número
--               de amostras que serão processadas em paralelo. Neste exercício
--               podemos assumir também que esse valor não será modificado, e o 
--               valor padrão será adotado (ou seja, apenas 1 amostra de cada 
--               bloco será lida da memória por vez). Ainda que não sejam obrigatórios,
--               os generics samples_per_block e parallel_samples devem ser mantidos
--               na descrição da entidade. 
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.sad_pack.all;

entity sad is
    generic(
        -- obrigatório ---
        -- defina as operações considerando o número de bits por amostra
        bits_per_sample   : positive := 8;
        -----------------------------------------------------------------------
        -- desejado (i.e., não obrigatório) ---
        -- se você desejar, pode usar os valores abaixo para descrever uma
        -- entidade que funcione tanto para a SAD v1 quanto para a SAD v3.
        samples_per_block : positive := 64;
        parallel_samples  : positive := 1
    );
    port(
        -- Não modifiquem os nomes das portas e nem mesmo a largura de bits.
        -- Procurem entender as funções address_length e sad_length que são usadas
        -- para a definição do número de bits de endereço (address) e do resultado
        -- final da sad (sad_value).
        -- Note que não podemos usar o nome sad para a saída do valor da SAD, pois
        -- este é o nome de nossa entidade.
        clk        : in  std_logic;
        rst_a      : in  std_logic;
        enable     : in  std_logic;
        sample_ori : in  std_logic_vector(bits_per_sample * parallel_samples - 1 downto 0);
        sample_can : in  std_logic_vector(bits_per_sample * parallel_samples - 1 downto 0);
        read_mem   : out std_logic;
        address    : out std_logic_vector(
                        address_length(samples_per_block, parallel_samples) - 1 downto 0
                     );
        sad_value  : out std_logic_vector(
                        sad_length(bits_per_sample, samples_per_block) - 1 downto 0
                     );
        done       : out std_logic
    );
end entity sad;

architecture structure of sad is

    type command_t is record
        exec, clear : std_logic;
    end record;


    signal command_signals : std_logic_vector(2 downto 0);
    signal status_signals  : std_logic_vector(1 downto 0); 

begin

    BC_inst : entity work.sad_bc
        generic map(
            samples_per_block => samples_per_block,
            parallel_samples  => parallel_samples
        )
        port map(
            clk      => clk,
            rst_a    => rst_a,
            enable   => enable,
            status   => status_signals,
            commands => command_signals,
            read_mem => read_mem,
            address  => address,
            done     => done
        );

    BO_inst : entity work.sad_bo
        generic map(
            bits_per_sample   => bits_per_sample,
            samples_per_block => samples_per_block
        )
        port map(
            clk        => clk,
            rst_a      => rst_a,
            commands   => command_signals,
            sample_ori => sample_ori,
            sample_can => sample_can,
            sad_result => sad_value,
            status     => status_signals
        );

end architecture structure;
