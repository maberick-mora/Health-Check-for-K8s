# Health-Check-for-k8s
Health Check for k8s

This repository contains a shell script for performing a comprehensive health check on an OpenShift cluster. It collects diagnostic data such as pod status, route health, namespace verification, and node resource usage, and logs the output into a timestamped log file for auditing or troubleshooting purposes.

📄 Features

✅ Collects a full list of pods across all namespaces.

❌ Detects and lists failed or problematic pods (Error, CrashLoopBackOff, etc.).

🌐 Verifies routes in namespaces ending with -manage (excluding db2u-manage).

🚫 Detects manage namespaces with no routes.

📈 Displays top nodes by CPU and Memory usage.

🗂️ Outputs everything to a log file named:
Health_Check_<Cluster>_<timestamp>.log

📋 Prerequisites

Access to an OpenShift cluster.

Tools required:

oc CLI (oc get, oc top)

kubectl CLI

jq

curl

Appropriate RBAC permissions to read pods, namespaces, routes, and node metrics.

🛠️ Usage

Set the Cluster variable before running the script:

Cluster="my-cluster-name"


Run the script:

./health_check.sh


All output will be saved in a file like Health_Check_my-cluster-name_2025-10-21-14-00.log.

🧠 What It Checks
Check	Description
Pod Overview	Lists all pods across namespaces with detailed status
Failed Pods	Filters pods with non-healthy status patterns
Manage Routes	Ensures that *-manage namespaces have valid routes and reachable hosts
Route Availability Check	Validates application response from each route
Missing Routes Warning	Detects *-manage namespaces with no routes configured
Top Node Resource Usage	Sorts and displays nodes by CPU and Memory usage
