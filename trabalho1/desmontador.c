#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
//-----------------------------------------------------------

#define MAX_FILE_SIZE_IN_BYTES 10000
#define EXIT_PROGRAM_CODE -1
#define SECTION_SIZE_IN_BYTES 40
#define SECTION_PROPERTIES_SIZE_IN_BYTES 4
#define START_OFFSET_OF_NAMES_IN_SECTION_SHSTRNDX 16
#define MAX_SECTION_NAME_SIZE 10
#define BYTE_SIZE 8

//-----------------------------------------------------------

typedef struct {
    char printSectionTable;
    char printSymbolTable;
    char printTextSection;
} CommandFlags;

CommandFlags FLAGS;

void initializeCommandFlags() {
    FLAGS.printSectionTable = 'h';
    FLAGS.printSymbolTable = 't';
    FLAGS.printTextSection = 'd';
};

//-----------------------------------------------------------

typedef struct {
    int offset;
    int size;
    int decimalValue;
    char *hexadecimalValue;
} HeaderProperties;

typedef struct {
    HeaderProperties e_shoff;
    HeaderProperties e_shnum;
    HeaderProperties e_shstrndx;
} FileHeaders;

FileHeaders FILE_HEADERS;

//-----------------------------------------------------------

typedef struct {
    HeaderProperties sh_name;
    HeaderProperties sh_size;
    HeaderProperties sh_addr;
} SectionHeaders;

SectionHeaders SECTION_HEADERS;

typedef struct {
    int index;
    char *name;
    char *size;
    char *vma;
} Section;

//-----------------------------------------------------------

int exponential(int base, int exponent) {
    if (exponent == 0)
        return 1;
    else
        return base * exponential(base, --exponent);
}

int convertMultipleBytesToDecimal (unsigned char *bytes, int size) {
    int exponent = 0, decimalValue = 0;
    for (int i = size - 1; i >= 0; i--) {
        decimalValue += bytes[i] * exponential(2, exponent);
        exponent += 8;
    }
    return decimalValue;
}

int getDecimalValueOfFileHeaderProperty (unsigned char *fileContent, HeaderProperties hp) {
    unsigned char headerProperty[hp.size];
    int initOffset = hp.offset,
            endOffset = initOffset + hp.size - 1,
            index = 0;

    for (int i = endOffset; i >= initOffset; i--) {
        headerProperty[index++] = fileContent[i];
    }

    return convertMultipleBytesToDecimal(headerProperty, hp.size);
}

char convertIntToNumericCharacter(int num) {
    return (char)(num + '0');
}

char convertIntToAlfabeticCharacter(int num) {
    return (char)(num + 'a');
}

void convertDecimalToHexadecimal (int decimal, char *hexadecimal) {
    char invertedHexNumber[BYTE_SIZE];
    int counter = 0, rest;

    do {
        rest = decimal % 16;
        invertedHexNumber[counter] = rest < 10 ? convertIntToNumericCharacter(rest) : convertIntToAlfabeticCharacter(rest - 10);
        decimal = decimal / 16;
        counter++;
    } while(decimal != 0);

    for (int i = counter; i < BYTE_SIZE; i++) {
        invertedHexNumber[i] = '0';
    }

    for (int j = 0; j < BYTE_SIZE; j++) {
        hexadecimal[BYTE_SIZE - (j + 1)] = invertedHexNumber[j];
    }
    hexadecimal[BYTE_SIZE] = '\0';
}

//-----------------------------------------------------------

char *readBytesFromFile(unsigned char *fileContent, char *arr, int init, int size) {
    char auxArr[SECTION_PROPERTIES_SIZE_IN_BYTES];
    int end = init + size - 1, index = 0;
    for (int i = end; i >= init; i--) {
        arr[index] = fileContent[i];
        index++;
    }
    arr[index] = '\0';
}

//----------------------------------------------------------

int getShstrtabSectionInit (unsigned char *fileContent) {
    int sectionIndex = FILE_HEADERS.e_shstrndx.decimalValue,
        sectionInit = FILE_HEADERS.e_shoff.decimalValue + sectionIndex * SECTION_SIZE_IN_BYTES,
        initOffset = sectionInit + START_OFFSET_OF_NAMES_IN_SECTION_SHSTRNDX;

    char offset[SECTION_PROPERTIES_SIZE_IN_BYTES];
    readBytesFromFile(fileContent, offset, initOffset, SECTION_PROPERTIES_SIZE_IN_BYTES);

    return convertMultipleBytesToDecimal(offset, SECTION_PROPERTIES_SIZE_IN_BYTES);
}

int getNameOffset(unsigned char *fileContent, int sectionInit) {
    char offset[SECTION_PROPERTIES_SIZE_IN_BYTES];
    readBytesFromFile(fileContent, offset, sectionInit, SECTION_PROPERTIES_SIZE_IN_BYTES);

    return convertMultipleBytesToDecimal(offset, SECTION_PROPERTIES_SIZE_IN_BYTES);
}

