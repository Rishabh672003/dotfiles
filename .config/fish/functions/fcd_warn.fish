function fcd_warn -d "Echo to STDERR"
	set -l options 'e/error' 'w/warn' 'i/info' 'h/help'

	set -l error 0
	set -l color (set_color normal)

	argparse $options -- $argv

	if set -q _flag_help
		echo "Output to STDERR"
		echo "Options:"
		echo "  -e, --error   Error level message"
		echo "  -w, --warn    Warning level message"
		echo "  -i, --info    Info level message"
		return
	end

	if set -q _flag_error
		set color (set_color -b brred brwhite)
	else if set -q _flag_warn
		set color (set_color -b bryellow black)
	else if set -q _flag_info
		set color (set_color brgreen)
	end
	set -l prompt (set_color bryellow)
	printf '%s>%s %s%s%s\n' $prompt $prompt $color "$argv" (set_color normal) >&2
end
