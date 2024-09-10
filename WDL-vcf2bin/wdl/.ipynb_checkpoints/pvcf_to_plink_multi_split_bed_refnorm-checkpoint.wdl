version 1.0

workflow multi_refnorm_bed {

    input {
        Array[File] manifest
        String PROJ
        String PTH
    }
    
    scatter (slice in manifest) {
      call vcf_has_data { input : vcf = slice }
      if ( vcf_has_data.n != 0 ) {
        call norm_ref_vcf_to_vcf {
            input: 
                vcf = slice,
                PROJ = PROJ,
                PTH = PTH
        }
        call nornvcf_to_bed {
            input:
                nornvcf = norm_ref_vcf_to_vcf.norm,
                PROJ = PROJ,
                PTH = PTH
        }
        call validate_bed {
          input:
            bed = nornvcf_to_bed.bed, 
            bim = nornvcf_to_bed.bim, 
            fam = nornvcf_to_bed.fam,
            PROJ = PROJ,
            PTH = PTH
        }
      }
    }
    
    call merge_bed {
        input:
            bed = nornvcf_to_bed.bed, 
            bim = nornvcf_to_bed.bim, 
            fam = nornvcf_to_bed.fam,
            PROJ = PROJ,
            PTH = PTH
    }

    call bed_to_bgen {
        input:
            bed = merge_bed.mbed, 
            bim = merge_bed.mbim, 
            fam = merge_bed.mfam,
            PROJ = PROJ,
            PTH = PTH
    }

    call count_stderr {
            input : inlist = norm_ref_vcf_to_vcf.stderr
    }

    if ( count_stderr.n != 0 ) {
        call save_stderr {
            input : errlist = count_stderr.outlist
        }
    }

    output {

        # Uncomment to enable non-merged files in output
        # Array[File?] bed = nornvcf_to_bed.bed
        # Array[File?] bim = nornvcf_to_bed.bim
        # Array[File?] fam = nornvcf_to_bed.fam
        # Array[File?] vld = validate_bed.pvalid

        File mlst = merge_bed.tsv
        File mbed = merge_bed.mbed
        File mbim = merge_bed.mbim
        File mfam = merge_bed.mfam
        File bgen = bed_to_bgen.zlbgen
        File smpl = bed_to_bgen.sample


    }
}


task vcf_has_data {
    input {
        File vcf
    }
    command <<<
        cat "~{vcf}" 2>/dev/null | zgrep "^[^#]" 2>/dev/null | head -1 | wc -l
    >>>
    output {
        Int n = read_int(stdout())
    }
}

task norm_ref_vcf_to_vcf {
    input {
        File vcf
        String prefix = basename("~{vcf}", ".vcf.gz")
        String PROJ
        String PTH
    }
    command <<<
        bcftools norm "~{vcf}" -f /data/GRCh38_full_analysis_set_plus_decoy_hla.fa -m -any -Oz --no-version --threads 4 -o "~{prefix}".norm.vcf.gz || bcftools_vanilla norm "~{vcf}" -f /data/GRCh38_full_analysis_set_plus_decoy_hla.fa -m -any -Oz --no-version --threads 4 -o "~{prefix}".norm.vcf.gz 2> "~{prefix}".norm.stderr.txt || true
    >>>
    runtime {
        docker: "dx://${PROJ}:/${PTH}/bcftools_v116m_v116_ref_GRCh38_v2.tar.gz"
        dx_instance_type: "mem3_ssd1_v2_x4"
        dx_restart: object {
          default: 5,
          max: 5,
          errors: object {
              UnresponsiveWorker: 3,
              ExecutionError: 3
          }
      }
    }
    output {
        File norm = prefix + ".norm.vcf.gz"
        File? stderr = prefix + ".norm.stderr.txt"
    }
}

