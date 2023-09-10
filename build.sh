#/bin/bash
git clone git@github.com:yuzutech/kroki-cli.git

kroki_tags=$(cd kroki-cli && git tag --contains $(git rev-list -n 1 "v0.5.0"))
kroki_go_version=$(cd kroki-cli && grep -E "^go .+$" go.mod | grep -Eo "([0-9]+\.)+[0-9]+")
rm -rf kroki-cli
go_all_tags=$(curl -L -s 'https://registry.hub.docker.com/v2/repositories/library/golang/tags?page_size=1024'|jq '."results"[]["name"]')

ALPINE_DISTROS="alpine:3.16 alpine:3.17 alpine:3.18"

TAGS_TO_BUILD="0.1.0-"
for DISTRO in ${ALPINE_DISTROS}
do
	for TAG in ${kroki_tags}
	do
		distro_name=$(echo ${DISTRO} | sed 's/://g')
		go_builder_tag="$(echo ${kroki_go_version} | sed 's/v//g')-${distro_name}"
		go_builder_image="golang:${go_builder_tag}"
		image_tag="aapozd/kroki-cli:$(echo ${TAG} | sed 's/v//g')-${distro_name}"
		if [[ ${go_all_tags} =~ ${go_builder_tag} ]]; then
			docker build . -t ${image_tag} \
				--build-arg GO_BUILDER_IMAGE=${go_builder_image} \
				--build-arg RUNTIME_IMAGE=${DISTRO} \
				--build-arg KROKI_VERSION=${TAG}
			if [[ $? -eq 0 ]]; then
				docker push ${image_tag}
			fi
		fi
	done
done
