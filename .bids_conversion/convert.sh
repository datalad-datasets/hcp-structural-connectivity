#!/bin/bash

set -e -u

# get list of dirs once
for subdir in [0-9]*; do

    newsub="sub-${subdir}"
    mkdir -p rawdata/${newsub}/ses-3T/anat \
             rawdata/${newsub}/ses-3T/fmap \
             derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/ses-3T/dwi \
             derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/ses-7T/dwi
    # rename 3T diffusion files
    git mv -fk ${subdir}/T1w/Diffusion/bvals derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/ses-3T/dwi/${newsub}_ses-3T_dwi.bvals || true
    git mv -fk ${subdir}/T1w/Diffusion/bvecs derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/ses-3T/dwi/${newsub}_ses-3T_dwi.bvecs || true
    git mv -fk ${subdir}/T1w/Diffusion/grad_dev.nii.gz derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/ses-3T/dwi/${newsub}_ses-3T_desc-graddev_dwi.nii.gz || true
    git mv -fk ${subdir}/T1w/Diffusion/nodif_brain_mask.nii.gz derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/ses-3T/dwi/${newsub}_ses-3T_desc-nodifbrain_mask.nii.gz || true
    git mv -fk ${subdir}/T1w/Diffusion/data.nii.gz derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/ses-3T/dwi/${newsub}_ses-3T_desc-data_dwi.nii.gz || true

    # rename 7T Diffusion files
    git mv -fk ${subdir}/T1w/Diffusion_7T/bvals derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/ses-7T/dwi/${newsub}_ses-7T_dwi.bvals || true
    git mv -fk ${subdir}/T1w/Diffusion_7T/bvecs derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/ses-7T/dwi/${newsub}_ses-7T_dwi.bvecs || true
    git mv -fk ${subdir}/T1w/Diffusion_7T/grad_dev.nii.gz derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/ses-7T/dwi/${newsub}_ses-7T_desc-graddev_dwi.nii.gz || true
    git mv -fk ${subdir}/T1w/Diffusion_7T/nodif_brain_mask.nii.gz derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/ses-7T/dwi/${newsub}_ses-7T_desc-nodifbrain_mask.nii.gz || true
    git mv -fk ${subdir}/T1w/Diffusion_7T/data.nii.gz derivatives/hcp_pipelines/diffusion_preprocessing/${newsub}/ses-7T/dwi/${newsub}_ses-7T_desc-data_dwi.nii.gz || true

    # rename 3T anat and fmap files
    # BEP001 lists the suffix VFA for variable flip angle, but there is no
    # recommended suffix for actual flip angle.
    git mv -fk ${subdir}/unprocessed/3T/T1w_MPR1/${subdir}_3T_AFI.nii.gz rawdata/${newsub}/ses-3T/anat/${newsub}_ses-3T_AFI.nii.gz || true
    git mv -fk ${subdir}/unprocessed/3T/T1w_MPR1/${subdir}_3T_BIAS_32CH.nii.gz rawdata/${newsub}/ses-3T/anat/${newsub}_ses-3T_acq-32ch_PDw.nii.gz || true
    git mv -fk ${subdir}/unprocessed/3T/T1w_MPR1/${subdir}_3T_BIAS_BC.nii.gz rawdata/${newsub}/ses-3T/anat/${newsub}_ses-3T_acq-BC_PDw.nii.gz || true
    git mv -fk ${subdir}/unprocessed/3T/T1w_MPR1/${subdir}_3T_FieldMap_Magnitude.nii.gz rawdata/${newsub}/ses-3T/fmap/${newsub}_ses-3T_magnitude.nii.gz || true
    git mv -fk ${subdir}/unprocessed/3T/T1w_MPR1/${subdir}_3T_FieldMap_Phase.nii.gz rawdata/${newsub}/ses-3T/fmap/${newsub}_ses-3T_phasediff.nii.gz || true
    git mv -fk ${subdir}/unprocessed/3T/T1w_MPR1/${subdir}_3T_T1w_MPR1.nii.gz rawdata/${newsub}/ses-3T/anat/${newsub}_ses-3T_T1w.nii.gz || true
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
  "BIDSVersion": "1.3.0-dev (BEP001)",
}
EOT

# create dataset_description.json for the derivatives
cat >> derivatives/hcp_pipelines/dataset_description.json << EOT
{
    "Name": "HCP Structural Connectivity",
    "BIDSVersion": "1.3.0-dev (BEP003)",
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
