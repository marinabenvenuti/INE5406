# Atividade Prática 2

O circuito implementa o cálculo da Soma das Diferenças Absolutas (SAD - Sum of Absolute Differences), uma operação comum em processamento de imagens e vídeo, especialmente em algoritmos de correspondência de blocos. Ele calcula a diferença absoluta entre dois conjuntos de amostras (original e candidato) e acumula essas diferenças para produzir uma medida de similaridade entre os blocos.

## Dupla X

- Yano de Melo Cavalcante (Matrícula 23103135)
- Marina Benvenuti Cardeal (Matrícula 23103131)

## Descrição

O sistema é dividido em dois componentes principais:

1. Bloco de Controle (sad_bc): Gerencia a máquina de estados e coordena as operações

2. Bloco Operativo (sad_bo): Realiza os cálculos aritméticos

```
entity sad is
    generic(
        bits_per_sample   : positive := 8;
        samples_per_block : positive := 64;
        parallel_samples  : positive := 1
    );
    port(
        clk        : in  std_logic;
        rst_a      : in  std_logic;
        enable     : in  std_logic;
        sample_ori : in  std_logic_vector(bits_per_sample * parallel_samples - 1 downto 0);
        sample_can : in  std_logic_vector(bits_per_sample * parallel_samples - 1 downto 0);
        read_mem   : out std_logic;
        address    : out std_logic_vector;
        sad_value  : out std_logic_vector;
        done       : out std_logic
    );
end entity sad;
```

O fluxo de operação funciona da seguinte forma:
1. Quando habilitado (enable = '1'), o bloco de controle inicia a leitura das amostras;
2. Para cada par de amostras (original e candidata), calcula a diferença absoluta;
3. Acumula essas diferenças em um registrador;
4. Quando todas as amostras do bloco são processadas, sinaliza conclusão (done = '1') e disponibiliza o resultado.

### Características importantes: 
* Parametrizável: Pode ser configurado para diferentes tamanhos de amostra e blocos;
* Pipeline: Opera em estágios controlados por clock;
* Sinalização clara: Indica quando a operação está concluída.

#### Simulação

A implementação do circuito SAD foi verificada através de simulação utilizando a ferramenta GHDL para compilação e execução, e GTKWave para visualização dos sinais. Esta abordagem permitiu uma análise detalhada do comportamento temporal do circuito. A simulação comprovou o correto funcionamento do circuito, com o cálculo preciso das diferenças absolutas e a acumulação correta dos valores.

![gtkwave](https://github.com/user-attachments/assets/059c255e-6c4a-4120-95fd-5c9c2dc810ac)

A imagem acima mostra alguns dos principais sinais do circuito durante a operação:
* clk e rst_a sincronizando as operações;
* sample_ori e sample_can com os valores de entrada
* sad_result mostrando o resultado acumulado
* address e next_add incrementando corretamente o endereço de memória durante a leitura
