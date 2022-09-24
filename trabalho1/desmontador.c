#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
//-----------------------------------------------------------
#define MAX_FILE_SIZE 10000
#define ERROR_OPENING_FILE -1
#define NUMBER_OF_BYTES_IN_SECTION 40
#define SECTION_OFFSET_SIZE_IN_BYTES 4
#define SECTION_SIZE_IN_BYTES 4
#define SECTION_PROPERTIES_SIZE_IN_BYTES 4
#define MAX_SECTION_NAME_SIZE 10
//-----------------------------------------------------------
typedef struct {
    char printSectionTable;
    char printSymbolTable;
    char printTextSection;
} ExecutionFlags;

ExecutionFlags executionFlags;

void initializeExecutionFlags() {
    executionFlags.printSectionTable = 'h';
    executionFlags.printSymbolTable = 't';
    executionFlags.printTextSection = 'd';
};
//-----------------------------------------------------------
typedef struct {
    int offset;
    int size;
    int value;
} HeaderProperties;

typedef struct {
    HeaderProperties e_shoff;
    HeaderProperties e_shnum;
    HeaderProperties e_shstrndx;
} FileHeaders;

FileHeaders FILE_HEADERS;

void initializeFileHeaders() {
    FILE_HEADERS.e_shoff.offset = 32;
    FILE_HEADERS.e_shoff.size = 4;
    FILE_HEADERS.e_shoff.value = 0;

    FILE_HEADERS.e_shnum.offset = 48;
    FILE_HEADERS.e_shnum.size = 2;
    FILE_HEADERS.e_shnum.value = 0;

    FILE_HEADERS.e_shstrndx.offset = 50;
    FILE_HEADERS.e_shstrndx.size = 2;
    FILE_HEADERS.e_shstrndx.value = 0;
}
//-----------------------------------------------------------
typedef struct {
    int index;
    char *name;
    char *size;
    char *vma;
} Section;

typedef struct {
    Section *sections;
    int numberOfSections;
} SectionsTable;

SectionsTable SECTIONS_TABLE;
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
//-----------------------------------------------------------
int getE_shoffValue(unsigned char *fileContent) {
    unsigned char e_shoff[FILE_HEADERS.e_shoff.size];
    int initOffsite = FILE_HEADERS.e_shoff.offset,
        endOffsite = initOffsite + FILE_HEADERS.e_shoff.size - 1,
        index = 0;

    for (int i = endOffsite; i >= initOffsite; i--) {
        e_shoff[index++] = fileContent[i];
    }

    return convertMultipleBytesToDecimal(e_shoff, FILE_HEADERS.e_shoff.size);
}

int getE_shnumValue(unsigned char *fileContent) {
    unsigned char e_shnum[FILE_HEADERS.e_shnum.size];
    int initOffsite = FILE_HEADERS.e_shnum.offset,
            endOffsite = initOffsite + FILE_HEADERS.e_shnum.size - 1,
            index = 0;

    for (int i = endOffsite; i >= initOffsite; i--) {
        e_shnum[index++] = fileContent[i];
    }

    return convertMultipleBytesToDecimal(e_shnum, FILE_HEADERS.e_shnum.size);
}

int getE_shstrndxValue(unsigned char *fileContent) {
    unsigned char e_shstrndx[FILE_HEADERS.e_shstrndx.size];
    int initOffsite = FILE_HEADERS.e_shstrndx.offset,
            endOffsite = initOffsite + FILE_HEADERS.e_shstrndx.size - 1,
            index = 0;

    for (int i = endOffsite; i >= initOffsite; i--) {
        e_shstrndx[index++] = fileContent[i];
    }

    return convertMultipleBytesToDecimal(e_shstrndx, FILE_HEADERS.e_shstrndx.size);
}

void setHeadersFromFile (unsigned char *fileContent) {
    FILE_HEADERS.e_shoff.value = getE_shoffValue(fileContent);
    FILE_HEADERS.e_shnum.value = getE_shnumValue(fileContent);
    FILE_HEADERS.e_shstrndx.value = getE_shstrndxValue(fileContent);
}
//-----------------------------------------------------------
char *getSectionName (unsigned char *fileContent, int sectionInit) {
    char name[MAX_SECTION_NAME_SIZE];
    int index = sectionInit;

    while(fileContent[index] != 0) {
        name[index - sectionInit] = fileContent[index];
        index++;
    }

    return *name;
}

char *getSectionVMA (unsigned char *fileContent, int sectionInit) {
    char vma[SECTION_PROPERTIES_SIZE_IN_BYTES];
    int index = 0;

    for(int i = sectionInit + 12; i <= SECTION_PROPERTIES_SIZE_IN_BYTES; i++) {
        vma[i] = fileContent[i];
    }

    return vma;
}

char *getSectionSize (unsigned char *fileContent, int sectionInit) {
    char size[SECTION_PROPERTIES_SIZE_IN_BYTES];
    int index = 0;

    for(int i = sectionInit + 20; i <= SECTION_PROPERTIES_SIZE_IN_BYTES; i++) {
        size[i] = fileContent[i];
    }

    return size;
}

void setSectionsInTable (unsigned char *fileContent) {
    Section s, sections[FILE_HEADERS.e_shnum.value];
    int sectionsInit = FILE_HEADERS.e_shoff.value,
        sectionsEnd = sectionsInit + FILE_HEADERS.e_shnum.value * NUMBER_OF_BYTES_IN_SECTION,
        index = 0;

    for (int i = sectionsInit; i < sectionsEnd; i+= NUMBER_OF_BYTES_IN_SECTION) {
        s.index = i;
        s.name = getSectionName(fileContent, i);
        s.vma = getSectionVMA(fileContent, i);
        s.size = getSectionSize(fileContent, i);
        sections[index++] = s;
    }

    SECTIONS_TABLE.sections = sections;
    SECTIONS_TABLE.numberOfSections = FILE_HEADERS.e_shnum.value;
}

void printSectionsTable () {
    printf("Sections:\n");
    printf("Idx\tName\tSize\tVMA");
    for (int i = 0; i < SECTIONS_TABLE.numberOfSections; i++) {
        printf("\n%d\t%s\t%s\t%s", SECTIONS_TABLE.sections[i].index, SECTIONS_TABLE.sections[i].name, SECTIONS_TABLE.sections[i].size, SECTIONS_TABLE.sections[i].vma);
    }
}
//-----------------------------------------------------------
char getFlagValue(char *flag) {
    return flag[0] == '-' ?  flag[1] : flag[0];
}

void executeDecodification (unsigned char *fileContent, char *executionOption) {
    char flag = getFlagValue(executionOption);

    if (flag == executionFlags.printSectionTable) {
        setSectionsInTable(fileContent);
        printSectionsTable();
    }

    else if (flag == executionFlags.printSymbolTable) {
        //TODO: implement getSymbolTable()
    }

    else if (flag == executionFlags.printTextSection) {
        // TODO: implement getTextSection()
    }
}
//-----------------------------------------------------------
int main(int argc, char *argv[]) {
    initializeExecutionFlags();

    // char *executionOption = argv[1];
    char *executionOption = "-h";
    // char *fileName = argv[2];
    char *fileName = "../bin/test-00.x";
    unsigned char fileContent[MAX_FILE_SIZE];

    int file = open(fileName, O_RDONLY);
    if (file == ERROR_OPENING_FILE) {
        return -1;
    }
    read(file, fileContent, MAX_FILE_SIZE);

    initializeFileHeaders();
    setHeadersFromFile(fileContent);

    executeDecodification(fileContent, executionOption);

    close(file);

    return 0;
}