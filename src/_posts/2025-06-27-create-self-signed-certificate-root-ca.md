---
title: "Create a Self-Signed Certificate with Your Own Root CA"
author: DevilDogTG
date: 2025-06-27 08:00:00 +0700
categories: [System Administrator, Certificates]
tags: [certificates, security, ssl, openssl, self-signed, root ca]
---

For internal use within local labs or a company, self-signed certificates can be used — but browsers will mark them as insecure. This guide shows how to create a trusted self-signed certificate by using your own Root CA.

## Create Your Own Root CA

The root CA is the key to solving the trust problem. You import your root CA certificate on your machines, and all certificates signed by it will be trusted.

Generate the root CA key and certificate (valid for 5 years):

```bash
openssl genrsa -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key -days 1825 -out rootCA.crt -config rootSSL.conf -extensions req_ext
```

> **Important:** The `rootCA.key` file is critical. Anyone with this file can generate trusted certificates. Keep it secure.

## Trust Your Root CA

You'll get a `rootCA.crt` file. Import it to trust all certificates signed by your root CA.

**Windows:** Double-click the `.crt` file and import it to the Trusted Root Certificate Authorities store.

**Linux:**

```bash
cp rootCA.crt /usr/local/share/ca-certificates/
update-ca-certificates --fresh
```

## Create a Certificate Using Your Root CA

**Step 1** — Generate a certificate request (CSR):

```bash
openssl genrsa -out certificate.key 4096
openssl req -new -key certificate.key -out certificate.req -config certificate.conf -nodes
```

**Step 2** — Sign the certificate with your root CA:

```bash
openssl x509 -req -in certificate.req -CA rootCA.crt -CAkey rootCA.key -out certificate.crt -days 1095
```

Use `certificate.crt` and `certificate.key` to install on your server or site.

## Example Configuration File

Use this as `certificate.conf` when generating the CSR:

```conf
[req]
distinguished_name = distinguished_name
req_extensions = req_ext
prompt = no

[distinguished_name]
C = TH
ST = Nonthaburi
L = Bang Yai
O = example
OU = OnPrem
CN = vip.example.local

[req_ext]
keyUsage = keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = vip.example.local
DNS.2 = vip-01.example.local
DNS.3 = vip-02.example.local
```
