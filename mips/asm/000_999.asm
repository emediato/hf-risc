.data
    # Memory-mapped peripheral addresses (using $gp in MARS)
    out_dec_s: .word 0x10008000  # Tenths of seconds register
    out_un:    .word 0x10008001  # Units of seconds register
    out_dz:    .word 0x10008002    # Dezenas de segundo
    out_ct:    .word 0x10008003    # Centésimos de segundo
    
    DELAY_COUNT: .word  100000 
.text
.globl main

main:
    # Initialize using global pointer ($gp)
    # load immediate
    li $s0, 0          # $s0 = 0 decimos segundos  (0-9)
    li $s1, 0          # $s1 = 0 unidades de segundos counter (0-9)
    li $s2, 0          # $s1 = 0 dezenas de segundos counter (0-9)
    li $s3, 0          # $s1 = 0 centesimos de segundos counter (0-9)
    
    li $t9, 4999        # reduced loop count for validation (1/1000 of real value)
    # li $t9, 4999       # reduced loop count for validation (1/1000 of real value)
    # li $t9, 2499992    # Real-time value at 50MHz
	# 100000	
	# Usar registradores temporários para cálculos de endereço

main_loop:
    # **** WRITE tenths ($s0) décimos de segundo
    # Step 1: Write to peripheral (using $gp-relative addressing)
    la $t0, out_dec_s   # load address of pointer, $t0 = load address out_dec_s, obtém o endereço do registrador periférico décimos
    lw $t1, 0($t0)      # Get actual peripheral address $t1 = mem[$t0 + 0] = carrega o endereço do periférico
    sb $s0, 0($t1)      # Store tenths escreve valor de décimos ($s1) no periférico

    # **** WRITE units ($s1) ===
    la $t0, out_un      # Load address of pointer  obtém o endereço do registrador periférico unidades
    lw $t1, 0($t0)      # Get actual peripheral address
    sb $s1, 0($t1)      # Store units - escreve valor de unidades ($s0) no periférico
    
    # **** dezenas  
    la $t0, out_dz              # obtém o endereço do registrador periférico dezenas
    lw $t0, 0($t0)              # carrega o endereço do periférico
    sb $s2, 0($t0)              # Store dezenas 
    
    #  ****  centésimos  
    la $t0, out_ct              # obtém o endereço do registrador periférico centésimos
    lw $t0, 0($t0)              # carrega o endereço do periférico
    sb $s3, 0($t0)              # Store  nos centésimos
    
    li $t9, 9
    bne $s0, $t9, continue_counting   # Se unidades != 9, continuar
    bne $s1, $t9, continue_counting 
    # bne $s2, $t9, continue_counting
    # bne $s3, $t9, continue_counting
    
    j end_program


continue_counting:
    # chamar função que espera 1 décimo de segundo
    jal delay_tenth_second
    
    # incrementar contagem
    addi $s2, $s2, 1    # Incrementar dezenas
    
    # Verificar se décimos chegaram a 10
    li $t9, 10
    bne $s2, $t9, main_loop    # Se décimos < 10, continuar loop principal
    
    # Reset dezenas e incrementar decimos
    li $s2, 0           # Reset décimos para 0
    # ********************
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

# Propósito: Atraso para exatamente 0.1 segundos (versão reduzida para validação)
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

    
delay_continue_counting:
    addi $t1, $t1, 1
    bne $t1, $t9, delay_continue_counting

    #  Increment counters
    addi $s0, $s0, 1    # Tenths++

    # Check for rollover
    li $t0, 10
    bne $s0, $t0, main_loop

    # Tenths rolled over
    li $s0, 0
    addi $s1, $s1, 1
    j main_loop


end_program:
    # Display final value forever
    la $t0, out_dec_s
    lw $t1, 0($t0)
    sb $s0, 0($t1)

    la $t0, out_un
    lw $t1, 0($t0)
    sb $s1, 0($t1)

    la $t0, out_dz
    lw $t1, 0($t0)
    sb $s2, 0($t1)

    la $t0, out_ct
    lw $t1, 0($t0)
    sb $s3, 0($t1)

    j end_program



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
