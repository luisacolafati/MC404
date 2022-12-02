#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

#define MAX_FILESIZE 102400
#define MAX_STRSIZE 1024

typedef enum { INVALID, SECTIONS, SYMBOL_TABLE, DISASSEMBLY } Option;

typedef struct {
  unsigned char e_ident[16];
  unsigned short e_type;
  unsigned short e_machine;
  unsigned int e_version;
  unsigned int e_entry;
  unsigned int e_phoff;
  unsigned int e_shoff;
  unsigned int e_flags;
  unsigned short e_ehsize;
  unsigned short e_phentsize;
  unsigned short e_phnum;
  unsigned short e_shentsize;
  unsigned short e_shnum;
  unsigned short e_shstrndx;
} Elf32_Ehdr; // File Header

typedef struct {
  unsigned int sh_name;
  unsigned int sh_type;
  unsigned int sh_flags;
  unsigned int sh_addr;
  unsigned int sh_offset;
  unsigned int sh_size;
  unsigned int sh_link;
  unsigned int sh_info;
  unsigned int sh_addralign;
  unsigned int sh_entsize;
} Elf32_Shdr; // Section Header

typedef struct {
  unsigned int st_name;
  unsigned int st_value;
  unsigned int st_size;
  unsigned char st_info;
  unsigned char st_other;
  unsigned short st_shndx;
} Elf32_Sym; // Symbol Table

typedef unsigned int RiscV_Instruction;

int strlength(const unsigned char *str) {
  int i = 0;
  while (str[i] != '\0')
    i++;
  return i;
}

int strequal(const unsigned char *str1, const unsigned char *str2) {
  if (strlength(str1) != strlength(str2))
    return 0;

  int i;
  int acc = 1;
  int n = strlength(str1);
  for (i = 0; i < n; i++)
    acc = acc && (str1[i] == str2[i]);
  return acc;
}

void strconcat(unsigned char *dest, const unsigned char *src) {
  int len = strlength(dest);
  int i;
  for (i = 0; src[i] != '\0'; i++, len++)
    dest[len] = src[i];
  dest[len] = '\0';
}

void strreverse(unsigned char *str) {
  int i, temp;
  for (i = 0; i < strlength(str) / 2; i++) {
    temp = str[i];
    str[i] = str[strlength(str) - i - 1];
    str[strlength(str) - i - 1] = temp;
  }
}

void strappend(unsigned char *str, unsigned char c) {
  int len = strlength(str);
  str[len] = c;
  str[len + 1] = '\0';
}

void strclear(unsigned char *str) { str[0] = '\0'; }

void strzero(unsigned char *str, int size) {
  int missing = size - strlength(str);
  unsigned char dest[MAX_STRSIZE];
  int i;
  for (i = 0; i < missing; i++) {
    strappend(dest, '0');
  }
  strconcat(dest, str);
  str = dest;
}

void strshiftr(unsigned char *str, int index) {
  int i;
  for (i = strlength(str); i >= index; i--) {
    str[i + 1] = str[i];
  }
  str[index] = ' ';
}

void strendianess(unsigned char *str) {
  unsigned char first = str[0];
  unsigned char second = str[1];
  str[0] = str[6];
  str[1] = str[7];
  str[6] = first;
  str[7] = second;
  unsigned char third = str[2];
  unsigned char fourth = str[3];
  str[2] = str[4];
  str[3] = str[5];
  str[4] = third;
  str[5] = fourth;
}

Option parse_option(int argc, char *argv[]) {
  Option opt;

  if (argc < 2)
    opt = INVALID;

  switch (argv[1][1]) {
  case 'h':
    opt = SECTIONS;
    break;
  case 't':
    opt = SYMBOL_TABLE;
    break;
  case 'd':
    opt = DISASSEMBLY;
    break;
  default:
    opt = INVALID;
    break;
  }
  return opt;
}

char *parse_filename(int argc, char *argv[]) {
  char *filename;
  if (argc < 3)
    filename = "";
  else
    filename = argv[2];
  return filename;
}

void read_file(unsigned char *buffer, char *filename) {
  int fd = open(filename, O_RDONLY);
  read(fd, buffer, MAX_FILESIZE);
}

void linebreak() {
  unsigned char lb = '\n';
  write(1, &lb, sizeof(unsigned char));
}

