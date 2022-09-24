#DISASSM="my_disassembler.x"
DISASSM="llvm-objdump-12 -M=no-aliases"
OUTDIR="my_output"

echo "==============================================================="
echo "This script runs the disassembly tool on all bin/*.x files"
echo "and store all the results into the target directory."
echo " * Disassembly tool: ${DISASSM}"
echo " * Target directory: ${OUTDIR}"
echo "==============================================================="

# Create output directory
[-d "${OUTDIR}" ] || mkdir -p "${OUTDIR}"

for EXE in bin/*.x; do
    echo "-- Disassembling ${EXE}"
    B=$(basename ${EXE} .x)
    ${DISASSM} -d ${EXE} | python3 ./remove-spaces.py > "${OUTDIR}/$B.d.dump"
    ${DISASSM} -t ${EXE} | python3 ./remove-spaces.py > "${OUTDIR}/$B.t.dump"
    ${DISASSM} -h ${EXE} | python3 ./remove-spaces.py | cut -d\  -f1-4 > "${OUTDIR}/$B.h.dump"
done
