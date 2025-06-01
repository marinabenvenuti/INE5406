--------------------------------------------------
--	Author:      Ismael Seidel (entity)
--	Created:     May 1, 2025
--
--	Project:     Exercício 6 de INE5406
--	Description: Contém a descrição da entidade `sad_bc`, que representa o
--               bloco de controle (BC) do circuito para cálculo da soma das
--               diferenças absolutas (SAD - Sum of Absolute Differences).
--               Este bloco é responsável pela geração dos sinais de controle
--               necessários para coordenar o funcionamento do bloco operativo
--               (BO), como enable de registradores, seletores de multiplexadores,
--               sinais de início e término de processamento, etc.
--               A arquitetura é comportamental e deverá descrever uma máquina
--               de estados finitos (FSM) adequada ao controle do datapath.
--               Os sinais adicionais de controle devem ser definidos conforme
--               a necessidade do projeto. PS: já foram definidos nos slides
--               da aula 6T.
--------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.sad_pack.all;

-- Bloco de Controle (BC) do circuito SAD.
-- Responsável por gerar os sinais de controle para o bloco operativo (BO),
-- geralmente por meio de uma FSM.
entity sad_bc is

    generic(
        samples_per_block : positive:= 64;
        parallel_samples : positive:= 1 
        );
        
	port(
		clk         : in std_logic;  -- clock (sinal de relógio)
		rst_a       : in std_logic;  -- reset assíncrono ativo em nível alto
		enable      : in std_logic;
		status      : in std_logic_vector(1 downto 0);
		commands    : out std_logic_vector(2 downto 0);
		read_mem    : out std_logic;
		address     : out std_logic_vector(address_length(samples_per_block, parallel_samples) - 1 downto 0);
		done        : out std_logic
		
	);
end entity;
-- Não altere o nome da entidade nem da arquitetura!

architecture behavior of sad_bc is
    
    constant READ_CYCLES : positive:= integer(
        ceil(real(samples_per_block)/real(parallel_samples))
        );
    constant TOTAL_ITERS : natural:= READ_CYCLES + 1;
    constant TOTAL_CYCLES : natural:= 3 * TOTAL_ITERS;
    
    signal cycle_cnt        :integer range 0 to TOTAL_CYCLES:= 0;
    signal running          :std_logic:='0';
    signal addr_reg         :unsigned(address_length(samples_per_block, parallel_samples) - 1 downto 0) := (others => '0');
    signal read_reg         :std_logic:= '0';
    signal block_start_reg  :std_logic:= '0';
    
    signal next_cnt         :integer range 0 to TOTAL_CYCLES;
    signal next_running     :std_logic;
    signal next_addr        :unsigned(addr_reg'range);
    signal next_read        :std_logic;
    signal next_start       :std_logic;
    
begin
    -- Preencher aqui (remova este comentário).
    -- Descreva a FSM responsável por coordenar o circuito SAD.
    
    -- Dica: separar em 3 processos:
    -- 1) carga e reset do registrador de estado;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if rst_a = '1' then
                running         <= '0';
                cycle_cnt       <= 0;
                addr_reg        <= (others => '0');
                read_reg        <= '0';
                block_start_reg <= '0';
            else
                running         <= next_running;
                cycle_cnt       <= next_cnt;
                addr_reg        <= next_addr;
                read_reg        <= next_read;
                block_start_reg <= next_start;
            end if;
        end if;
    end process;
    
    -- 2) LPE;
    
    process(running, enable, cycle_cnt)
    begin
        if running = '0' then
            next_running <= enable;
            next_cnt <= 0;
        else
            next_running <= running;
            if cycle_cnt < TOTAL_CYCLES then
                next_cnt <= cycle_cnt + 1;
            else
                next_cnt <=0;
            end if;
        end if;
    end process;
    
    -- 3) LS.
    
    process(cycle_cnt)
    begin
        next_addr <= (others => '0');
        next_read <= '0';
        next_start <= '0';
        
        if(cycle_cnt mod 3) = 1 and ((cycle_cnt + 2)/ 3) <= READ_CYCLES then
            next_addr <= to_unsigned((cycle_cnt - 1)/3, addr_reg'length);
            next_read <= '1';
        end if;
        
        if cycle_cnt = 0 then
            next_start <= '1';
        end if;
    end process;
    
    read_mem <= read_reg;
    address <= std_logic_vector(addr_reg);
    
    commands <= "010" when block_start_reg = '1' else
                "001" when read_reg = '1' else
                "000";
                
    done <= '1' when (running = '0') or (cycle_cnt = TOTAL_CYCLES) else '0';
    
end architecture;