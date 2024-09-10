source prep_manifest.env

# List the file-IDs for a chromosome ans save them to .json file that will be used as input to dx run command
dx find data --brief --name "*${FIELD}_c${CHR}_b*vcf.gz" --property field_id=${FIELD} --folder "Bulk/" | awk -F ':' '{print $2}' | \
  sed 's/^/  {"$dnanexus_link" : "/; s/$/"}/; $!s/$/,/' | \
  cat <(echo { '"stage-common.manifest": [' ) - <(echo '],') \
  > chr${CHR}.json

echo '"stage-common.PROJ": "'${PROJ}'",' >> chr${CHR}.json
echo '"stage-common.PTH": "'${PTH}'"}' >> chr${CHR}.json


# Log the number of VCF files found for chromosome number
echo "Number of VCFs:" $(grep "file-" chr${CHR}.json | wc -l)
