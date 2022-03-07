#!/bin/bash

usage () {
    echo "sequasta - sequence snippet returner"
    echo 
    echo "USAGE:" 
    echo "  sequasta.sh --infile \$FASTA --range \$START,\$STOP"
    echo "  sequasta.sh --range \$START,\$STOP < \$FASTX"

    echo "-i, --infile      input sequence, default: stdin"
    echo "-r, --range       start and stop coordinate of desired snippet; inclusive; 0-based; comma-separated"
    exit 1
}

processfile () {
    if [[ -f "$1" ]]; then
        fastx="$(grep -i ">" "$1")"
    else 
        if [[ "${1:0:1}" == ">" ]]; then
            fastx="FASTX"
        fi
    fi
    if [ "$fastx" == "" ]; then
        echo "$1"
    else
        SEQ=""
        if [[ $fastx == "FASTX" ]]; then
            while IFS='\n' read -ra ADDR; do
                for i in "${ADDR[@]}"; do
                    if [[ ! "${i:0:1}" == ">" ]]; then
                        SEQ="$SEQ$i"
                    fi
                done
            done <<< "$1"
        else
            SEQ=$(tail -n +2 "$1" | tr --delete '\n')
        fi
        if [[ $SEQ =~ ^[ARNDCEQGHILKMFPSTWYVX\-]*$ ]]; then #[[ $SEQ =~ ^[ACGT\-]*$ ]] || [[ $SEQ =~ ^[ACGU\-]*$ ]] ||
            echo $SEQ
        else
            echo "FALSE!"
        fi
    fi
} 

while (( "$#" )); do
    case "$1" in
    -i|--infile)
        if [ -n "$2" ] && [ -f "$2" ] && [ ${2:0:1} != "-" ]; then
            SEQUENCE=$(processfile $2)
            if [[ $SEQUENCE == "FALSE!" ]]; then
                echo "Neither a genomic nor a protein sequence!"
                usage
            fi
            shift 2
        else
            echo "Error: Argument for $1 is missing" >&2
            exit 1
        fi
        ;;
    -r|--range)
        if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
            IFS=',' read -a RANGE <<< "$2" 
            START="${RANGE[0]}"
            STOP="${RANGE[1]}"
            shift 2
        else
            echo "Error: Argument for $1 is missing" >&2
            exit 1
        fi
        ;;
    -*|--*=) # unsupported flags
        echo "Error: Unsupported flag $1" >&2
        exit 1
        ;;
    *) # preserve positional arguments
        PARAMS="$PARAMS $1"
        shift
        ;;
  esac
done

eval set -- "$PARAMS"

if [[ $START == "" ]] || [[ $STOP == "" ]]; then
    echo "Missing coordinates!"
    usage
fi

if [[ $SEQUENCE == "" ]]; then
    SEQ=$(cat -)
    SEQUENCE="$(processfile "$SEQ")"
fi

if [[ $SEQUENCE == "" ]]; then
    echo "Missing Sequence!"
    usage
fi

LENGTH_RANGE="$(($STOP-$START+1))"
LENGTH_SEQUENCE=${#SEQUENCE}
HELPER_LENGTH="$((LENGTH_SEQUENCE-2))"

if (( $START > $HELPER_LENGTH )); then
    echo "Range exceeds sequence length!"
    exit 1
else
    if (( $STOP > $LENGTH_SEQUENCE )); then
        echo "End of Range exceeds sequence length."
        echo "Sequence from $START to end of sequence printed."
    fi
    echo "${SEQUENCE:START:STOP}"
fi