void getSectionName (unsigned char *fileContent, int sectionInit, char *name) {
    int nameOffset = getNameOffset(fileContent, sectionInit);
    int nameInit = SECTION_HEADERS.sh_name.offset + nameOffset;

    int index = 0;
    while((int)fileContent[nameInit + index] != 0) {
        name[index] = fileContent[nameInit + index];
        index++;
    }
    name[index] = '\0';
}

void getSectionHeaderProperty (unsigned char *fileContent, int sectionInit, char *property, HeaderProperties hp) {
    unsigned char binaryValue[hp.size];
    int init = sectionInit + hp.offset,
        end = init + hp.size - 1,
        index = 0;

    for (int i = end; i >= init; i--) {
        binaryValue[index] = fileContent[i];
        index++;
    }

    hp.decimalValue = convertMultipleBytesToDecimal(binaryValue, hp.size);
    convertDecimalToHexadecimal(hp.decimalValue, property);
}

//-----------------------------------------------------------

void initializeFileHeaders(unsigned char *fileContent) {
    FILE_HEADERS.e_shoff.offset = 32;
    FILE_HEADERS.e_shoff.size = 4;
    FILE_HEADERS.e_shoff.decimalValue = getDecimalValueOfFileHeaderProperty(fileContent, FILE_HEADERS.e_shoff);

    FILE_HEADERS.e_shnum.offset = 48;
    FILE_HEADERS.e_shnum.size = 2;
    FILE_HEADERS.e_shnum.decimalValue = getDecimalValueOfFileHeaderProperty(fileContent, FILE_HEADERS.e_shnum);

    FILE_HEADERS.e_shstrndx.offset = 50;
    FILE_HEADERS.e_shstrndx.size = 2;
    FILE_HEADERS.e_shstrndx.decimalValue = getDecimalValueOfFileHeaderProperty(fileContent, FILE_HEADERS.e_shstrndx);
}

void initializeSectionHeaders(unsigned char *fileContent) {
    SECTION_HEADERS.sh_name.offset = getShstrtabSectionInit(fileContent);

    SECTION_HEADERS.sh_addr.offset = 12;
    SECTION_HEADERS.sh_addr.size = 4;

    SECTION_HEADERS.sh_size.offset = 20;
    SECTION_HEADERS.sh_size.size = 4;
}

//-----------------------------------------------------------

Section getSection (unsigned char *fileContent, int sectionInit, int sectionIndex) {
    Section s;
    char name[MAX_SECTION_NAME_SIZE], vma[BYTE_SIZE + 1], size[BYTE_SIZE + 1];

    getSectionName(fileContent, sectionInit, &name);
    getSectionHeaderProperty(fileContent, sectionInit, &size, SECTION_HEADERS.sh_size);
    getSectionHeaderProperty(fileContent, sectionInit, &vma, SECTION_HEADERS.sh_addr);

    s.index = sectionIndex;
    s.name = name;
    s.size = size;
    s.vma = vma;

    return s;
}

Section *printSectionTable (unsigned char *fileContent) {
    int numberOfSections = FILE_HEADERS.e_shnum.decimalValue,
        sectionInit = FILE_HEADERS.e_shoff.decimalValue;
    Section section;

    printf("\nSections:");
    printf("\nIdx\tName\tSize\tVMA");

    for (int i = 0; i < numberOfSections; i++) {
        section = getSection(fileContent, sectionInit, i);
        printf("\n%d\t%s\t%s\t%s", section.index, section.name, section.size, section.vma);
        sectionInit += SECTION_SIZE_IN_BYTES;
    }
}

//-----------------------------------------------------------

char removeTraceFromFlag(char *flag) {
    return flag[0] == '-' ?  flag[1] : flag[0];
}

void executeDecodification (unsigned char *fileContent, char *flagWithTracePrefix) {
    char flag = removeTraceFromFlag(flagWithTracePrefix);

    if (flag == FLAGS.printSectionTable) {
        printSectionTable(fileContent);
    }

    else if (flag == FLAGS.printSymbolTable) {
        //TODO: implement getSymbolTable()
    }

    else if (flag == FLAGS.printTextSection) {
        // TODO: implement getTextSection()
    }
}

//-----------------------------------------------------------
int main(int argc, char *argv[]) {
    initializeCommandFlags();

    // char *executionOption = argv[1];
    char *flag = "-h";
    // char *fileName = argv[2];
    char *fileName = "../bin/test-00.x";
    unsigned char fileContent[MAX_FILE_SIZE_IN_BYTES];

    int file = open(fileName, O_RDONLY);
    if (file == EXIT_PROGRAM_CODE) {
        return -1;
    }
    read(file, fileContent, MAX_FILE_SIZE_IN_BYTES);

    initializeFileHeaders(fileContent);
    initializeSectionHeaders(fileContent);

    executeDecodification(fileContent, flag);

    close(file);

    return 0;
}