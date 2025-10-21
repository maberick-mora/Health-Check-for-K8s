if true; then
    initial_check_filename="Health_Check_${Cluster}_$(date +%Y-%m-%d-%H-%M).log"

    echo "======================================== $Cluster ======================================" | tee -a "${initial_check_filename}"
    date | tee -a "${initial_check_filename}"

    echo "*********************** Complete list of pods for $Cluster ***********************" | tee -a "${initial_check_filename}"
    oc get pods --all-namespaces -o wide 2>/dev/null | tee -a "${initial_check_filename}"

    echo -e "\n\n"

    echo "*********************** $Cluster Failed Pods Report ************************" | tee -a "${initial_check_filename}"
    oc get pods --all-namespaces -o wide 2>/dev/null \
      | grep -E "(Error|Terminating|Pending|CrashLoopBackOff|ErrImagePull|ImagePullBackOff|ContainerCreating|ContainerStatusUnknown|Init:)" \
      | tee -a "${initial_check_filename}"

    echo "################################ Manage Routes Status for $Cluster ##########################################" | tee -a "${initial_check_filename}"

    all_ns=$(oc get ns -o=custom-columns=NAME:.metadata.name --no-headers 2>/dev/null | grep -E '\-manage$' | grep -vi 'db2u-manage$')
    count_all=$(echo "$all_ns" | wc -l | tr -d ' ')
    echo "The result is ${count_all} MANAGE namespaces." | tee -a "${initial_check_filename}"

    echo "################################ Testing Routes in Manage Namespaces ##########################################" | tee -a "${initial_check_filename}"
    kubectl get routes --all-namespaces -o json 2>/dev/null \
      | jq -r '.items[] | select(.metadata.namespace as $ns | ($ns | test(".*manage$") and ($ns | test("db2u-manage") | not))) | .spec.host' \
      | grep 'main.manage' \
      | while read -r host; do
          curl -s "https://$host" | grep -q "The application or context root for this request has not been found" \
          && echo "✅ $host: OK" \
          || echo "❌ $host: No matches"
        done | nl | tee -a "${initial_check_filename}"

    ns_without_route=""
    for ns in $all_ns; do
      route_count=$(kubectl get routes -n "$ns" --no-headers 2>/dev/null | wc -l | tr -d ' ')
      if [ "$route_count" -eq 0 ]; then
        ns_without_route="${ns_without_route} $ns"
      fi
    done

    if [ -z "$ns_without_route" ]; then
        echo "All manage namespaces have at least one route assigned." | tee -a "${initial_check_filename}"
    else
        echo "Check manually; The following manage namespaces have no route assigned: ${ns_without_route}" | tee -a "${initial_check_filename}"
    fi

    echo "############################### Top Nodes by CPU Usage for $Cluster ###############################" | tee -a "${initial_check_filename}"
    sleep 1
    (kubectl top nodes 2>/dev/null | head -n1 && kubectl top nodes 2>/dev/null | tail -n +2 | sort -k3 -nr) | tee -a "${initial_check_filename}"

    echo -e "\n\n"

    echo "############################### Top Nodes by Memory Usage $Cluster ###############################" | tee -a "${initial_check_filename}"
    sleep 1
    (kubectl top nodes 2>/dev/null | head -n1 && kubectl top nodes 2>/dev/null | tail -n +2 | sort -k5 -nr) | tee -a "${initial_check_filename}"
fi
