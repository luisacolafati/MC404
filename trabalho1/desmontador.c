#include <fcntl.h>
#include <unistd.h>
//-----------------------------------------------------------

#define STDOUT_FILENO 1
#define MAX_FILE_SIZE_IN_BYTES 10000
#define BYTE_SIZE 8
#define EXIT_PROGRAM_CODE -1
#define SECTION_SIZE_IN_BYTES 40
#define SECTION_PROPERTIES_SIZE_IN_BYTES 4
#define START_OFFSET_OF_NAMES_IN_SECTION_SHSTRNDX 16
#define MAX_STRING_SIZE 20
#define INSTRUCTION_SIZE_IN_BYTES 4

//-----------------------------------------------------------

typedef struct {
    char printSectionTable;
    char printSymbolTable;
    char disassemblyTextSection;
} CommandFlags;

CommandFlags FLAGS;

void initializeCommandFlags() {
    FLAGS.printSectionTable = 'h';
    FLAGS.printSymbolTable = 't';
    FLAGS.disassemblyTextSection = 'd';
};

//-----------------------------------------------------------

typedef struct {
    int offset;
    int size;
    int decimalValue;
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
    HeaderProperties sh_offset;
    HeaderProperties sh_addr;
} SectionHeaders;

SectionHeaders SECTION_HEADERS;

typedef struct {
    unsigned char *name;
    struct {
        int decimalValue;
        char *stringValue;
    } index;
    struct {
        int decimalValue;
        unsigned char *hexadecimalValue;
    } offset;
    struct {
        int decimalValue;
        unsigned char *hexadecimalValue;
    } size;
    struct {
        int decimalValue;
        unsigned char *hexadecimalValue;
    } vma;
} Section;

//-----------------------------------------------------------

typedef struct {
    unsigned int st_name;
    unsigned int st_value;
    unsigned int st_size;
    unsigned char st_info;
    unsigned char st_other;
    unsigned short st_shndx;
} Symbol;

//-----------------------------------------------------------

int getStringSize (const unsigned char *str) {
    int i = 0;
    while (str[i] != '\0')
        i++;
    return i;
}

int stringIsEqual (const unsigned char *str1, const unsigned char *str2) {
    if (getStringSize(str1) != getStringSize(str2))
        return 0;

    int i, acc = 1, strSize = getStringSize(str1);
    for (i = 0; i < strSize; i++)
        acc = acc && (str1[i] == str2[i]);

    return acc;
}

void addShiftInString (unsigned char *str, int index) {
    int i;
    for (i = getStringSize(str); i >= index; i--) {
        str[i + 1] = str[i];
    }
    str[index] = ' ';
}

void addLeftZeroInString (unsigned char *str, int strLength) {
    int numberOfZero = strLength - getStringSize(str);
    unsigned char aux[strLength];

    int i = 0;
    while (str[i] != '\0') {
        aux[i] = str[i];
        i++;
    }

    for (int j = 0; j < numberOfZero; j++) {
        str[j] = '0';
    }

    for (int k = numberOfZero; k < strLength; k++) {
        str[k] = aux[k - numberOfZero];
    }
}

void removeLeftZeroInString (unsigned char *str) {
    unsigned char aux[BYTE_SIZE];

    for (int i = 0; i < BYTE_SIZE; i++) {
        aux[i] = str[i];
    }

    int indexOfFirstNonZeroCharacter;
    for (int j = 0; j < BYTE_SIZE; j++) {
        if (str[j] != '0' && str[j] != '\0') {
            indexOfFirstNonZeroCharacter = j;
            break;
        }
    }

    int index = 0;
    for (int k = indexOfFirstNonZeroCharacter; k < BYTE_SIZE; k++) {
        str[index] = aux[k];
        index++;
    }
    str[index] = '\0';
}

void invertEndianess (unsigned char *str) {
    unsigned char firstCharacter = str[0];
    unsigned char secondCharacter = str[1];
    unsigned char thirdCharacter = str[2];
    unsigned char fourthCharacter = str[3];

    str[0] = fourthCharacter;
    str[1] = thirdCharacter;
    str[2] = secondCharacter;
    str[3] = firstCharacter;
}

