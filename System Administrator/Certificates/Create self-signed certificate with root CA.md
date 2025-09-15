---
layout: default
---
# Create a self-signed certificate with your own root CA

For internal use within local labs and company self-signed certificate can be used, but it will be marked as insecure. This blog will guide you to use self-signed certificate for internal use without marked with insecure.

## Create you own root CA

This it key to solved problem, root CA will use to signed all of your certificate and you need to import root CA certificate on your machine to mark them know each other as secured.

To generate root CA key use:

```bash
openssl genrsa -out rootCA.key 4096
# Update expired time as you need in this example will be valid for 5 years
openssl req -x509 -new -nodes -key rootCA.key -days 1825 -out rootCA.crt -config rootSSL.conf -extensions req_ext
```

Please note: this file is very important because you can use this file to generate certificate and your devices will be trust certificate generate from this key.

## Trust your root CA

In previous step you get `rootCA.crt` file. This is your root certificate. Use `rootCA.crt` to trust all certificate generate from your root CA

For windows system: double click on `.crt` file and select import to trust root store

For linux system:

```bash
cp rootCA.crt /usr/local/share/ca-certificates/
update-ca-certificates --fresh
```

## Create certificate using root CA key

Then we need to generate self-signed certificate to install each node you need. We're has 2 more step

1. Generate certificate request

    Normally, this file will sent to CA in order to obtain certificate. But in our case, we'll create with our root CA

    ```bash
    # Generate key for new certificate
    openssl genrsa -our certificate.key 4096
    openssl req -new -key certificate.key -out certificate.req -config certificate.conf -nodes
    ```

2. Create certificate from csr

    using command to create your own certificate:

    ```bash
    openssl x509 -req -in certificate.req -CA rootCA.crt -CAkey rootCA.key -out certificate.crt -days 1095
    ```

Use certificate to install your site or server as you need.

### Example configure file

Here is some example certificate configure file using in generate csr step

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
