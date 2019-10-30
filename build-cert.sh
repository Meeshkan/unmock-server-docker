#!/usr/bin/env bash
# Usage: bash build.sh DOMAINS [TARGET_DIRECTORY]
# Example: bash build.sh api.github.com,petstore.swagger.io certs/

domains=$1
target_dir=$2

if [ -z ${domains} ];
then
  echo "Add domain names like this: bash prepare-cert.sh domain.io,domain.io2"
  exit 1
fi

if [ -z ${target_dir} ];
then
    target_dir="."
    echo "Writing to current directory"
else 
    if [ ! -d ${target_dir} ];
    then
        echo "Directory ${target_dir} does not exist."
        exit 1
    fi
fi

# Split names
arr=(${domains//,/ })

# Build SAN of the form "DNS:domain1,DNS:domain2"
SAN=""

first=true

for i in "${arr[@]}"
do
  if [ ${first} = false ];
  then
    SAN+=,
  fi
  first=false
  SAN+=DNS:$i
done

openssl req -x509 -newkey rsa:4096 -subj "/C=FI/ST=HE/O=Meeshkan/CN=*" -reqexts SAN -extensions SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\nsubjectAltName=${SAN}")) -nodes -keyout ${target_dir}/key.pem -out ${target_dir}/cert.pem

# echo $(openssl x509 -in cert.pem -text -noout)
