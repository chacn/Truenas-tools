(echo "CONTENEDOR RED IP_INTERNA NOMBRES_DNS" && \
docker ps -q | xargs docker inspect --format '{{range $net, $conf := .NetworkSettings.Networks}}{{$.Name}} {{$net}} {{$conf.IPAddress}} {{printf "%v" $conf.Aliases}}{{println}}{{end}}' | sed 's/\///g') | column -t
