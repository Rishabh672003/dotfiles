#! /usr/bin/env sh
has_cmd() {
    for opt in "$@"; do
        command -v "$opt" >/dev/null
    done
}
mime=$(file -bL --mime-type "$1")
category=${mime%%/*}
kind=${mime##*/}
ext=${1##*.}

if [ -d "$1" ]; then
    exa --color always --icons -1abh -s name --git --sort date --group-directories-first "$1"
elif [ "$category" = text ]; then
    if head -c 1024 "$1" | grep -q "[[:cntrl:]]"; then
        echo "Binary input in text file"
        exit 1
    fi
    bat --color=always -pp "$1"
elif [ "$kind" = vnd.openxmlformats-officedocument.spreadsheetml.sheet ] ||
    [ "$kind" = vnd.openxmlformats-officedocument.wordprocessingml.document ] ||
    [ "$kind" = vnd.openxmlformats-officedocument.presentationml.presentation ] ||
    [ "$kind" = vnd.ms-excel ]; then
    bcat "$1" --paging never -t catppuccin
elif [ "$kind" = json ]; then
    if has_cmd jq; then
        jq -Cr . "$1"
    fi
elif [ "$kind" = pdf ]; then
    if has_cmd pdftotext sed; then
        pdftotext -q "$1" -
    fi
elif [ "$category" = image ]; then
    if has_cmd chafa; then
        chafa -f symbols "$1"
    fi
    if has_cmd exiftool; then
        exiftool "$1" | bat --color=always -plyaml
    fi
elif file -bL --mime-encoding "$1" | grep -q binary; then
    echo "Binary file not for preview"
    exit 1
else
    exit 1
fi
