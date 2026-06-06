# Authentik Identity Provider Deployment

An **_Ansible role_** facilitates the **_identity provider deployment_** process for **_Authentik_** (_e.g.,_ KVM-IAM01), providing a centralized, secure authentication layer for the homelab.

## 1. Domain Controller LDAP Certificate Setup

1. Generate **_self-signed certificates_**:

- On `KVM-DC01` and `KVM-DC02`, open **_PowerShell as Administrator_** and execute:

  ```powershell
  New-SelfSignedCertificate -DnsName "kvm-dc01.khangvum.lab", "kvm-dc02.khangvum.lab" -CertStoreLocation "cert:\LocalMachine\My" -NotAfter (Get-Date).AddYears(5)
  ```

- Open **_Certificate Manager_** (`certlm.msc`):
  - Navigate to **Personal** > **Certificates**.
  - Copy the newly created certificate.
  - Navigate to **Trusted Root Certification Authorities** > **Certificates** and paste the certificate.

2. Export the **_root certificate_**:

- In **_Certificate Manager_** (`certlm.msc`), under **_Trusted Root Certification Authorities_**, locate the certificate.
- Right click > **All Tasks** > **Export...**
- Select **No, do not export the private key**.
- Choose **_Base-64 encoded X.509 (.CER)_** and save it as `dc_root.cer`.
- Transfer `dc_root.cer` to the management machine.

## 2. Authentik Source Integration

- In the **_Authentik Admin Interface_**, navigate to **_System_** > **_Certificates_**.
- Click **_Import Existing Certificate-Key Pair_**.
- Fill out the details:

  |     Property     | Value                                                                   |
  | :--------------: | :---------------------------------------------------------------------- |
  | Certificate Name | `AD-SelfSigned-Root`                                                    |
  |   Certificate    | Paste the text content of `dc_root.cer` (including `BEGIN`/`END` lines) |
  |   Private Key    | Leave empty                                                             |
