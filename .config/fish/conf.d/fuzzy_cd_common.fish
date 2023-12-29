function fcd_install --on-event fuzzy_cd_install
	fcd_warn "fuzzy_cd: testing prerequisites"

	if not test -d ~/.marks
		fcd_warn -e "fuzzy_cd: jump doesn't appear to be installed. Please see https://github.com/oh-my-fish/plugin-jump"
		fcd_warn "......... if you have oh-my-fish installed, you can use `omf install jump`"
	else
		fcd_warn "......... jump is installed"
	end

	if not test (which fasd)
		fcd_warn -e "fuzzy_cd: fasd is not installed/available in PATH. Please install https://github.com/clvv/fasd"
		fcd_warn "......... if you're on a Mac and have Homebrew installed, you can use `brew install fasd`"
	else
		fcd_warn "......... fasd is available"
	end
end

function fcd_shortest_common
	set -l root $argv[1]
	set -l results $argv[1]
	set -e argv[1]
	for path in (fcd_return_array $argv | sort)
		if not test (string match "$root*" $path)
			set root $path
			set -a results $path
		end
	end
	fcd_return_array $results
end

function fcd_dir_to_regex
	echo (printf '%s' (echo "$argv"|sed -E 's/ +//g'|sed -E 's/(.)/\1[^\/]*/g'))
end

function fcd_dir_regex
	set -l section
	set -l regex (fcd_dir_to_regex $argv[1])
	for arg in $argv[2..-1]
		set section (fcd_dir_to_regex $arg)
		set regex "$regex/[^.]*$section"
	end
	echo $regex
end

function fcd_return_array -d 'Echo out an array one line at a time'
	for item in $argv
		echo $item
	end
end
