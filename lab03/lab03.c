#include <stdio.h>
#define STRING_MAX_LENGTH 20
#define PREFIX_LENGTH 2
//-------------------------------------ASCII FUNCTIONS-------------------------------------------
int convertNumericCharacterToInt(char c) {
    return (int)(c - '0');
}

int convertAlfabeticCharacterToInt(char c) {
    return (int)(c - 'A');
}

char convertIntToNumericCharacter(int num) {
    return (char)(num + '0');
}

char convertIntToAlfabeticCharacter(int num) {
    return (char)(num + 'A');
}
//-------------------------------------STRUCTS/ENUMS---------------------------------------------
typedef struct {
    char character;
    int  decimalValue;
} HexadecimalNumber;

HexadecimalNumber HEX_NUMBERS[16];

void initializeHexadecimalNumbersDictionary() {
    for (int i = 0; i < 16; i++) {
        HEX_NUMBERS[i].character = i < 10 ? convertIntToNumericCharacter(i) : convertIntToAlfabeticCharacter(i - 10);
        HEX_NUMBERS[i].decimalValue = i;
    }
}
//-------------------------------------MATH FUNCTION-------------------------------------------
int exponential(int base, int exponent) {
    if (exponent == 0)
        return 1;
    else
        return base * exponential(base, --exponent);
}
//-------------------------------------INT FUNCTIONS-------------------------------------------
char *convertIntToString(int num, int isBinary, int isHexadecimal, int isNegative) {
    int numberOfdigits = 0, invertedDigits[100], digits[100], digit, prefixLength;
    char str[100];

    //getting inverted digits of number
    do {
        digit = num % 10;
        invertedDigits[numberOfdigits++] = digit;
        num /= 10;
    } while (num != 0);
    //inverting digits read of number
    for (int i = 0; i < numberOfdigits; i++) {
        digits[i] = invertedDigits[numberOfdigits - (i + 1)];
    }
    //adding prefix, if necessary
    if (isHexadecimal == 1) {
        str[0] = '0';
        str[1] = 'x';
        prefixLength += 2;
    }
    if (isBinary == 1) {
        str[0] = '0';
        str[1] = 'b';
        prefixLength += 2;
    }
    if (isNegative == 1) {
        str[prefixLength] = '-';
        prefixLength += 1;
    }
    //converting digits to character
    for (int i = 0; i < numberOfdigits; i++) {
        str[i + prefixLength] = convertIntToNumericCharacter(digits[i]);
    }

    return str;
}
//-----------------------------------STRING/CHAR FUNCTIONS--------------------------------------
int convertCharacterToInt(char c) {
    for (int i = 0; i < 16; i++) {
        if (HEX_NUMBERS[i].character == c) {
            return HEX_NUMBERS[i].decimalValue;
        }
    }
    return -1;
}

int convertStringToInt(char str[], int length) {
    int decimal = 0;
    for (int i = 1; i <= length; i++) {
        decimal += convertCharacterToInt(str[i - 1]) * exponential(10, length - i);
    }
    return decimal;
}

int representsHexadecimalNumber(char str[]) {
    return (str[1] == 'x') ? 1 : 0;
}

int representsNegativeNumber(char str[]) {
    return (str[0] == '-') ? 1 : 0;
}

char *removeNumericBasePrefix(char str[]) {
    return str + PREFIX_LENGTH;
}
//-----------------------------------------DECIMAL_FUNCTIONS-----------------------------------------
char *convertDecimalToHexadecimal(char str[], int length) {
    int decimal = convertStringToInt(str, length), counter = 0, rest;
    char invertedHexNumber[STRING_MAX_LENGTH], hexNumber[STRING_MAX_LENGTH];

    do {
        rest = decimal % 16;
        invertedHexNumber[counter] = rest < 10 ? convertIntToNumericCharacter(rest) : convertIntToAlfabeticCharacter(rest - 10);
        decimal = decimal / 16;
        counter++;
    } while(decimal != 0);

    for (int j = 0; j < counter; j++) {
        hexNumber[counter - (j + 1)] = invertedHexNumber[j];
    }
    
    return hexNumber;
}

int convertDecimalToBinary(int num) {
    if (num == 0) 
        return 0;
    else
        return ((num % 2) + 10 * convertDecimalToBinary(num / 2));
}
//-------------------------------------HEXADECIMAL FUNCTIONS--------------------------------------
int convertHexadecimalToDecimal(char hex[], int length) {
    char* hexWithoutPrefix = removeNumericBasePrefix(hex);
    int newLength = length - PREFIX_LENGTH;

    int decimal = 0;
    for (int i = 1; i <= newLength; i++) {
        decimal += convertCharacterToInt(hexWithoutPrefix[i - 1]) * exponential(16, newLength - i);
    }
    
    return decimal;
}

int convertHexaconvertDecimalToBinary(char hex[], int length) {
    int decimal = convertHexadecimalToDecimal(hex, length);
    int binary = convertDecimalToBinary(decimal);
    
    return binary;
}
//----------------------------------------------------------------
char *toBinary(char str[], int length, int isHexadecimal, int isNegative) {
    int binary;
    
    if (isHexadecimal == 1) {
        binary = convertHexaconvertDecimalToBinary(str, length);
    } else if (isNegative == 1) {
        binary = convertDecimalToBinary(convertStringToInt(str, length));
    } else {
        binary = convertDecimalToBinary(convertStringToInt(str, length));
    }

    return convertIntToString(binary, 1, 0, isNegative);
}

char *toDecimal(char str[], int length, int isHexadecimal, int isNegative) {
    int decimal = isHexadecimal == 1 ? convertHexadecimalToDecimal(str, length) : convertStringToInt(str, length);
    
    return convertIntToString(decimal, 0, 0, isNegative);
}

char *toHexadecimal(char str[], int length, int isHexadecimal, int isNegative) {
    char hex = isHexadecimal == 1 ? removeNumericBasePrefix(str) : convertDecimalToHexadecimal(str, length);
    // TODO: add 0x prefix in hex variable
}
//----------------------------------------------------------------
int main()
{
    initializeHexadecimalNumbersDictionary();

    char str[STRING_MAX_LENGTH], *binary, *decimal, *hexadecimal;
    scanf("%s", str);

    int length = 1;

    int isNegative = representsNegativeNumber(str);
    int isHexadecimal = representsHexadecimalNumber(str);

    binary = toBinary(str, length, isHexadecimal, isNegative);

    decimal = toDecimal(str, length, isHexadecimal, isNegative);

    hexadecimal = toHexadecimal(str, length, isHexadecimal, isNegative);

    return 0;
}