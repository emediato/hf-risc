# MIPS Second Counter: 0.0s to 9.9s
# Versão para validação com laço menor
# Usa área de dados com global pointer ($gp) para MARS

.data
    # Endereços de saída usando área apontada pelo $gp
    out_dec_s: .word 0x10008000    # Décimos de segundo
    out_un:    .word 0x10008001    # Unidades de segundo  
    out_dz:    .word 0x10008002    # Dezenas de segundo
    out_ct:    .word 0x10008003    # Centésimos de segundo
    
    # Constante de delay reduzida para validação
    # Valor real seria 2499993, mas usamos menor para teste
    DELAY_COUNT: .word 2499993 #100000      # Valor reduzido para validação
    
    # Mensagens para debug (opcional)
    msg_time: .asciiz "Tempo: "
    msg_dot:  .asciiz "."
    msg_s:    .asciiz "s\n"

.text
.globl debug_main

#main:
    # Passo 1: Reset dos 2 registradores MIPS
    #li $s0, 0           # $s0 = unidades de segundos (0-9)
    #li $s1, 0           # $s1 = décimos de segundos (0-9)
    
main_loop:
    # Passo 2: Escrever os valores nas saídas
    
    # Escrever décimos de segundo
    la $t0, out_dec_s           # obtém o endereço do registrador periférico décimos
    lw $t0, 0($t0)              # carrega o endereço do periférico
    sb $s1, 0($t0)              # escreve valor de décimos ($s1) no periférico
    
    # Escrever unidades de segundo
    la $t0, out_un              # obtém o endereço do registrador periférico unidades
    lw $t0, 0($t0)              # carrega o endereço do periférico
    sb $s0, 0($t0)              # escreve valor de unidades ($s0) no periférico
    
    # escrever zero nas dezenas (sempre 0 para 0.0-9.9s)
    la $t0, out_dz              # obtém o endereço do registrador periférico dezenas
    lw $t0, 0($t0)              # carrega o endereço do periférico
    li $t1, 0                   # valor zero
    sb $t1, 0($t0)              # escreve zero nas dezenas- Write zero to tens place (always 0 since we only count 0.0-9.9)

    
    #  escrever zero nos centésimos  
    la $t0, out_ct              # obtém o endereço do registrador periférico centésimos
    lw $t0, 0($t0)              # carrega o endereço do periférico
    li $t1, 0                   # valor zero
    sb $t1, 0($t0)              # escreve zero nos centésimos
    
    # Verificar condição de parada: se ambos os valores são 9, parar
    li $t9, 9
    bne $s0, $t9, continue_counting    # Se unidades != 9, continuar
    bne $s1, $t9, continue_counting    # Se décimos != 9, continuar
    
    # Ambos são 9, então parar o programa (chegou a 9.9s)
    j program_end
    
continue_counting:
    # chamar função que espera 1 décimo de segundo
    jal delay_tenth_second
    
    # incrementar contagem
    addi $s1, $s1, 1    # Incrementar décimos
    
    # Verificar se décimos chegaram a 10
    li $t9, 10
    bne $s1, $t9, main_loop    # Se décimos < 10, continuar loop principal
    
    # Reset décimos e incrementar unidades
    li $s1, 0           # Reset décimos para 0
    addi $s0, $s0, 1    # Incrementar unidades
    
    # Continuar loop principal
    j main_loop

# Função: delay_tenth_second
# Propósito: Atraso para exatamente 0.1 segundos (versão reduzida para validação)
# Registradores usados: $t0 (contador), $t1 (constante de delay)
delay_tenth_second:
    # Salvar endereço de retorno
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Carregar contagem de delay
    lw $t1, DELAY_COUNT         # Carrega valor reduzido para validação
    move $t0, $t1               # Inicializar contador
    
delay_loop:
    # Loop de delay simples: 2 ciclos por iteração
    addi $t0, $t0, -1           # Decrementar contador (1 ciclo)
    bne $t0, $zero, delay_loop  # Branch se não zero (1 ciclo quando taken)
    
    # Restaurar endereço de retorno e retornar
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

program_end:
    # Programa termina aqui
    # Mensagem final opcional
    li $v0, 4           # Print string
    la $a0, msg_time
    syscall
    
    li $v0, 1           # Print integer
    move $a0, $s0       # Print unidades
    syscall
    
    li $v0, 4           # Print string
    la $a0, msg_dot
    syscall
    
    li $v0, 1           # Print integer
    move $a0, $s1       # Print décimos
    syscall
    
    li $v0, 4           # Print string
    la $a0, msg_s
    syscall
    
    # Chamada de sistema para sair
    li $v0, 10          # Exit system call
    syscall

# Versão alternativa com saída no console para debug
# (Descomente esta seção para testar no MARS com saída visual)

debug_main:
    li $s0, 0           # unidades de segundos
    li $s1, 0           # décimos de segundos
    
debug_loop:
    # Imprimir "Tempo: X.Xs"
    li $v0, 4           # Print string
    la $a0, msg_time
    syscall
    
    li $v0, 1           # Print integer
    move $a0, $s0       # Print unidades
    syscall
    
    li $v0, 4           # Print string
    la $a0, msg_dot
    syscall
    
    li $v0, 1           # Print integer
    move $a0, $s1       # Print décimos
    syscall
    
    li $v0, 4           # Print string
    la $a0, msg_s
    syscall
    
    # Verificar condição de parada
    li $t9, 9
    bne $s0, $t9, debug_continue
    bne $s1, $t9, debug_continue
    j program_end
    
debug_continue:
    # Delay reduzido para visualização
    jal delay_tenth_second
    
    # Incrementar contadores
    addi $s1, $s1, 1
    li $t9, 10
    bne $s1, $t9, debug_loop
    
    li $s1, 0
    addi $s0, $s0, 1
    j debug_loop

# Cálculo do overhead do programa:
# Instruções executadas por iteração do loop principal:
# 1. la $t0, out_dec_s     # 1 ciclo
# 2. lw $t0, 0($t0)        # 1 ciclo  
# 3. sb $s1, 0($t0)        # 1 ciclo
# 4. la $t0, out_un        # 1 ciclo
# 5. lw $t0, 0($t0)        # 1 ciclo
# 6. sb $s0, 0($t0)        # 1 ciclo
# 7. la $t0, out_dz        # 1 ciclo
# 8. lw $t0, 0($t0)        # 1 ciclo
# 9. sb $t1, 0($t0)        # 1 ciclo
# 10. la $t0, out_ct       # 1 ciclo
# 11. lw $t0, 0($t0)       # 1 ciclo
# 12. sb $t1, 0($t0)       # 1 ciclo
# 13. li $t9, 9            # 1 ciclo
# 14. bne $s0, $t9, ...    # 1 ciclo
# 15. bne $s1, $t9, ...    # 1 ciclo
# 16. jal delay_...        # 1 ciclo
# 17. addi $s1, $s1, 1     # 1 ciclo
# 18. li $t9, 10           # 1 ciclo
# 19. bne $s1, $t9, ...    # 1 ciclo
# Total overhead: ~19 ciclos por iteração
# 
# Para compensar, o valor real de DELAY_COUNT seria:
# 2,500,000 - 10 = 2,499,990 (aproximadamente)
