library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu is
	port (	op1:		in std_logic_vector(31 downto 0);
		op2:		in std_logic_vector(31 downto 0);
		alu_op:		in std_logic_vector(3 downto 0);
		result:		out std_logic_vector(31 downto 0);
		zero:		out std_logic; -- coloca 1 quando a operacao resultante for 0, usado no BRANCH EQUAL
		less_than:	out std_logic -- quando a entrada A for menor que a B, usada no BRANCH LESS THAN
	     );
end alu;

architecture arch_alu of alu is
	signal r, shift: std_logic_vector(31 downto 0);
	signal shift_op2: std_logic_vector(4 downto 0);
	signal addsub: std_logic_vector(32 downto 0); 
	-- bit de sinal fica no bit 31
	-- bit 33 :
	signal less, left, logical: std_logic;
begin
	process(op1, op2, alu_op, addsub, less, shift_op2, shift)
	begin
		case alu_op is
			-- valores vem do tipo de operacao que vai realizar
			when "0000" => r <= op1 and op2; -- AND
			when "0001" => r <= op1 or op2; -- OR
			when "0010" => r <= op1 xor op2; -- XOR
			when "0100" | "0101" => r <= addsub(31 downto 0); -- ADD/SUB - Adição ("0100") ou Subtração ("0101")
			when "0110" => r <= op2; -- passa direto 			-- LOAD IMEDIATO, pega valor do registrador e joga na ALU , o dado está na p isntrucao
			--  MOV/LUI - Move valor ou carrega imediato na parte superior (Load Upper Immediate)
			when "0111" | "1000" => r <= x"0000000" & "000" & less; -- "0111" / "1000"r <= x"0000000" & "000" & less
			-- SLT/SLTU - Set Less Than (comparações com ou sem sinal)other
			-- rsr <= shift
			when others => r <= shift;
			-- SLL/SRL/SRA - Deslocamentos lógicos à esquerda/direita ou aritmético à direi

		end case;
	end process;

	addsub <= ('0' & op1) - ('0' & op2) when alu_op > "0100" else ('0' & op1) + ('0' & op2);
	
	less <= addsub(32) when op1(31) = op2(31) or alu_op = "1000" else op1(31); 
			-- verifica se os dois bits sao iguais, se forem 0s ou 1s 
			-- 
			
	less_than <= less;
	zero <= not (r(31) or r(30) or r(29) or r(28) or r(27) or r(26) or r(25) or r(24) or
			r(23) or r(22) or r(21) or r(20) or r(19) or r(18) or r(17) or r(16) or
			r(15) or r(14) or r(13) or r(12) or r(11) or r(10) or r(9) or r(8) or
			r(7) or r(6) or r(5) or r(4) or r(3) or r(2) or r(1) or r(0));

	shift_op2 <= op2(4 downto 0);

	left <= '1' when alu_op(0) = '1' else '0';
	logical <= '1' when alu_op(2) = '0' else '0';

	barrel_shifter: entity work.bshift
	port map(	left => left,
			logical => logical,
			shift => shift_op2,
			input => op1,
			output => shift
	);

	result <= r;

end arch_alu;

