#!/usr/bin/env bash
ranOrSourced=$([[ $_ != $0 ]] && echo "source" || echo -n "exec") # has to be first line of script
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TRACING+=("code/10-bootstrapInfra/localK3s/bootstrapInfraCommonCommon.sh")
source "${SCRIPTDIR}/$(backToRepoDir "${TRACING[-1]}")/lib/00_init.sh" "$@"
TRACE "${ranOrSourced} ${TRACING[-1]} $* ..."
## ===========================================================================

COMMONNODECOUNT=$1
COMMONNODENAMEPREFIX=$2


YTT_TEMPLATE="cloud-config_CommonNodes.yml"
YTT_FILES=( \
    "${GENCONFDIR}/ytt/conf.yml" \
    "${SCRIPTDIR}/ytt/templates/${YTT_TEMPLATE}"
)
YTT_OPTS=""
YTT_RESULT=$(callYtt)
#mkdir -p "${GENYTTDIR}"
echo "${YTT_RESULT}"
echo "${YTT_RESULT}" > "${GENYTTDIR}/${YTT_TEMPLATE}"

# NODE01=$(printf "${COMMONNODENAMEPREFIX}%02d" 1)
#  multipass ls --format json | jq -r '.list[] | select(.name == "node01").name'
# multipass ls --format json | jq -r ".list[] | select(.name == \"$NODE01\").name"

FORMERNODESTATE=()
# Create or start hyper-V VMs
if [[ $COMMONNODECOUNT -le 1 ]]; then
    SLEEP=true
    CURRNODE=$(printf "${COMMONNODENAMEPREFIX}%02d" 1)
    CURRNODESTATE=$(multipass ls --format json | jq -r ".list[] | select(.name == \"${CURRNODE}\").state")
    if [[ $CURRNODESTATE = "Stopped" ]]; then
        INFOHIGHLIGHT "starting single ${CURRNODE} ${MULTIPASSBASEOS} VM"
        FORMERNODESTATE+=("done")
        call multipass start "$CURRNODE"
    elif [[ $CURRNODESTATE = "Running" ]]; then
        INFOHIGHLIGHT "VM ${CURRNODE} already up and running"
        FORMERNODESTATE+=("done")
        SLEEP=false
    else
        INFOHIGHLIGHT "creating single ${CURRNODE} VM from ${MULTIPASSBASEOS}"
        FORMERNODESTATE+=("fresh")
        call multipass launch --name "${CURRNODE}" --cpus 4 --mem 6G --disk 15G --cloud-init "${GENYTTDIR}/${YTT_TEMPLATE}" "${MULTIPASSBASEOS}"
    fi
else
    for (( i=1; i<=$COMMONNODECOUNT; i++ )); do
        SLEEP=false
        CURRNODE=$(printf "${COMMONNODENAMEPREFIX}%02d" "$i")
        CURRNODESTATE=$(multipass ls --format json | jq -r ".list[] | select(.name == \"${CURRNODE}\").state")
        if [[ $CURRNODESTATE = "Stopped" ]]; then
            INFOHIGHLIGHT "starting ${CURRNODE} ${MULTIPASSBASEOS} VM"
            SLEEP=true
            FORMERNODESTATE+=("done")
            call multipass start "$CURRNODE"
        elif [[ $CURRNODESTATE = "Running" ]]; then
            INFOHIGHLIGHT "VM ${CURRNODE} already up and running"
            FORMERNODESTATE+=("done")
        else
            INFOHIGHLIGHT "creating $i (of ${COMMONNODECOUNT}) ${CURRNODE} VM from ${MULTIPASSBASEOS}"
            SLEEP=true
            FORMERNODESTATE+=("fresh")
            call multipass launch --name "${CURRNODE}" --cpus 2 --mem 2G --disk 5G --cloud-init "${GENYTTDIR}/${YTT_TEMPLATE}" "${MULTIPASSBASEOS}"
        fi
    done
fi
# Wait a few seconds for nodes to be up
if $SLEEP; then call sleep 2 ; fi

# get node names and their ips
COMMONNODES=()
COMMONNODEIPS=()
for (( i=1; i<=$COMMONNODECOUNT; i++ )); do
    CURRNODE=$(printf "${COMMONNODENAMEPREFIX}%02d" "$i")
    COMMONNODES+=( $CURRNODE )
    CURRNODEIP=$(multipass ls --format json | jq -r ".list[] | select(.name == \"${CURRNODE}\").ipv4[0]")
    COMMONNODEIPS+=( $CURRNODEIP )
done
nodesAndIps=""
for (( i=1; i<=$COMMONNODECOUNT; i++ )); do
    nodesAndIps="${nodesAndIps} $(printf "${COMMONNODENAMEPREFIX}%02d" "$i"):${COMMONNODEIPS[((i-1))]}"
