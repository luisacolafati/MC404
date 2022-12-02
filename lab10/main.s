.text
.globl user_main
user_main:
  jal logica_controle
loop_infinito: 
  j loop_infinito