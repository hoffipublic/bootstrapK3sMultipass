#!/usr/bin/env bash
ranOrSourced=$([[ $_ != $0 ]] && echo "source" || echo -n "exec") # has to be first line of script
TRACING+=("code/30-bootstrapK3s/bootstrapK3sCommon.sh")
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${SCRIPTDIR}/$(backToRepoDir "${TRACING[-1]}")/lib/00_init.sh" "$@"
TRACE "${ranOrSourced} ${TRACING[-1]} $* ..."
## ===========================================================================

bootstrapK3sBaseDir="code/30-bootstrapK3s/${targetEnvSmallCaps}"
source "${bootstrapK3sBaseDir}/bootstrapK3s${targetEnv}.sh"

# spin up K3s master
call multipass exec "${K3SNODES[0]}" -- /bin/bash -c "curl -sfL -C - https://get.k3s.io | sh -"
K3SNODEIP_MASTER="${K3SNODEIPS[0]}"

# get kube config k3s.yml file
INFOHIGHLIGHT "spinning up K8s Master ${K3SNODES[0]} at ${K3SNODEIPS[0]}"
call multipass exec "${K3SNODES[0]}" -- bash -c 'sudo cat /etc/rancher/k3s/k3s.yaml' > "${TMPDIR}/k3s.yaml"
sed -i'.orig' -e "s/127.0.0.1/${K3SNODES[0]}/g" "${TMPDIR}/k3s.yaml"
if [[ -z $HOST_KUBECONFIG_FILE ]]; then
    export KUBECONFIG="${REPODIR}/${TMPDIR}/k3s.yml"
else
    set +e
    mv "${HOME}/.kube/config" "${HOME}/.kube/config.backup-${FILEPOSTFIX_STARTDATETIME}" > /dev/null 2>&1
    set -e
    cp "${TMPDIR}/k3s.yaml" "${HOST_KUBECONFIG_FILE}"
fi

# get k3s root_ca
mkdir -p "${K3S_CLUSTER_ROOTCA%/*}"
call kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 -d > "${K3S_CLUSTER_ROOTCA}"

# Get the TOKEN from the master node
K3S_TOKEN="$(call multipass exec "${K3SNODES[0]}" -- /bin/bash -c "sudo cat /var/lib/rancher/k3s/server/node-token")"
if [[ -z ${K3S_TOKEN} || ${K3S_TOKEN} =~ ^.*\ .*$ ]]; then
    FATAL "couldn't get K3S_TOKEN:  K3S_TOKEN=${K3S_TOKEN} (check DNS lookup (e.g. dnsmasq and/or /etc/rosolv.conf /etc/systemd/resolved.conf is/are configured correctly)"
    exit 1
fi

# wait for master being up
if [[ ${#K3SNODES[@]} -gt 1 ]]; then
    kubewaitPodRunning -n "kube-system" -l app.kubernetes.io/name=traefik 'traefik-.*' 5 5 20 1 # initial:5 between:5 times:20 after:1
fi

# Deploy k3s on the worker nodes (all but the first in NODES array)
for (( i=1; i<${#K3SNODES[@]}; i++ )); do
    INFOHIGHLIGHT "spinning up K8s slave $i ${K3SNODES[$i]} at ${K3SNODEIPS[$i]}"
    call multipass exec "${K3SNODES[$i]}" -- /bin/bash -c "curl -sfL -C - https://get.k3s.io | K3S_TOKEN=${K3S_TOKEN} K3S_URL=https://${K3SNODEIP_MASTER}:6443 sh -"
done
call sleep 7

call kubectl taint node "${K3SNODES[0]}" --overwrite node-role.kubernetes.io/master=effect:NoSchedule
for (( i=1; i<${#K3SNODES[@]}; i++ )); do
    call kubectl label node "${K3SNODES[$i]}" --overwrite node-role.kubernetes.io/node=
done
call sleep 3

kubectl get nodes -o wide

kubewaitPodRunning -n "kube-system" -l app.kubernetes.io/name=traefik 'traefik-.*' 5 5 20 1 # initial:5 between:5 times:20 after:1


## ===========================================================================
TRACE "code/30-bootstrapK3s/bootstrapK3sCommon.sh done."