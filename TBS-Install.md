login to registry.pivotal.io

```
$ docker login registry.pivotal.io
Username: YOUR_TANZU_USER
Password: 
WARNING! Your password will be stored unencrypted in /home/curtis/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

```
$ docker login hub.oakwood.ave
Username: admin
Password: 
WARNING! Your password will be stored unencrypted in /home/curtis/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

```
kbld --registry-verify-certs=false relocate -f ./images.lock --lock-output ./images-relocated.lock --repository hub.oakwood.ave/tanzu-build-service/build-service
```

```
$ kbld --registry-verify-certs=false relocate -f ./images.lock --lock-output ./images-relocated.lock --repository hub.oakwood.ave/tanzu-build-service/build-service
relocate | exporting 11 images...
relocate | will export registry.pivotal.io/build-service/kpack-build-init@sha256:575fd9ee4ba5db4c407e51ed24d4cf88fce15c1079298f14628043d5e2e86985
relocate | will export registry.pivotal.io/build-service/kpack-completion@sha256:2e182c946e42fc62353a40b1355cdcd4e474406303b5e9c8fae28d0e0329011a
relocate | will export registry.pivotal.io/build-service/kpack-controller@sha256:8358c4de486709a86b2a0e0e5f90e043f63c150df94ea31f75ef2db86083738e
relocate | will export registry.pivotal.io/build-service/kpack-lifecycle@sha256:4f445eaaa2d6ab5ec7f4a83c2278225467df9c18b5ced1de9179e8152fa8f90b
relocate | will export registry.pivotal.io/build-service/kpack-rebase@sha256:0c6ef28a7810b98b18d7d730f4e09b05f60f4bf59b082113111b1cf70760aa4d
relocate | will export registry.pivotal.io/build-service/kpack-webhook@sha256:23b6c9e8d6b78800e7d568931d6cea772af2cc1cc7748c281be6235d95d3dffc
relocate | will export registry.pivotal.io/build-service/pod-webhook@sha256:a1fda51e2e0b5f9b8b34941c20a9b15aa4ef4433b2afa60a8b751691b4b9c2bf
relocate | will export registry.pivotal.io/build-service/secret-syncer@sha256:ba895ea5e4380e44f5b25d6babed2c3840402b670b4b3a25b95233b92ab228e1
relocate | will export registry.pivotal.io/build-service/setup-ca-certs@sha256:fa88cf24fb79048cc4051536a777bf0f415c637472bb1870c316c91b3f1580e6
relocate | will export registry.pivotal.io/build-service/sleeper@sha256:1137af949008f4a9060aae34b2df0108e6d20eff09c7bcb16bb31ce18c4f30c8
relocate | will export registry.pivotal.io/build-service/smart-warmer@sha256:66a1b04ce787cf5e61f5b3a42352046cde3fccfed9dc6efb50544a4640f2987d
relocate | exported 11 images
relocate | importing 11 images...
relocate | importing registry.pivotal.io/build-service/secret-syncer@sha256:ba895ea5e4380e44f5b25d6babed2c3840402b670b4b3a25b95233b92ab228e1 -> hub.oakwood.ave/tanzu-build-service/build-service@sha256:ba895ea5e4380e44f5b25d6babed2c3840402b670b4b3a25b95233b92ab228e1...
relocate | importing registry.pivotal.io/build-service/kpack-controller@sha256:8358c4de486709a86b2a0e0e5f90e043f63c150df94ea31f75ef2db86083738e -> hub.oakwood.ave/tanzu-build-service/build-service@sha256:8358c4de486709a86b2a0e0e5f90e043f63c150df94ea31f75ef2db86083738e...
relocate | importing registry.pivotal.io/build-service/smart-warmer@sha256:66a1b04ce787cf5e61f5b3a42352046cde3fccfed9dc6efb50544a4640f2987d -> hub.oakwood.ave/tanzu-build-service/build-service@sha256:66a1b04ce787cf5e61f5b3a42352046cde3fccfed9dc6efb50544a4640f2987d...
relocate | importing registry.pivotal.io/build-service/kpack-completion@sha256:2e182c946e42fc62353a40b1355cdcd4e474406303b5e9c8fae28d0e0329011a -> hub.oakwood.ave/tanzu-build-service/build-service@sha256:2e182c946e42fc62353a40b1355cdcd4e474406303b5e9c8fae28d0e0329011a...
relocate | importing registry.pivotal.io/build-service/kpack-webhook@sha256:23b6c9e8d6b78800e7d568931d6cea772af2cc1cc7748c281be6235d95d3dffc -> hub.oakwood.ave/tanzu-build-service/build-service@sha256:23b6c9e8d6b78800e7d568931d6cea772af2cc1cc7748c281be6235d95d3dffc...
relocate | importing registry.pivotal.io/build-service/setup-ca-certs@sha256:fa88cf24fb79048cc4051536a777bf0f415c637472bb1870c316c91b3f1580e6 -> hub.oakwood.ave/tanzu-build-service/build-service@sha256:fa88cf24fb79048cc4051536a777bf0f415c637472bb1870c316c91b3f1580e6...
relocate | importing registry.pivotal.io/build-service/sleeper@sha256:1137af949008f4a9060aae34b2df0108e6d20eff09c7bcb16bb31ce18c4f30c8 -> hub.oakwood.ave/tanzu-build-service/build-service@sha256:1137af949008f4a9060aae34b2df0108e6d20eff09c7bcb16bb31ce18c4f30c8...
relocate | importing registry.pivotal.io/build-service/kpack-build-init@sha256:575fd9ee4ba5db4c407e51ed24d4cf88fce15c1079298f14628043d5e2e86985 -> hub.oakwood.ave/tanzu-build-service/build-service@sha256:575fd9ee4ba5db4c407e51ed24d4cf88fce15c1079298f14628043d5e2e86985...
relocate | importing registry.pivotal.io/build-service/kpack-rebase@sha256:0c6ef28a7810b98b18d7d730f4e09b05f60f4bf59b082113111b1cf70760aa4d -> hub.oakwood.ave/tanzu-build-service/build-service@sha256:0c6ef28a7810b98b18d7d730f4e09b05f60f4bf59b082113111b1cf70760aa4d...
relocate | importing registry.pivotal.io/build-service/pod-webhook@sha256:a1fda51e2e0b5f9b8b34941c20a9b15aa4ef4433b2afa60a8b751691b4b9c2bf -> hub.oakwood.ave/tanzu-build-service/build-service@sha256:a1fda51e2e0b5f9b8b34941c20a9b15aa4ef4433b2afa60a8b751691b4b9c2bf...
relocate | importing registry.pivotal.io/build-service/kpack-lifecycle@sha256:4f445eaaa2d6ab5ec7f4a83c2278225467df9c18b5ced1de9179e8152fa8f90b -> hub.oakwood.ave/tanzu-build-service/build-service@sha256:4f445eaaa2d6ab5ec7f4a83c2278225467df9c18b5ced1de9179e8152fa8f90b...
relocate | imported 11 images
Succeeded
```

docker hub (*doesn't work)

```
kbld relocate -f ./images.lock --lock-output ./docker-hub-images-relocated.lock --repository ccollicutttanzu
```

icbc-poc harbor...

```
$ kbld --registry-ca-cert-path ./root_ca_certificate relocate -f ./images.lock --lock-output ./harbor-icbc-poc-relocated.lock --repository harbor.icbc-poc.oakwood.ave/library/build-service

```

download root ca from ops manager.

```
ytt -f ./values.yaml \
    -f ./manifests/ \
    -f ./root_ca_certificate \
    -v docker_repository="hub.oakwood.ave/tanzu-build-service/build-service" \
    -v docker_username="admin" \
    -v docker_password="admin" \
    | kbld -f ./images-relocated.lock -f- \
    | kapp deploy -a tanzu-build-service -f- -y
```