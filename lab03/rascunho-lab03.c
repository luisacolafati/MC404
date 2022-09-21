/* 
TODO: use scanf instead read to test

int read(int __fd, const void *__buf, int __n){
  int bytes;
  __asm__ __volatile__(
    "mv a0, %1           # file descriptor\n"
    "mv a1, %2           # buffer \n"
    "mv a2, %3           # size \n"
    "li a7, 63           # syscall read (63) \n"
    "ecall \n"
    "mv %0, a0"
    : "=r"(bytes)  // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
  return bytes;
}

TODO: use printf instead write to test

void write(int __fd, const void *__buf, int __n){
  __asm__ __volatile__(
    "mv a0, %0           # file descriptor\n"
    "mv a1, %1           # buffer \n"
    "mv a2, %2           # size \n"
    "li a7, 64           # syscall write (64) \n"
    "ecall"
    :   // Output list
    :"r"(__fd), "r"(__buf), "r"(__n)    // Input list
    : "a0", "a1", "a2", "a7"
  );
} */

#include <stdio.h>

bool isHexadecimal (char str[]) {
    // considering that all hexadecimal values init with '0x' prefix, and end with '/n'
    return str[1] == 'x';
}

bool isNegative (char str[]) {
    return str[0] == '-';
}

int convertToPositiveNumber (char str[], int numberOfCaracters) {
    char aux[numberOfCaracters];
    if (isHexadecimal(str)) {
        for (int i = 2; i < numberOfCaracters; i++) {
            aux[i - 2] = str[i];
        }
    } else {
        strcpy(aux, str);
    }
    return atoi(aux);
}

int convertToNegativeNumber (char str[], int numberOfCaracters) {}

int convertToDecimal (int number) {}

int convertDecimalToBinary (int decimalNumber) {
    int dividendo = decimalNumber, quociente, resto, restos[32];

    do {
        quociente = dividendo / 2;
        resto = dividendo % 2;

        restos[] = resto;

        dividendo = quociente;
    } while (quocient >= 2);
}

int main()
{
  char str[20];
  int number;
  bool isHexadecimal, isNegative;
  // 0 = valor padrão que permite o funcionamento da função e a diferencia do write
  // str = valor a ser lido (simulador espera que vc digite alguma coisa)
  // n = número de caracteres lidos de fato (/n também é um caractere, e vai vir sempre no final da linha)
  // 20 = número máximo de caracteres que pode ser lido
  // int n = read(0, str, 20);
  
  // n = número de caracteres a ser imprimido + 1, pois pularemos de linha no final
  // write(1, str, n);
  
  scanf("%s", str); // TODO: use read instead

  isHexadecimal = isHexadecimal(str);
  isNegative = isNegative(str);

  if (isNegative) {
    number = convertToNegativeNumber(str, sizeof(str));
  } else {
    number = convertToPositiveNumber(str, sizeof(str));
    printf("%d", number);
  }

  /* int binaryValue = isHexadecimal ? convertHexadecimalToBinary(number) : convertDecimalToBinary(number);
  printf("0b%d", binaryValue); */

  /* int decimalValue = isHexadecimal ? convertToDecimal(number) : number;
  printf("%d", decimalValue);

  int hexadecimalValue = isHexadecimal ? number : convertToHexadecimal(number);
  printf("%d", decimalValue); */

  return 0;
}
 
/* void _start(){
  main();
} */