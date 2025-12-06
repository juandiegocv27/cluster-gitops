# Argo CD access (Talos local cluster)

## Initial admin password

Get the initial admin password:

```
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo

You should change this password after the first login and store it in your password manager.
```

Web UI
```
	•	URL: http://192.168.100.82:30880
	•	Username: admin
	•	Password: <admin-password-from-command>
```

CLI
```
argocd login 192.168.100.82:30880 \
  --username admin \
  --password <admin-password-from-command-or-password-manager> \
  --insecure
 ```

