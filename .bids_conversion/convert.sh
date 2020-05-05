#!/bin/bash

set -e -u

# get list of dirs once
for subdir in [0-9]*; do

    newsub="sub-${subdir}"
    mkdir -p rawdata/${newsub}/anat \
             rawdata/${newsub}/fmap \
             derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/dwi
    # rename files
    # sub-107220, 109325, 113417, 114924, 116120, 117728, 121315, 121820,
    # 126931, 128329, 129432, 129533, 131621, 142424, 143527, 145531, 150423,
    # 159845, 165234, 168038, 169141, 171128, 171734, 186949, 190132, 197449,
    # 201717, 203721, 207628, 239136, 221218, 355845, 355542, 623137, 613235,
    # 611231, 584355, 552544, 662551, 650746, 689470, 782157, 745555, 734247,
    # 733548, 822244, 953764, 209531 are missing bvals, bvecs, data.nii.gz,
    # grad_dev.nii.gz, and nodiff_brain_mask.nii.gz
    git mv -fk ${subdir}/T1w/Diffusion/bvals derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/dwi/${newsub}_dwi.bvals || true
    git mv -fk ${subdir}/T1w/Diffusion/bvecs derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/dwi/${newsub}_dwi.bvecs || true
    git mv -fk ${subdir}/T1w/Diffusion/grad_dev.nii.gz derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/dwi/${newsub}_desc-grad-dev_dwi.nii.gz || true
    git mv -fk ${subdir}/T1w/Diffusion/nodif_brain_mask.nii.gz derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/dwi/${newsub}_desc-nodif-brain_mask.nii.gz || true
    # sub-212823 is missing only data.nii.gz
    git mv -fk ${subdir}/T1w/Diffusion/data.nii.gz derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/dwi/${newsub}_desc-data_dwi.nii.gz || true

    # sub-103010, 103111, 111009, 111514, 115017, 121416, 127630, 130821,
    # 136732, 138332, 143325, 179952, 181131, 194443, 206525, 208630, 245333,
    # 299760, 300618, 346137, 392750, 397154, 406432, 415837, 429040, 633847,
    # 662551, 679770, 688569, 693461, 815247 are missing AFI.nii.gz
    # BEP001 lists the suffix VFA for variable flip angle, but there is no
    # recommended suffix for actual flip angle.
    git mv -fk ${subdir}/unprocessed/3T/T1w_MPR1/${subdir}_3T_AFI.nii.gz rawdata/${newsub}/anat/${newsub}_AFI.nii.gz || true
    git mv -fk ${subdir}/unprocessed/3T/T1w_MPR1/${subdir}_3T_BIAS_32CH.nii.gz rawdata/${newsub}/anat/${newsub}_acq-32ch_PDw.nii.gz || true
    # sub-135528 is missing BIAS_BC.nii.gz
    git mv -fk ${subdir}/unprocessed/3T/T1w_MPR1/${subdir}_3T_BIAS_BC.nii.gz rawdata/${newsub}/anat/${newsub}_acq-BC_PDw.nii.gz || true
    # sub-102614, 111009, 111514, 115017, 121416, 130821, 138332, 179952,
    # 299760, 300618, 392750, 406432, 429040, 633847, 662551, 679770, 688569,
    # 693461, 815247 are missing FieldMap_Magnitude.nii.gz
    git mv -fk ${subdir}/unprocessed/3T/T1w_MPR1/${subdir}_3T_FieldMap_Magnitude.nii.gz rawdata/${newsub}/fmap/${newsub}_magnitude.nii.gz || true
    # sub-102614, 111009, 111514, 115017, 121416, 130821, 138332, 179952,
    # 299760, 300618, 392750, 406432, 429040, 633847, 662551, 679770, 688569,
    # 693461, 815247 are missing FieldMap_Phase
    git mv -fk ${subdir}/unprocessed/3T/T1w_MPR1/${subdir}_3T_FieldMap_Phase.nii.gz rawdata/${newsub}/fmap/${newsub}_phasediff.nii.gz || true
    # sub-195041 is missing T1w_MPR1.nii.gz
    git mv -fk ${subdir}/unprocessed/3T/T1w_MPR1/${subdir}_3T_T1w_MPR1.nii.gz rawdata/${newsub}/anat/${newsub}_T1w.nii.gz || true
    # get rid of the old dir
    git rm -r ${subdir} &> /dev/null || rm -rf ${subdir}
done

# let git-annex ensure all file pointers are proper
git annex fsck -q

# create dataset_description.json files, if there are none
[ -f dataset_description.json ] && exit 0

# create dataset_description.json for the raw data
cat >> rawdata/dataset_description.json << EOT
{
  "Name": "HCP Structural Connectivity",
  "BIDSVersion": "1.3.0",
}
EOT

# create dataset_description.json for the derivatives
cat >> derivatives/hcp_pipelines/dataset_description.json << EOT
{
    "Name": "HCP Structural Connectivity",
    "BIDSVersion": "1.3.0-dev (BEP003) & (BEP001)",
    "PipelineDescription": {
        "Name": "HCP Pipelines - Diffusion Preprocessing",
        "Version": "",
        },
    "SourceDatasets": [
        {
            "DOI": "",
            "URL": "https://github.com/datalad-datasets/human-connectome-project-openaccess",
            "Version": ""
        }
    ]
}
EOT
