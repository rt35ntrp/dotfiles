#!/bin/bash

image_name=my_image
container_name=my_container

docker kill ${container_name}
docker rm ${container_name}

docker run -d -it -p 8080:8080 \
    -v $(pwd)/logs:/app/logs \
	--name ${container_name} "${image_name}"