task nornvcf_to_bed {
    input {
        File nornvcf
        String prefix = basename("~{nornvcf}", ".norm.vcf.gz")
        String PROJ
        String PTH
    }
    command <<<

    plink --make-bed \
      --vcf "~{nornvcf}"  \
      --keep-allele-order \
      --vcf-idspace-to _ \
      --double-id \
      --allow-extra-chr 0 \
      --vcf-half-call m \
      --out "~{prefix}"

      ls -lah "~{prefix}".bed
      ls -lah "~{prefix}".bim
      ls -lah "~{prefix}".fam
    >>>
    runtime {
        docker: "dx://${PROJ}:/${PTH}/plink_v19_image.tar.gz"
        dx_instance_type: "mem1_ssd1_v2_x4"
        dx_restart: object {
          default: 3,
          max: 5,
          errors: object {
              UnresponsiveWorker: 3,
              ExecutionError: 3
          }
      }
    }
    output {
        File bed = prefix + ".bed"
        File bim = prefix + ".bim"
        File fam = prefix + ".fam"
    }
}

task validate_bed {
    input {
        File bed
        File bim
        File fam
        String prefix = basename("~{bed}", ".bed")
        String PROJ
        String PTH
    }
    command <<<
      plink2 --validate --bed "~{bed}" --bim "~{bim}" --fam "~{fam}" > "~{prefix}".BedValid.txt
    >>>
    runtime {
        docker: "dx://${PROJ}:/${PTH}/plink2_image.tar.gz"
        dx_instance_type: "mem1_ssd1_v2_x4"
        dx_restart: object {
          default: 3,
          max: 5,
          errors: object {
              UnresponsiveWorker: 3,
              ExecutionError: 3
          }
      }
    }
    output {
        File pvalid = prefix + ".BedValid.txt"

    }
}

task make_tab {
    input {
         Array[File?] pgen
         Array[File?] pvar
         Array[File?] psam
         File tsv = write_tsv(transpose([pgen, pvar, psam]))
    }
    command {}
    output {
        File tab = tsv
    }
}


task count_stderr {
    input {
         Array[File?] inlist
         Array[File] simperrlist = select_all(inlist)
    }
    command {}
    output {
        Int n = length(select_first([simperrlist, []]))
        Array[File] outlist = simperrlist
    }
}

task save_stderr {
    input {
        Array[File] errlist
        String prefix = sub(basename("~{select_first(errlist)}", ".norm.stderr.txt"), "_b[0-9]+_v1", "_v1")

    }
    command <<<
        cat ~{sep=' ' errlist} > "~{prefix}".common.stderr.txt
    >>>
    output {
        File err = prefix + ".common.stderr.txt"
    }
}


task merge_bed {
    input {
        Array[File?] bed
        Array[File?] bim
        Array[File?] fam
        String prefix = sub(basename("~{select_first(bed)}", ".bed"), "_b[0-9]+_v1", "_v1")
        String PROJ
        String PTH
    }
    command <<<
      cat ~{write_tsv(transpose([select_all(bed), select_all(bim), select_all(fam)]))} > "~{prefix}"_merge_list.txt
      # plink --merge-list "~{prefix}"_merge_list.txt --make-bed --out "~{prefix}"
      plink2 --pmerge-list "~{prefix}"_merge_list.txt --make-bed --out "~{prefix}" --multiallelics-already-joined --max-alleles 2 
    >>>
    runtime {
        docker: "dx://${PROJ}:/${PTH}/plink2_image.tar.gz"
        dx_instance_type: "mem3_ssd3_x12"
        dx_restart: object {
          default: 3,
          max: 5,
          errors: object {
              UnresponsiveWorker: 3,
              ExecutionError: 3
          }
      }
    }
    output {
        File tsv = prefix + "_merge_list.txt"
        File mbed = prefix + ".bed"
        File mbim = prefix + ".bim"
        File mfam = prefix + ".fam"
        
    }
}

task bed_to_bgen {
    input {
        File bed
        File bim
        File fam
        String prefix = basename("~{bed}", ".bed")
        String PROJ
        String PTH
    }
    command <<<
      plink2 --bed "~{bed}" --bim "~{bim}" --fam "~{fam}" --export bgen-1.2 bits=8 ref-first --out "~{prefix}".zlib
    >>>
    runtime {
        docker: "dx://${PROJ}:/${PTH}/plink2_image.tar.gz"
        dx_instance_type: "mem3_ssd3_x8"
        dx_restart: object {
          default: 3,
          max: 5,
          errors: object {
              UnresponsiveWorker: 3,
              ExecutionError: 3
          }
      }
    }
    output {
        File zlbgen = prefix + ".zlib.bgen"
        File sample = prefix + ".zlib.sample"
    }
}