//-----------------------------------------------------------

void writeBreakLine () {
    unsigned char breakLine = '\n';
    write(STDOUT_FILENO, &breakLine, sizeof(unsigned char));
}

void writeTab () {
    unsigned char tab = '\t';
    write(STDOUT_FILENO, &tab, sizeof(unsigned char));
}

void writeSpace () {
    unsigned char space = ' ';
    write(STDOUT_FILENO, &space, sizeof(unsigned char));
}

void writeGreaterThenSymbol () {
    char greaterThenSymbol = '>';
    write(STDOUT_FILENO, &greaterThenSymbol, sizeof(char));
}

void writeLessThenSymbol () {
    char lessThenSymbol = '<';
    write(STDOUT_FILENO, &lessThenSymbol, sizeof(char));
}

void writeTwoPointsSymbol () {
    char twoPointsSymbol = ':';
    write(STDOUT_FILENO, &twoPointsSymbol, sizeof(char));
}

void writeHeader (char *filename) {
    writeBreakLine();

    write(STDOUT_FILENO, filename, getStringSize((unsigned char *)filename));

    unsigned char fileDetails[31] = ": file format elf32-littleriscv";
    write(STDOUT_FILENO, fileDetails, getStringSize(fileDetails));

    writeBreakLine();
    writeBreakLine();
}

//-----------------------------------------------------------

