# sequasta

A simple tool for obtaining a given sub-seequence of an input. The input can either be a FASTA file, sequence via stdin, and FASTA via stdin. Required are the start and stop coordinate of the substring. The values are considered as 0-based and inclusive. <br>
Allowed input sequences are DNA, RNA, or proteins. 

## Example

    cat $FASTA
        > >Test
        > ACTGATCGACTAGCACTGACTA
        > ACTAGCTAGCATCAGCTAGCAT
        > ACTGTAGCATCGACT

    sequasta --range 5,10 --infile $FASTA
        > TCGACTAGCA

Analog calls:

    sequasta --range 5,10 < $FASTA
    cat $FASTA | sequasta --range 5,10

Also:

    SEQ="ACGACTAGCATCGACTAG"

    echo $SEQ | sequasta --range 5,10
        > TAGCATCGAC

## Usage
    sequasta.sh --infile $FASTA --range $START,$STOP

    -i, --infile      input sequence, default: stdin
    -r, --range       start and stop coordinate of desired snippet; inclusive; 0-based; comma-separated
 