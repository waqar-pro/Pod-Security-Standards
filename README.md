# Pod Security Standards - Kubernetes 

![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Security](https://img.shields.io/badge/Security-Hardening-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)

## Overview

This work demonstrates how to implement and enforce **Pod Security Standards (PSS)** in Kubernetes. Pod Security Standards define different isolation levels for Pods to restrict what they can do at the namespace level.

---

## Security Levels

| Level | Description |
|-------|-------------|
| 🔴 **Privileged** | No restrictions — full access |
| 🟡 **Baseline** | Blocks most critical vulnerabilities |
| 🟢 **Restricted** | Maximum security enforcement |

---

## Lab Tasks Completed

### Task 1: Cluster Setup
- Explored current cluster configuration
- Created `baseline-test` and `restricted-test` namespaces
- Verified Pod Security Standards API availability

### Task 2: Baseline Policy
- Applied Baseline security labels to namespace
- Deployed compliant pod successfully
- Blocked privileged pod deployment
- Blocked host network access
- Blocked hostPath volume mounts

### Task 3: Security Context Testing
- Tested various security contexts
- Verified host network restrictions
- Verified volume mount restrictions

### Task 4: Restricted Policy
- Applied Restricted security labels to namespace
- Demonstrated that Baseline-compliant pods fail Restricted policy
- Deployed fully compliant pod with all required settings

### Task 5: Policy Comparison
- Deployed same workload to both namespaces
- Analyzed policy violation events
- Compared enforcement behavior

### Task 6: Secure Application Template
- Created production-ready secure deployment
- Implemented all security best practices
- Deployed with resource limits and health checks

---

## Key Concepts

### Namespace Labels
```bash
kubectl label namespace my-namespace \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted
```

### Required Settings for Restricted Policy
```yaml
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      capabilities:
        drop:
        - ALL
```

---

## Test Results

### Baseline Namespace
| Pod Configuration | Result |
|------------------|--------|
| Compliant pod | ✅ Allowed |
| Privileged pod | ❌ Blocked |
| Host network pod | ❌ Blocked |
| HostPath volume pod | ❌ Blocked |

### Restricted Namespace
| Pod Configuration | Result |
|------------------|--------|
| Baseline-compliant pod | ❌ Blocked (missing seccompProfile) |
| Fully compliant pod | ✅ Allowed |
| Secure web app deployment | ✅ Allowed |

---

## Security Best Practices

1. **Always set `runAsNonRoot: true`** — never run containers as root
2. **Drop ALL capabilities** — add only what is necessary
3. **Use `readOnlyRootFilesystem: true`** — prevent filesystem tampering
4. **Set `seccompProfile: RuntimeDefault`** — restrict system calls
5. **Set resource limits** — prevent resource exhaustion attacks
6. **Implement health checks** — liveness and readiness probes
7. **Never use `privileged: true`** — major security risk
8. **Avoid hostPath volumes** — can expose host filesystem
9. **Avoid hostNetwork** — can expose host network

---

## Commands Reference

```bash
# Apply security labels to namespace
kubectl label namespace <name> pod-security.kubernetes.io/enforce=restricted

# Check namespace labels
kubectl describe namespace <name>

# View policy violation events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Check pod security context
kubectl get pod <name> -o jsonpath='{.spec.securityContext}'

# Test permissions
kubectl auth can-i <verb> <resource> -n <namespace>
```

---

## Cleanup

```bash
kubectl delete pod --all -n baseline-test
kubectl delete pod --all -n restricted-test
kubectl delete deployment --all -n baseline-test
kubectl delete deployment --all -n restricted-test
kubectl delete service --all -n baseline-test
kubectl delete service --all -n restricted-test
kubectl delete namespace baseline-test restricted-test
```

---

## Key Takeaways

- Pod Security Standards are **built into Kubernetes** — no extra tools needed
- **Baseline** stops the most dangerous configurations
- **Restricted** enforces security best practices for production
- Security policies are enforced at the **namespace level**
- Always test pods against the target security policy before deploying to production

---

## Tools Used

- Kubernetes (Minikube)
- kubectl
- nginx:1.21-alpine (unprivileged)

---

*Lab completed as part of Kubernetes Security training at Al Nafi*
