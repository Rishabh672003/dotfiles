#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Info:
#   Original author:    Miroslav Vidovic
#   This is my version
#   file:      books-search.sh
# Script:

# Books directory
BOOKS_DIR=~/Library/

# Save find result to F_ARRAY
readarray -t F_ARRAY <<<"$(find "$BOOKS_DIR" -type f \( -name '*.pdf' -o -name '*.epub' \))"

# Associative array for storing books
# key => book name
# value => absolute path to the file
declare -A BOOKS

# Add elements to BOOKS array
get_books() {
	if [[ -n ${F_ARRAY[*]} ]]; then
		for i in "${!F_ARRAY[@]}"; do
			path=${F_ARRAY[$i]}
			file=$(basename "${F_ARRAY[$i]}")
			BOOKS+=(["$file"]="$path")
		done
	else
		echo "$BOOKS_DIR is empty!"
		echo "Please put some books in it."
		echo "Only .pdf and .epub files are accepted."
		exit
	fi
}

# List for rofi
gen_list() {
	for i in "${!BOOKS[@]}"; do
		echo "$i"
	done
}

main() {
	get_books
	book=$( (gen_list) | rofi -dmenu -i -matching normal -no-custom -location 0 -p "  ")

	if [ -n "$book" ]; then
		echo "$book" | sed -e "s/^.... - //" -e "s/\ .*//" | wl-copy
		# Check the extension of the file
		extension=${book##*.}
		if [ "$extension" == "pdf" ]; then
			evince "${BOOKS[$book]}"
		elif [ "$extension" == "epub" ]; then
			foliate "${BOOKS[$book]}"
		fi
	fi
}

main

exit 0
