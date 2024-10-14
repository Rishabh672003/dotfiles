#! /usr/bin/env sh
# this is a example of .lessfilter, you can change it
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
elif [ "$kind" = vnd.openxmlformats-officedocument.spreadsheetml.sheet ] ||
	[ "$kind" = vnd.ms-excel ]; then
	in2csv "$1" | xsv table | bat -ltsv --color=always
elif [ "$category" = text ]; then
	bat --color=always -pp "$1"
elif [ "$kind" = json ]; then
	if has_cmd jupyter bat && [ "$ext" = ipynb ]; then
		jupyter nbconvert --to python --stdout "$1" | bat --color=always -plpython
	elif has_cmd jq; then
		jq -Cr . "$1"
	fi
elif [ "$kind" = vnd.sqlite3 ]; then
	if has_cmd yes sqlite3 bat; then
		yes .q | sqlite3 "$1" | bat --color=always -plsql
	fi
elif [ "$kind" = pdf ]; then
	if has_cmd pdftotext sed; then
		pdftotext -q "$1" - | sed "s/\f/$(hr ─)\n/g"
	fi
elif [ "$kind" = rfc822 ]; then
	if has_cmd bat; then
		bat --color=always -lEmail "$1"
	fi
elif [ "$category" = image ]; then
	if has_cmd chafa; then
		chafa -f symbols "$1"
	fi
	if has_cmd exiftool; then
		exiftool "$1" | bat --color=always -plyaml
	fi
else
	exit 1
fi
