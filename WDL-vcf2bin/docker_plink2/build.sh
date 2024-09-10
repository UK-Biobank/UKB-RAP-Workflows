source ../docker.env

# 1) Build Docker image and confirm that it's OK
docker build --rm -t plink2 .
docker image ls

# 2) Validate the binaries inside the Docker image
docker run plink2:latest plink2 --version
docker run plink2:latest bcftools --version


# 3) Save Docker image
docker save -o plink2_image.tar.gz plink2:latest


# 4) Upload docker image to your project
dx upload plink2_image.tar.gz --path $PTH/
