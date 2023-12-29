if functions -q __fuzzy_cd
	if test -d ~/.marks && test (which fasd)
		if not functions -q __fuzzy_wrapped_cd
			functions -c cd __fuzzy_wrapped_cd
		end
		functions -e cd
		functions -c __fuzzy_cd cd
	end
end