done
INFO all nodes: $nodesAndIps

# write to tmp/${targetEnv}/hosts and sudo /etc/hosts
TMPFILE="${TMPDIR}/hosts"
TMPFILE2="/etc/hosts"
touch "${TMPFILE}"
fileAppendSentinelsIfAbsent "${TMPFILE}"
sudoFunc fileAppendSentinelsIfAbsent "${TMPFILE2}"
for (( i=0; i<COMMONNODECOUNT; i++ )); do
    CURRNODE="${COMMONNODES[$i]}"
    CURRNODEIP="${COMMONNODEIPS[$i]}"
    if fileLineExistsBetweenSentinels " ${CURRNODE}" "${TMPFILE}"; then
        fileDeleteLinesBetweenSentinels " ${CURRNODE}" "${TMPFILE}"
    fi
    fileAppendBetweenSentinels "${CURRNODEIP} ${CURRNODE}" "${TMPFILE}"
    if fileLineExistsBetweenSentinels " ${CURRNODE}" "${TMPFILE2}"; then
        sudoFunc fileDeleteLinesBetweenSentinels " ${CURRNODE}" "${TMPFILE2}"
    fi
    sudoFunc fileAppendBetweenSentinels "${CURRNODEIP} ${CURRNODE}" "${TMPFILE2}"
done
if [[ $USING_DNSMASQ_ON_HOST = "true" ]]; then
TMPFILE="/usr/local/etc/dnsmasq.conf"
fileAppendSentinelsIfAbsent "${TMPFILE}"
for (( i=0; i<COMMONNODECOUNT; i++ )); do
    CURRNODE="${COMMONNODES[$i]}"
    CURRNODEIP="${COMMONNODEIPS[$i]}"
    if ! fileLineExistsBetweenSentinels "^address=/${CURRNODE}/${CURRNODEIP}" "${TMPFILE}"; then
        if fileLineExistsBetweenSentinels " ${CURRNODE}" "${TMPFILE}"; then
            sudoFunc fileDeleteLinesBetweenSentinels " ${CURRNODE}" "${TMPFILE}"
        fi
        sudoFunc fileAppendBetweenSentinels "address=/${CURRNODE}/${CURRNODEIP}" "${TMPFILE}"
    fi
done
sudo brew services restart dnsmasq
fi

# multipass cloud-init does not support packages module yet
# but bootcmd: of cloud-init works!
for (( i=0; i<COMMONNODECOUNT; i++ )); do
    CURRNODE="${COMMONNODES[$i]}"
    if [[ ${FORMERNODESTATE[$i]} != "fresh" ]]; then
        INFO "$CURRNODE already configured"
        multipass exec "${CURRNODE}" -- bash +e -x -c "
            set +x
            echo -e \"\\n\"
            echo -e \"informational for $CURRNODE:\"
            uname -a
            echo
            cat /etc/systemd/resolved.conf
            echo
            tail /etc/hosts
            echo
            tail ~/.ssh/authorized_keys
            echo
            for checkVersion in ${packagesCmdVersion[*]}; do echo \"\\\$ \$checkVersion\" ; \$checkVersion ; done
        "
    else
        INFO "configuring $CURRNODE:"
        multipass exec "${CURRNODE}" -- bash +e -x -c "
            sudo apt update
            sudo apt install -y ${aptPackages[*]}
            sudo snap install ${snapPackages[*]}
            if fzf --version >/dev/null 2>&1 ; then echo \"source /usr/share/doc/fzf/examples/key-bindings.bash\" >> /home/ubuntu/.bashrc ; fi
            sudo chown ubuntu:ubuntu /etc/hosts
            echo -e \"\\n#$0 $(date)\" >> /etc/hosts
            COMMONNODES=( ${COMMONNODES[*]} )
            COMMONNODEIPS=( ${COMMONNODEIPS[*]} )
            for (( i=0; i<$COMMONNODECOUNT; i++ )); do echo -e \"\${COMMONNODEIPS[\$i]} \${COMMONNODES[\$i]}\" >> /etc/hosts ; done
            echo -e \"$(cat ~/.ssh/id_rsa.pub)\" >> /home/ubuntu/.ssh/authorized_keys
            # TODO add self-signed cert to /usr/local/share/ca-certificates/ or /etc/ssl/certs/
            #
            set +x
            echo -e \"\\n\"
            echo -e \"informational for $CURRNODE:\"
            uname -a
            echo
            cat /etc/systemd/resolved.conf
            echo
            tail /etc/hosts
            echo
            tail ~/.ssh/authorized_keys
            echo
            for checkVersion in ${packagesCmdVersion[*]}; do echo \"\\\$ \$checkVersion\" ; \$checkVersion ; done
        "
    fi
done


## ===========================================================================
TRACE "code/10-bootstrapInfra/localK3s/bootstrapInfraCommonCommon.sh done."