int exponential (int base, int exponent) {
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

char convertIntToNumericCharacter (int num) {
    return (char)(num + '0');
}

char convertIntToAlfabeticCharacter (int num) {
    return (char)(num + 'a');
}

void convertIntToString(int num, char *str) {
    int numberOfdigits = 0, invertedDigits[100], digits[100], digit;

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

    digits[numberOfdigits] = '\0';

    //converting digits to character
    for (int i = 0; i < numberOfdigits; i++) {
        str[i] = convertIntToNumericCharacter(digits[i]);
    }
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

void readBytesFromFile (unsigned char *fileContent, char *arr, int init, int size) {
    int end = init + size - 1, index = 0;
    for (int i = end; i >= init; i--) {
        arr[index] = fileContent[i];
        index++;
    }
    arr[index] = '\0';
}

//----------------------------------------------------------

int getSectionOffset (int sectionIndex) {
    return FILE_HEADERS.e_shoff.decimalValue + sectionIndex * SECTION_SIZE_IN_BYTES;
}

int getSectionEnd (int sectionInit, int sectionSize) {
    return sectionInit + sectionSize;
}

int getShstrtabSectionInit (unsigned char *fileContent) {
    int sectionIndex = FILE_HEADERS.e_shstrndx.decimalValue,
        sectionInit = getSectionOffset(sectionIndex),
        initOffset = sectionInit + START_OFFSET_OF_NAMES_IN_SECTION_SHSTRNDX;

    char offset[SECTION_PROPERTIES_SIZE_IN_BYTES];
    readBytesFromFile(fileContent, offset, initOffset, SECTION_PROPERTIES_SIZE_IN_BYTES);

    return convertMultipleBytesToDecimal(offset, SECTION_PROPERTIES_SIZE_IN_BYTES);
}

int getNameOffset (unsigned char *fileContent, int sectionInit) {
    char offset[SECTION_PROPERTIES_SIZE_IN_BYTES];
    readBytesFromFile(fileContent, offset, sectionInit, SECTION_PROPERTIES_SIZE_IN_BYTES);

    return convertMultipleBytesToDecimal(offset, SECTION_PROPERTIES_SIZE_IN_BYTES);
}

int getNameInAnotherSection (unsigned char *fileContent, int sectionInit, int nameOffset, char *name) {
    int nameInit = sectionInit + nameOffset;
    if ((int)fileContent[nameInit] == 0) nameInit++;

    int index = 0;

    while((int)fileContent[nameInit + index] != 0) {
        name[index] = fileContent[nameInit + index];
        index++;
    }
    name[index] = '\0';
    return index + 1;
}

int getSectionHeaderProperty (unsigned char *fileContent, int sectionInit, char *hexadecimalValue, HeaderProperties hp) {
    unsigned char binaryValue[hp.size];
    int init = sectionInit + hp.offset,
        end = init + hp.size - 1,
        index = 0;

    for (int i = end; i >= init; i--) {
        binaryValue[index] = fileContent[i];
        index++;
    }

    hp.decimalValue = convertMultipleBytesToDecimal(binaryValue, hp.size);
    convertDecimalToHexadecimal(hp.decimalValue, hexadecimalValue);

    return hp.decimalValue;
}

//-----------------------------------------------------------

void initializeFileHeaders (unsigned char *fileContent) {
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

void initializeSectionHeaders (unsigned char *fileContent) {
    SECTION_HEADERS.sh_name.offset = getShstrtabSectionInit(fileContent);

    SECTION_HEADERS.sh_addr.offset = 12;
    SECTION_HEADERS.sh_addr.size = 4;

    SECTION_HEADERS.sh_offset.offset = 16;
    SECTION_HEADERS.sh_offset.size = 4;

    SECTION_HEADERS.sh_size.offset = 20;
    SECTION_HEADERS.sh_size.size = 4;
}

//-----------------------------------------------------------

Section getSection (unsigned char *fileContent, int sectionInit, int i) {
    Section s;
    char index[MAX_STRING_SIZE], name[MAX_STRING_SIZE], hexadecimalOffset[BYTE_SIZE + 1], hexadecimalVma[BYTE_SIZE + 1], hexadecimalSize[BYTE_SIZE + 1];
    int nameOffset = getNameOffset(fileContent, sectionInit);

    getNameInAnotherSection(fileContent, SECTION_HEADERS.sh_name.offset, nameOffset, &name);
    getSectionHeaderProperty(fileContent, sectionInit, &hexadecimalSize, SECTION_HEADERS.sh_size);
    getSectionHeaderProperty(fileContent, sectionInit, &hexadecimalOffset, SECTION_HEADERS.sh_offset);
    getSectionHeaderProperty(fileContent, sectionInit, &hexadecimalVma, SECTION_HEADERS.sh_addr);
    convertIntToString(i, index);

    s.name = name;
    s.index.decimalValue = i;
    s.index.stringValue = index;
    s.size.decimalValue = SECTION_HEADERS.sh_size.decimalValue;
    s.size.hexadecimalValue = hexadecimalSize;
    s.offset.decimalValue = SECTION_HEADERS.sh_offset.decimalValue;
    s.offset.hexadecimalValue = hexadecimalOffset;
    s.vma.decimalValue = SECTION_HEADERS.sh_addr.decimalValue;
    s.vma.hexadecimalValue = hexadecimalVma;

    return s;
}

Section *printSectionTable (unsigned char *fileContent) {
    int numberOfSections = FILE_HEADERS.e_shnum.decimalValue,
            sectionInit = FILE_HEADERS.e_shoff.decimalValue;
    Section s;

    const unsigned char title[10] = "Sections:";
    write(STDOUT_FILENO, title, 9);

    writeBreakLine();

    const unsigned char subtitle[18] = "Idx Name Size VMA";
    write(STDOUT_FILENO, subtitle, 17);

    for (int i = 0; i < numberOfSections; i++) {
        s = getSection(fileContent, sectionInit, i);

        writeBreakLine();
        write(STDOUT_FILENO, s.index.stringValue, getStringSize(s.index.stringValue));
        writeTab();
        write(STDOUT_FILENO, s.name, getStringSize(s.name));
        writeTab();
        write(STDOUT_FILENO, s.size.hexadecimalValue, getStringSize(s.size.hexadecimalValue));
        writeTab();
        write(STDOUT_FILENO, s.vma.hexadecimalValue, getStringSize(s.vma.hexadecimalValue));

        sectionInit += SECTION_SIZE_IN_BYTES;
    }
}

//-----------------------------------------------------------

void printSymbolTable (unsigned char *fileContent) {
    int numberOfSections = FILE_HEADERS.e_shnum.decimalValue,
        sectionInit = FILE_HEADERS.e_shoff.decimalValue;

    unsigned char symtabOffset[MAX_STRING_SIZE], symtabSize[MAX_STRING_SIZE], strtabOffset[MAX_STRING_SIZE];
    int symtabOffsetDecimalValue, symtabSizeDecimalValue, strtabOffsetDecimalValue;

     for (int i = 0; i < numberOfSections; i++) {
        char symtabName[10] = ".symtab",
             strtabName[10] = ".strtab",
             name[MAX_STRING_SIZE];

        int nameOffset = getNameOffset(fileContent, sectionInit);
         getNameInAnotherSection(fileContent, SECTION_HEADERS.sh_name.offset, nameOffset, &name);

        if (stringIsEqual(name, symtabName) == 1) {
            symtabOffsetDecimalValue = getSectionHeaderProperty(fileContent, sectionInit, symtabOffset, SECTION_HEADERS.sh_offset);
            symtabSizeDecimalValue = getSectionHeaderProperty(fileContent, sectionInit, symtabSize, SECTION_HEADERS.sh_size);
        }

         if (stringIsEqual(name, strtabName) == 1) {
             strtabOffsetDecimalValue = getSectionHeaderProperty(fileContent, sectionInit, strtabOffset, SECTION_HEADERS.sh_offset);
         }

        sectionInit += SECTION_SIZE_IN_BYTES;
    }

    unsigned int numberOfSymbols = (symtabSizeDecimalValue / sizeof(Symbol)) - 1;

    unsigned char   symbolValue[MAX_STRING_SIZE],
                    symbolInfo,
                    symbolSize[MAX_STRING_SIZE],
                    symbolName[MAX_STRING_SIZE],
                    symbolSectionName[MAX_STRING_SIZE],
                    st_shndx[BYTE_SIZE];

    int symbolOffset = 0,
        lastOffsetReadInStrtabSection = 0;

    char title[MAX_STRING_SIZE] = "SYMBOL TABLE:";
    write(STDOUT_FILENO, title, 13);

    writeBreakLine();

    for (int j = 0; j < numberOfSymbols; j++) {
        int init = symtabOffsetDecimalValue + symbolOffset;

        // symbol value
        readBytesFromFile(fileContent, symbolValue, init + 20, 4);
        int decimalValue = convertMultipleBytesToDecimal(symbolValue, 4);
        convertDecimalToHexadecimal(decimalValue, symbolValue);
        write(STDOUT_FILENO, symbolValue, 8);
        writeTab();

        // symbol type -> global (g) or local (l)
        symbolInfo = fileContent[init + 28];
        if (symbolInfo >> 4 == 0) {
            write(STDOUT_FILENO, "l", 1);
        } else {
            write(STDOUT_FILENO, "g", 1);
        }
        writeTab();

        // symbol section name
        readBytesFromFile(fileContent, st_shndx, init + 30, BYTE_SIZE);
        unsigned short st_shndx_decimal_value = convertMultipleBytesToDecimal(st_shndx, BYTE_SIZE);

        if (st_shndx_decimal_value < 0 || st_shndx_decimal_value > numberOfSections) {
            write(STDOUT_FILENO, "*ABS*", 5);
        } else {
            int sectionInit = FILE_HEADERS.e_shoff.decimalValue + st_shndx_decimal_value * SECTION_SIZE_IN_BYTES;
            int nameOffset = getNameOffset(fileContent, sectionInit);
            getNameInAnotherSection(fileContent, SECTION_HEADERS.sh_name.offset, nameOffset, &symbolSectionName);
            write(STDOUT_FILENO, symbolSectionName, getStringSize(symbolSectionName));
        }
        writeTab();

        // read and print symbol size
        readBytesFromFile(fileContent, symbolSize, init + 8, 4);
        if (getStringSize(symbolSize) < BYTE_SIZE) {
            addLeftZeroInString(symbolSize, BYTE_SIZE);
        }
        write(STDOUT_FILENO, symbolSize, BYTE_SIZE);
        writeTab();

        // symbol name
        lastOffsetReadInStrtabSection += getNameInAnotherSection(fileContent, strtabOffsetDecimalValue, lastOffsetReadInStrtabSection, symbolName);
        write(STDOUT_FILENO, symbolName, getStringSize(symbolName));

        symbolOffset += 16;

        writeBreakLine();
    }
}

//-----------------------------------------------------------

void disassemblyTextSection(unsigned char *fileContent) {
    writeBreakLine();

    unsigned char title[29] = "Disassembly of section .text:";
    write(STDOUT_FILENO, title, 29);
    writeBreakLine();

    // getting .text, .symtab and .strtab section properties

    int numberOfSections = FILE_HEADERS.e_shnum.decimalValue,
        sectionInit = FILE_HEADERS.e_shoff.decimalValue;

    // .text properties
    char textOffset[MAX_STRING_SIZE],
         textAddress[MAX_STRING_SIZE],
         textSize[MAX_STRING_SIZE];
    unsigned int textOffsetDecimalValue,
                 textAddressDecimalValue,
                 textSizeDecimalValue;

    // .symtab properties
    unsigned char symtabOffset[MAX_STRING_SIZE],
                  symtabSize[MAX_STRING_SIZE];
    int symtabOffsetDecimalValue,
        symtabSizeDecimalValue;

    // .strtab properties
    unsigned char strtabOffset[MAX_STRING_SIZE];
    int strtabOffsetDecimalValue;

    for (int i = 0; i < numberOfSections; i++) {
        char textName[10] = ".text",
             symtabName[10] = ".symtab",
             strtabName[10] = ".strtab",
             name[MAX_STRING_SIZE];

        int nameOffset = getNameOffset(fileContent, sectionInit);
        getNameInAnotherSection(fileContent, SECTION_HEADERS.sh_name.offset, nameOffset, &name);

        if (stringIsEqual(name, textName) == 1) {
            textAddressDecimalValue = getSectionHeaderProperty(fileContent, sectionInit, textAddress, SECTION_HEADERS.sh_addr);
            textOffsetDecimalValue = getSectionHeaderProperty(fileContent, sectionInit, textOffset, SECTION_HEADERS.sh_offset);
            textSizeDecimalValue = getSectionHeaderProperty(fileContent, sectionInit, textSize, SECTION_HEADERS.sh_size);
        }

        if (stringIsEqual(name, symtabName) == 1) {
            symtabOffsetDecimalValue = getSectionHeaderProperty(fileContent, sectionInit, symtabOffset, SECTION_HEADERS.sh_offset);
            symtabSizeDecimalValue = getSectionHeaderProperty(fileContent, sectionInit, symtabSize, SECTION_HEADERS.sh_size);
        }

        if (stringIsEqual(name, strtabName) == 1) {
            strtabOffsetDecimalValue = getSectionHeaderProperty(fileContent, sectionInit, strtabOffset, SECTION_HEADERS.sh_offset);
        }

        sectionInit += SECTION_SIZE_IN_BYTES;
    }

    // print disassamble of section .text

    int instructionAddressDecimalValue = textAddressDecimalValue,
        instructionOffset = 0;
    do {
        // getting symbols names and addresses
        unsigned int numberOfSymbols = (symtabSizeDecimalValue / sizeof(Symbol)) - 1,
                     symbolOffset = 0,
                     lastOffsetReadInStrtabSection = 0;

        unsigned char symbolAddress[MAX_STRING_SIZE],
                      symbolName[MAX_STRING_SIZE];

        for (int j = 0; j < numberOfSymbols; j++) {
            int init = symtabOffsetDecimalValue + symbolOffset;

            // symbol value
            readBytesFromFile(fileContent, symbolAddress, init + 20, 4);
            int symbolAddressDecimalValue = convertMultipleBytesToDecimal(symbolAddress, 4);
            convertDecimalToHexadecimal(symbolAddressDecimalValue, symbolAddress);

            // symbol name
            lastOffsetReadInStrtabSection += getNameInAnotherSection(fileContent, strtabOffsetDecimalValue, lastOffsetReadInStrtabSection, symbolName);

            // print symbol name if instructions addresses are inside of symbol address
            if (instructionAddressDecimalValue == symbolAddressDecimalValue &&
            instructionAddressDecimalValue >= symbolAddressDecimalValue &&
            instructionAddressDecimalValue <= symbolAddressDecimalValue + INSTRUCTION_SIZE_IN_BYTES) {

                writeBreakLine();

                write(STDOUT_FILENO, symbolAddress, BYTE_SIZE);
                writeTab();

                writeLessThenSymbol();
                write(STDOUT_FILENO, symbolName, getStringSize(symbolName));
                writeGreaterThenSymbol();
                writeTwoPointsSymbol();

                writeBreakLine();

            }

            symbolOffset += 16;
        }

        // print instruction address
        unsigned char instructionHexadecimalAddress[BYTE_SIZE];
        convertDecimalToHexadecimal(instructionAddressDecimalValue, instructionHexadecimalAddress);

        removeLeftZeroInString(instructionHexadecimalAddress);

        writeTab();
        write(STDOUT_FILENO, instructionHexadecimalAddress, getStringSize(instructionHexadecimalAddress));
        writeTwoPointsSymbol();
        writeTab();

        // print instruction code (hexadecimal value)
        unsigned char instructionHexadecimalCode[INSTRUCTION_SIZE_IN_BYTES];
        int instructionInit = textOffsetDecimalValue + instructionOffset;
        readBytesFromFile(fileContent, instructionHexadecimalCode, instructionInit, INSTRUCTION_SIZE_IN_BYTES);

        invertEndianess(instructionHexadecimalCode);

        for (int l = 0; l < INSTRUCTION_SIZE_IN_BYTES; l++) {
            char hexadecimal[BYTE_SIZE];

            convertDecimalToHexadecimal((int)instructionHexadecimalCode[l], hexadecimal);

            removeLeftZeroInString(hexadecimal);

            addLeftZeroInString(hexadecimal, 2);

            write(STDOUT_FILENO, hexadecimal, 2);
            writeSpace();
        }

        writeBreakLine();

        // jump to next instruction
        instructionAddressDecimalValue += INSTRUCTION_SIZE_IN_BYTES;
        instructionOffset += INSTRUCTION_SIZE_IN_BYTES;

    } while (instructionAddressDecimalValue < textAddressDecimalValue + textSizeDecimalValue);
}

//-----------------------------------------------------------

char removeTraceFromFlag (char *flag) {
    return flag[0] == '-' ?  flag[1] : flag[0];
}

void executeDecodification (unsigned char *fileContent, char *flagWithTracePrefix) {
    char flag = removeTraceFromFlag(flagWithTracePrefix);

    if (flag == FLAGS.printSectionTable) {
        printSectionTable(fileContent);
    }

    else if (flag == FLAGS.printSymbolTable) {
        printSymbolTable(fileContent);
    }

    else if (flag == FLAGS.disassemblyTextSection) {
        disassemblyTextSection(fileContent);
    }
}

//-----------------------------------------------------------
int main (int argc, char *argv[]) {
    initializeCommandFlags();

    char *flag = argv[1];
    char *fileName = argv[2];
    unsigned char fileContent[MAX_FILE_SIZE_IN_BYTES];

    int file = open(fileName, O_RDONLY);
    if (file == EXIT_PROGRAM_CODE) {
        return -1;
    }
    read(file, fileContent, MAX_FILE_SIZE_IN_BYTES);

    initializeFileHeaders(fileContent);
    initializeSectionHeaders(fileContent);

    writeHeader(fileName);

    executeDecodification(fileContent, flag);

    close(file);

    return 0;
}