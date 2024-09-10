# **UKB-RAP-Workflows**

This UK Biobank repository focuses on executing complex, multi-stage workflows on the UKB-RAP. By using tools such as [Apps and applets](https://documentation.dnanexus.com/faqs/developing-apps-and-applets), and [Workflow Description Language (WDL)](https://github.com/openwdl/wdl), researchers can create scalable, parallelised, portable workflows that allow optimised computational resource control for large-scale analyses.

Currently, this repository comprises a single WDL workflow (*WDL-vcf2bin*) that was employed by UK Biobank in the conversion of Whole genome sequencing 200k pVCFs into [Plink](https://www.cog-genomics.org/plink/) and [BGEN](https://www.chg.ox.ac.uk/~gav/bgen_format/index.html) formatted binaries.

