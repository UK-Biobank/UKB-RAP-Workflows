source compile_wdl.env

# 1) Set up the project ID variable
PR=$(dx env | grep project- | cut -f 2)
echo $PR

# 2) Compile the WDL 1st stage of workflow
wid=$(java -jar ${DXC} compile ./pvcf_to_plink_multi_split_bed_refnorm.wdl -project $PR -folder /"$WDL_LOC"/ -f -extras extras.json)
echo $wid

# 3) Validate the workflow on RAP
java -jar $DXC describe $wid --pretty
dx list stages $wid
dx describe $wid


