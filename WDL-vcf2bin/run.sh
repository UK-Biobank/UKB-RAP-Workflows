source run.env

dx run /"$WDL_LOC"/multi_refnorm_bed \
    -f "chr${CHR}.json" \
    --destination="/$DEST/" \
    --name="chr${CHR}-wdl" \
    --tag "chr${CHR}" --tag "VCF 2 binary" -y --brief --priority normal --delay-workspace-destruction
