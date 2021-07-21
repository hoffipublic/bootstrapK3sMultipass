
# from https://github.com/UrsaDK/getopts_long
# shellcheck disable=SC1091
source "${REPODIR}/lib/getopts_long/getopts_long.bash"

# e.g.: ./test.sh --all -bx --file=filepath/name.sh -g otherfile.sh -- eins "zwei drei" vier
cmdLineOptsShort=() ; cmdLineOptsLong=()
cmdLineOptsShort+=('a')  ; cmdLineOptsLong+=('all') ; OPT_ALL=false # docs for arg
cmdLineOptsShort+=('b')  ; cmdLineOptsLong+=('beta') ; OPT_BETA=false # docs for arg
cmdLineOptsShort+=('C')  ; cmdLineOptsLong+=('no-color') ; OPT_NO_COLOR=false # docs for arg
cmdLineOptsShort+=('f:') ; cmdLineOptsLong+=('file:') ; OPT_FILE="default" # docs for arg
cmdLineOptsShort+=('g:') ; cmdLineOptsLong+=('gfile:') ; OPT_GFILE="default" # docs for arg
cmdLineOptsShort+=('x') ; OPT_X=false # docs for arg

SHORTOPTSPEC=$(printf '%s\n' "$(IFS=''; printf '%s' "${cmdLineOptsShort[*]}")") # concat array elements without space
LONGOPTSPEC="${cmdLineOptsLong[*]}" # concat array elements with space
while getopts_long ":$SHORTOPTSPEC $LONGOPTSPEC" OPTKEY; do
    case ${OPTKEY} in
        'a'|'all')
            echo 'all triggered'
            OPT_ALL=true
            ;;
        'b'|'beta')
            echo 'beta triggered'
            OPT_BETA=true
            ;;
        'C'|'no-color')
            echo 'no-color triggered'
            OPT_NO_COLOR=true
            ;;
        'f'|'file')
            echo "supplied --file ${OPTARG}"
            if [[ ! -s ${OPTARG} ]]; then
                echo "--file ${OPTARG} does not exist or has zero size" >&2
                exit 1
            else
                OPT_FILE="${OPTARG}"
            fi
            ;;
        'g'|'gfile')
            echo "supplied --gfile ${OPTARG}"
            OPT_GFILE="${OPTARG}"
            ;;
        'x')
            echo 'x triggered'
            OPT_X=true
            ;;
        '?')
            echo "INVALID OPTION: ${OPTARG}" >&2
            exit 1
            ;;
        ':')
            echo "MISSING ARGUMENT for option: ${OPTARG}" >&2
            exit 1
            ;;
        *)
            echo "UNIMPLEMENTED OPTION: ${OPTKEY}" >&2
            exit 1
            ;;
    esac
done

shift $(( OPTIND - 1 ))
set +u
[[ "${1}" == "--" ]] && shift
set -u

ARGS=( "$@" )