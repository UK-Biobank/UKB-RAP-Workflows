source ../docker.env

# 1) Build Docker image and confirm that it's OK
docker build --rm -t plink1 .
docker image ls

# 2) Validate the binaries inside the Docker image
docker run plink1:latest plink --version
docker run plink1:latest bcftools --version


# 3) Save Docker image
docker save -o plink_v19_image.tar.gz plink1:latest


# 4) Upload docker image to your project
dx upload plink_v19_image.tar.gz --path $PTH/
