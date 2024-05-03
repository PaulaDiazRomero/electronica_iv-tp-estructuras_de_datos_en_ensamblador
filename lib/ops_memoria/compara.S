.syntax unified
.cpu cortex-m3
.thumb

.text

/**
 * @brief Compara dos regiones de memoria byte a byte como valores *sin signo*. 
 * Retorna 0 si son iguales, -1 si en la primera diferencia el valor de
 * izquierda es el menor y 1 si en la primera diferencia el valor de la
 * izquierda es mayor
 * 
 * @param izquierda Dirección base de la primera región
 * @param derecha Dirección base de la segunda región
 * @param tamano tamaño de las regiones
 * @return int 
 */

    .type comparaMemoria, %function
    .global comparaMemoria
comparaMemoria:
    push {r4,lr}   // r0 = *i, r1 = *d, r2 = n
    mov r12, #0    // r12 = j, r3 = i[j], r4 = d[j]
0:
    cmp r12, r2
    BGE 3f         // si r12 >= r2, salto a 3
    ldrb r3, [r0, r12]
    ldrb r4, [r1, r12]
    cmp r3, r4
    BNE 1f         // si r3 != r4, salto a 1
    add r12, #1
    B 0b
1:
    cmp r3, r4
    BGT 2f         // si r3 > r4, salto a 2
    mov r0, #-1
    B 4f
2:
    mov r0, #1
    B 4f
3:
    mov r0, #0
4:
    // retorno
    pop {r4,pc}
    .size comparaMemoria, . - comparaMemoria
