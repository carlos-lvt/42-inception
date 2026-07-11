FROM debian:bookworm

# openssl: to generate my TLS certificate
RUN apt-get update && apt-get install -y nginx openssl \
		&& rm -rf /var/lib/apt/lists/*

# /etc/nginx/ssl: folder where the cert + key will live
# -x509: no real CA to sign this, so skip the CSR step and
#        self-sign the cert directly (browser will warn, that's expected)
# -nodes: don't password-protect the key, or nginx would ask
#         for it every time the container starts
# -days 365: how long the cert stays valid (1 year)
# -newkey rsa:2048: generate a fresh 2048-bit private key too
# -keyout: where to save the private key
# -out: where to save the public certificate
# -subj: fill Country/State/Locality/Org/CommonName without
#        the interactive prompt (CN must match my domain)
RUN mkdir -p /etc/nginx/ssl \
		&& openssl req -x509 -nodes -days 365 \
			-newkey rsa:2048 \
			-keyout /etc/nginx/ssl/inception.key \
			-out /etc/nginx/ssl/inception.crt \
			-subj "/C=PT/ST=PORTO/L=PORTO/O=42/CN=carlaugu.42.fr"

COPY conf/nginx.conf /etc/nginx/sites-available/default

EXPOSE 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]