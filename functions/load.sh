# s.load.yaml arg1
# load an yaml file and set environments with "s_config_" prefix
# generates a warning if yaml file is not found
# Thanks to https://github.com/pkuczynski
function s.load.yaml() {
	test -z "$*" && return
	s.check.requirements? sed awk
	if [ ! -s "$1" ]; then
		s.print.log debug "YAML file not found"
		return 2
	fi
	local prefix="s_config_"
	local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
	sed -ne "s|^\($s\):|\1|" \
		-e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
		-e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
	awk -F$fs '{
			indent = length($1)/2;
			vname[indent] = $2;
			for (i in vname) {if (i > indent) {delete vname[i]}}
			if (length($3) > 0) {
				vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
				printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
			}
	}'
}