void space() {
  unsigned char sp = ' ';
  write(1, &sp, sizeof(unsigned char));
}

unsigned int power(unsigned int base, unsigned int exponent) {
  int i;
  int result = 1;
  for (i = 0; i < exponent; i++)
    result *= exponent;
  return result;
}

void uint32_to_string(unsigned int val, unsigned int base, unsigned char *str) {
  int i = 0;
  if (val == 0) {
    str[i++] = '0';
    str[i] = '\0';
  }
  while (val != 0) {
    int rem = val % base;
    if (rem > 9)
      str[i++] = (rem - 10) + 'a';
    else
      str[i++] = rem + '0';
    val = val / base;
  }
  str[i] = '\0';
  strreverse(str);
}

void print_file_info(char *filename) {
  linebreak();
  write(STDOUT_FILENO, filename, strlength((unsigned char *)filename));
  unsigned char info[MAX_STRSIZE] = ": file format elf32-littleriscv";
  write(STDOUT_FILENO, info, strlength(info));
  linebreak();
  linebreak();
}

int main(int argc, char *argv[]) {
  Option opt = parse_option(argc, argv);
  char *filename = parse_filename(argc, argv);
  unsigned char buffer[MAX_FILESIZE];
  read_file(buffer, filename);

  Elf32_Sym *current_sym;
  Elf32_Ehdr *file_header = (Elf32_Ehdr *)&buffer;
  Elf32_Shdr *section_header;
  Elf32_Shdr *shstrtab_header =
      (Elf32_Shdr *)&buffer[file_header->e_shoff +
                            file_header->e_shstrndx * sizeof(Elf32_Shdr)];
  /* unsigned int shstrtab_offset = shstrtab_header->sh_offset; */
  unsigned short number_of_sections = file_header->e_shnum;
  unsigned int section_name_offset;
  unsigned int symbol_name_offset;
  int i, j;

  switch (opt) {
  case SECTIONS:
    // imprimir inicio do output
    print_file_info(filename);
    unsigned char sections_title[MAX_STRSIZE] = "Sections:";
    write(STDOUT_FILENO, sections_title, strlength(sections_title));
    linebreak();

    unsigned char columns[MAX_STRSIZE] = "Idx Name Size VMA";
    write(STDOUT_FILENO, columns, strlength(columns));
    linebreak();

    unsigned char section_idx[MAX_STRSIZE];
    unsigned char section_name[MAX_STRSIZE] = "";
    unsigned char section_size[MAX_STRSIZE] = "";
    unsigned char section_vma[MAX_STRSIZE] = "";

    unsigned char c;
    for (i = 0; i < number_of_sections; i++) {
      uint32_to_string(i, 10, section_idx);
      write(STDOUT_FILENO, section_idx, strlength(section_idx));
      space();

      section_header =
          (Elf32_Shdr *)&buffer[file_header->e_shoff + i * sizeof(Elf32_Shdr)];

      // read and print section name
      section_name_offset =
          shstrtab_header->sh_offset + section_header->sh_name;
      strclear(section_name);
      for (j = section_name_offset; buffer[j] != '\0'; j++) {
        c = buffer[j];
        strappend(section_name, c);
      }
      write(STDOUT_FILENO, section_name, strlength(section_name));
      if (strlength(section_name))
        space();

      // read and print section size
      uint32_to_string(section_header->sh_size, 16, section_size);
      if (strlength(section_size) < 8) {
        char zero = '0';
        for (j = 0; j < 8 - strlength(section_size); j++) {
          write(STDOUT_FILENO, &zero, sizeof(unsigned char));
        }
      }
      write(STDOUT_FILENO, section_size, strlength(section_size));
      space();

      // read and print virtual memory address
      uint32_to_string(section_header->sh_addr, 16, section_vma);
      if (strlength(section_vma) < 8) {
        char zero = '0';
        for (j = 0; j < 8 - strlength(section_vma); j++) {
          write(STDOUT_FILENO, &zero, sizeof(unsigned char));
        }
      }
      write(STDOUT_FILENO, section_vma, strlength(section_vma));
      space();

      linebreak();
    }
    linebreak();
    break;
  case SYMBOL_TABLE:
    print_file_info(filename);

    unsigned char title[MAX_STRSIZE] = "SYMBOL TABLE:";
    write(STDOUT_FILENO, title, strlength(title));
    linebreak();

    // find the .symtab and .strtab sections
    unsigned int symtab_offset, symtab_size;
    unsigned int strtab_offset;
    unsigned char symtab_name[MAX_STRSIZE] = ".symtab";
    unsigned char strtab_name[MAX_STRSIZE] = ".strtab";

    for (i = 0; i < number_of_sections; i++) {
      section_header =
          (Elf32_Shdr *)&buffer[file_header->e_shoff + i * sizeof(Elf32_Shdr)];

      // get section name
      section_name_offset =
          shstrtab_header->sh_offset + section_header->sh_name;
      strclear(section_name);
      for (j = section_name_offset; buffer[j] != '\0'; j++) {
        c = buffer[j];
        strappend(section_name, c);
      }
      if (strequal(section_name, symtab_name)) {
        symtab_offset = section_header->sh_offset;
        symtab_size = section_header->sh_size;
      } else if (strequal(section_name, strtab_name)) {
        strtab_offset = section_header->sh_offset;
      }
    }

    unsigned int number_of_symbols = (symtab_size / sizeof(Elf32_Sym)) - 1;
    unsigned char symbol_value[MAX_STRSIZE];
    unsigned char symbol_size[MAX_STRSIZE] = "";
    unsigned char symbol_name[MAX_STRSIZE] = "";

    for (i = 0; i < number_of_symbols; i++) {
      current_sym = (Elf32_Sym *)&buffer[symtab_offset + i * sizeof(Elf32_Sym)];

      // read and print symbol value
      unsigned int st_value = current_sym->st_value;
      uint32_to_string(st_value, 16, symbol_value);
      if (strlength(symbol_value) < 8) {
        char zero = '0';
        for (j = 0; j < 8 - strlength(symbol_value); j++) {
          write(STDOUT_FILENO, &zero, sizeof(unsigned char));
        }
      }
      write(STDOUT_FILENO, symbol_value, strlength(symbol_value));
      space();

      // read and print symbol scope
      unsigned char symbol_scope = current_sym->st_info ? 'g' : 'l';
      write(STDOUT_FILENO, &symbol_scope, sizeof(unsigned char));
      space();

      // read and print symbol section name
      unsigned short st_shndx = current_sym->st_shndx;
      if (st_shndx < 0 || st_shndx > number_of_sections) {
        unsigned char symbol_section[] = "*ABS*";
        write(STDOUT_FILENO, symbol_section, strlength(symbol_section));
        space();
      } else {
        section_header = (Elf32_Shdr *)&buffer[file_header->e_shoff +
                                               st_shndx * sizeof(Elf32_Shdr)];
        section_name_offset =
            shstrtab_header->sh_offset + section_header->sh_name;
        strclear(section_name);
        for (j = section_name_offset; buffer[j] != '\0'; j++) {
          c = buffer[j];
          strappend(section_name, c);
        }
        write(STDOUT_FILENO, section_name, strlength(section_name));
        if (strlength(section_name))
          space();
      }

      // read and print symbol size
      unsigned int st_size = current_sym->st_size;
      uint32_to_string(st_size, 16, symbol_size);
      if (strlength(symbol_size) < 8) {
        char zero = '0';
        for (j = 0; j < 8 - strlength(symbol_size); j++) {
          write(STDOUT_FILENO, &zero, sizeof(unsigned char));
        }
      }
      write(STDOUT_FILENO, symbol_size, strlength(symbol_size));
      space();

      // read and print symbol name
      symbol_name_offset = strtab_offset + current_sym->st_name;
      strclear(symbol_name);
      for (j = symbol_name_offset; buffer[j] != '\0'; j++) {
        c = buffer[j];
        strappend(symbol_name, c);
      }
      write(STDOUT_FILENO, symbol_name, strlength(symbol_name));
      space();

      linebreak();
    }

    break;
  case DISASSEMBLY:
    // imprimir inicio do output
    print_file_info(filename);
    linebreak();

    unsigned char disassembly_title[] = "Disassembly of section .text:";
    write(STDOUT_FILENO, disassembly_title, strlength(disassembly_title));
    linebreak();

    // find .text section
    unsigned int text_offset, text_addr, text_size;
    unsigned char text_name[] = ".text";
    for (i = 0; i < number_of_sections; i++) {
      section_header =
          (Elf32_Shdr *)&buffer[file_header->e_shoff + i * sizeof(Elf32_Shdr)];

      // get section name
      section_name_offset =
          shstrtab_header->sh_offset + section_header->sh_name;
      strclear(section_name);
      for (j = section_name_offset; buffer[j] != '\0'; j++) {
        c = buffer[j];
        strappend(section_name, c);
      }
      if (strequal(section_name, text_name)) {
        text_offset = section_header->sh_offset;
        text_addr = section_header->sh_addr;
        text_size = section_header->sh_size;
      }
    }

    // read and print instruction's address and hexadecimal code
    unsigned char instruction_labl[MAX_STRSIZE] = "";
    unsigned char instruction_addr[MAX_STRSIZE];
    unsigned char instruction_hex[MAX_STRSIZE];
    unsigned int address = text_addr;
    unsigned int offset = text_offset;
    do {
      // find the .symtab section
      unsigned int symtab_size;
      unsigned char symtab_name[MAX_STRSIZE] = ".symtab";
      unsigned char strtab_name[MAX_STRSIZE] = ".strtab";
      for (i = 0; i < number_of_sections; i++) {
        section_header = (Elf32_Shdr *)&buffer[file_header->e_shoff +
                                               i * sizeof(Elf32_Shdr)];

        // get section name
        section_name_offset =
            shstrtab_header->sh_offset + section_header->sh_name;
        strclear(section_name);
        for (j = section_name_offset; buffer[j] != '\0'; j++) {
          c = buffer[j];
          strappend(section_name, c);
        }
        if (strequal(section_name, symtab_name)) {
          symtab_size = section_header->sh_size;
          symtab_offset = section_header->sh_offset;
        } else if (strequal(section_name, strtab_name)) {
          strtab_offset = section_header->sh_offset;
        }
      }

      unsigned int number_of_symbols = (symtab_size / sizeof(Elf32_Sym)) - 1;
      for (i = 1; i <= number_of_symbols; i++) {
        current_sym =
            (Elf32_Sym *)&buffer[symtab_offset + i * sizeof(Elf32_Sym)];
        if (current_sym->st_value == address &&
            address >= current_sym->st_value &&
            address <= current_sym->st_value + current_sym->st_size) {
          linebreak();
          uint32_to_string(address, 16, instruction_addr);
          if (strlength(instruction_addr) < 8) {
            char zero = '0';
            for (j = 0; j < 8 - strlength(instruction_addr); j++) {
              write(STDOUT_FILENO, &zero, sizeof(unsigned char));
            }
          }
          write(STDOUT_FILENO, instruction_addr, strlength(instruction_addr));
          space();
          char less = '<';
          write(STDOUT_FILENO, &less, sizeof(char));

          // print instruction label
          symbol_name_offset = strtab_offset + current_sym->st_name;
          strclear(instruction_labl);
          for (j = symbol_name_offset; buffer[j] != '\0'; j++) {
            char l = buffer[j];
            strappend(instruction_labl, l);
          }
          write(STDOUT_FILENO, instruction_labl, strlength(instruction_labl));

          char greater = '>';
          write(STDOUT_FILENO, &greater, sizeof(char));
          char colon = ':';
          write(STDOUT_FILENO, &colon, sizeof(char));

          linebreak();
        }
      }
      // read and print instruction's address
      uint32_to_string(address, 16, instruction_addr);
      write(STDOUT_FILENO, instruction_addr, strlength(instruction_addr));
      char colon = ':';
      write(STDOUT_FILENO, &colon, sizeof(char));
      space();

      // read and print instruction's hexadecimal code
      RiscV_Instruction *instruction = (RiscV_Instruction *)&buffer[offset];
      uint32_to_string(*instruction, 16, instruction_hex);
      while (strlength(instruction_hex) < 8) {
        strshiftr(instruction_hex, 0);
        instruction_hex[0] = '0';
      }
      strendianess(instruction_hex);
      strshiftr(instruction_hex, 2);
      strshiftr(instruction_hex, 5);
      strshiftr(instruction_hex, 8);
      strshiftr(instruction_hex, 11);
      write(STDOUT_FILENO, instruction_hex, strlength(instruction_hex));
      space();

      linebreak();
      address += sizeof(RiscV_Instruction);
      offset += sizeof(RiscV_Instruction);
    } while (address < text_addr + text_size);

    break;
  case INVALID:
    break;
  }
  return 0;
}
