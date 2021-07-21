# bash boilerplate project

goals:

- able to "chunk" scripts into smaller peaces which may source each other (do not execute, but source them)
- decent (colorfull) logging for bash
- decent cmd line args/opts parsing (with support of `getopts_long`)
- use yaml templating tool ytt to deal with YAML files and configurations
- use ytt (vmware <https://carvel.dev/ytt/>) for YAML templating
- use jq to deal with JSON files
- use yq (golang version) to convert json to yaml

## Dependencies

- bash version 4 (won't work with bash 3)
- ytt (<https://carvel.dev/ytt/>)
- jq json-query tool (<https://github.com/stedolan/jq>)
- golang implementation of yq (<https://github.com/mikefarah/yq>)

## running with specific log level

LOGLEVEL=DEBUG run/test.sh

