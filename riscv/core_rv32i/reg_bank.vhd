library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reg_bank is
	port (	clock:		in std_logic; -- clock
		read_reg1:	in std_logic_vector(4 downto 0); -- RS1
		read_reg2:	in std_logic_vector(4 downto 0);  -- RS1
		write_reg:	in std_logic_vector(4 downto 0); -- WRITE REG
		wreg:		in std_logic; -- Reg write : se for = 1, é quando é para escrever
		write_data:	in std_logic_vector(31 downto 0);
		read_data1:	out std_logic_vector(31 downto 0);
		read_data2:	out std_logic_vector(31 downto 0)
	);
end reg_bank;

architecture arch_reg_bank of reg_bank is
	type bank is array(0 to 31) of std_logic_vector(31 downto 0); -- arquitetura de 32 bits. array com 32 posicoes, e cada posicao tem 32 bits, entao cada um tem 32 bits
	signal registers: bank := (others => (others => '0')); -- nosso banco de registradores é um array
begin
	process(clock, write_reg, wreg, write_data, read_reg1, read_reg2, registers) -- SEMPRE QUE TIVER MUDANÇA NESSE SINAIS, O PROCESS VAI SER EXECUTADO
	-- CADA VEZ QUE ACONTECER O WREG, NOVO ENDERECO DE REGISTRADOR, process vai ser executado
	
	begin
		if clock'event and clock = '1' then
			if write_reg /= "00000" and wreg = '1' then
				registers(conv_integer(write_reg)) <= write_data;
			end if;
		end if;
		-- A condição verifica duas coisas simultaneamente:
			-- write_reg /= "00000" - Verifica se o endereço do registrador de destino não é o registrador 0
			-- O registrador 0 geralmente é hardwired para sempre conter o valor zero (por isso evita-se escrever nele)
			-- UNIDADE DE CONTROLE =1 wreg = '1' - Verifica se o sinal de controle de escrita está ativo
				-- Se ambas as condições forem verdadeiras:
					-- A função conv_integer() converte o valor binário de write_reg para um número inteiro que é usado como índice do array registers.
					-- registers(conv_integer(write_reg)) <= write_data; - O valor em write_data é escrito no registrador especificado por write_reg
	end process;

	-- SEMPRE 0 : others=>0
	read_data1 <= registers(conv_integer(read_reg1)) when read_reg1 /= "00000" else (others => '0');
	read_data2 <= registers(conv_integer(read_reg2)) when read_reg2 /= "00000" else (others => '0');
			
end arch_reg_bank;

