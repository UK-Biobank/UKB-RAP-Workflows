source ../docker.env

# 1) Download GRCh38 reference files
dx download "${REF}/GRCh38_full_analysis_set_plus_decoy_hla*"

# 2) Build docker image and confirm that it's OK
docker build --rm -t bcftools116_ref .
docker image ls

# 3) Validate the binaries inside the Docker image
docker run bcftools116_ref:latest bcftools --version
docker run bcftools116_ref:latest bcftools_vanilla --version
docker run bcftools116_ref:latest ls -lah /data

# 4) Save Docker image
docker save -o bcftools_v116m_v116_ref_GRCh38_v2.tar.gz bcftools116_ref:latest


# 5) Upload docker image to your project
dx upload bcftools_v116m_v116_ref_GRCh38_v2.tar.gz --path $PTH/
