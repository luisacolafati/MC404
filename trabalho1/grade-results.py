import glob, os
import argparse

verbosity = 0

def show_v(v): 
    return verbosity >= v

def print_v(v,msg):
    if show_v(v):
        print(msg)

"""
Para cada executável testado, uma nota será atribuída da forma mostrada a seguir. 
Não há nota parcial dentro de cada um dos itens.

20% para a impressão correta da tabela de símbolos (opção -t).
20% para a impressão correta da tabela de seções (opção -h). A coluna type não será considerada para a correção.
20% para a impressão correta da desmontagem da seção .text (opção -d) até a primeira coluna.
20% para a impressão correta da desmontagem da seção .text (opção -d) até a segunda coluna.
20% para a impressão correta da desmontagem da seção .text (opção -d) até a terceira coluna.
"""

def read_file(filename, max_columns = None, skip_empty_lines = False):
    lines = []
    with open(filename,"r") as f:
        for l in f.readlines():
            ll = l.split()
            if max_columns and len(ll) > max_columns:
                s = " ".join(ll[:max_columns])
            else:
                s = " ".join(ll)
            if not skip_empty_lines or s != "":
                lines.append(s)
    return lines

def show_differences(f1,l1,f2,l2):
    diffs = ""
    for i in range(len(l1)):
        if len(l2) <= i:
            diffs += " +--\n"
            diffs += " |{}[{}]: file {} does not contain line number {}\n".format(f2,i,f2,i)
            continue
        if l1[i] != l2[i]:
            diffs += " +--\n"
            diffs += " |Difference(s) in line {}\n".format(i)
            diffs += " | {}[{}]: {}\n".format(f1,i,l1[i])
            diffs += " | {}[{}]: {}\n".format(f2,i,l2[i])
    return diffs

def equal_files(f1, f2, max_columns=None):
    """Returns True if equal, otherwise false"""
    l1 = read_file(f1, max_columns)
    l2 = read_file(f2, max_columns)
    if l1 == l2:
        return True
    if show_v(3):
        diffs = show_differences(f1,l1,f2,l2)
        print(" * {} and {} differ!\n{} +--".format(f1, f2, diffs))
    elif show_v(2):
        print(" * {} and {} differ!".format(f1, f2))

    return False

def grade_symbol_tables(reference_dir, student_dir):
    tests_count = 0
    correct_count = 0
    for file in glob.glob(reference_dir + "*.t.dump"):
        tests_count += 1
        basename = os.path.basename(file)
        student_file = os.path.join(student_dir, basename) 
        if equal_files(file, student_file):
            correct_count += 1
    return 10 * correct_count / tests_count

def grade_session_headers(reference_dir, student_dir):
    tests_count = 0
    correct_count = 0
    for file in glob.glob(reference_dir + "*.h.dump"):
        tests_count += 1
        basename = os.path.basename(file)
        student_file = os.path.join(student_dir, basename) 
        if equal_files(file, student_file, max_columns=4):
            correct_count += 1
    return 10 * correct_count / tests_count

def grade_disassembly(reference_dir, student_dir, ncols):
    tests_count = 0
    correct_count = 0
    for file in glob.glob(reference_dir + "*.d.dump"):
        tests_count += 1
        basename = os.path.basename(file)
        student_file = os.path.join(student_dir, basename) 
        if equal_files(file, student_file, max_columns=ncols):
            correct_count += 1
    return 10 * correct_count / tests_count

def main():
    global verbosity
    parser = argparse.ArgumentParser()
    parser.add_argument("student_dir", help="Student directory containing soluctions to the test cases")
    parser.add_argument("-v", help="increase output verbosity", type=int, default=0)
    args = parser.parse_args()

    reference_dir = "objdump/"
    student_dir = args.student_dir
    verbosity = args.v
    print_v(2,"\nGrading the symbol table tests!")
    st_grade = grade_symbol_tables(reference_dir, student_dir)
    print_v(1,"Symbol table grading    : {}".format(st_grade))

    print_v(2,"\nGrading the session headers tests!")
    sh_grade = grade_session_headers(reference_dir, student_dir)    
    print_v(1,"Session headers grading : {}".format(sh_grade))

    print_v(2,"\nGrading the disassembly tests (c1)!")
    d1_grade = grade_disassembly(reference_dir, student_dir, 1)
    print_v(1,"Disassembly grading (c1): {}".format(d1_grade))

    print_v(2,"\nGrading the disassembly tests (c2)!")
    d2_grade = grade_disassembly(reference_dir, student_dir, 5)
    print_v(1,"Disassembly grading (c2): {}".format(d2_grade))

    print_v(2,"\nGrading the disassembly tests (c3)!")
    d3_grade = grade_disassembly(reference_dir, student_dir, 9)
    print_v(1,"Disassembly grading (c3): {}".format(d3_grade))

    grade = (st_grade+sh_grade+d1_grade+d2_grade+d3_grade) / 5
    print("Final grading: {0:.2f}".format(grade))

main()