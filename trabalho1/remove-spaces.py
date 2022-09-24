
import fileinput
def main():
    for line in fileinput.input():
        l = line.split()
        print(" ".join(l))

main()