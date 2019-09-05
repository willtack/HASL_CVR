#! /bin/bash
#
#

CONTAINER="[willtack/hasl]"
echo -e "$CONTAINER  Initiated"


# Built to flywheel-v0 spec.
FLYWHEEL_BASE=/flywheel/v0
MCR_ROOT=/opt/mcr/v92/  # double check this
OUTPUT_DIR=${FLYWHEEL_BASE}/output


# Make sure that /output directory exists
if [[ ! -d "${OUTPUT_DIR}" ]]
    then
        echo "${CONTAINER}  ${OUTPUT_DIR} not found!"
        exit 1
fi


# Set paths to input files
aslFile=$(find $FLYWHEEL_BASE/input/asl/ -type f -name "*asl.nii*")
m0File=$(find $FLYWHEEL_BASE/input/m0/ -type f -name "*m0.nii*")
mprageFile=$(find $FLYWHEEL_BASE/input/mprage/ -type f -name "*MPRAGE_brain.nii*")

# Check for required inputs
if [[ -z "$aslFile" ]] ||  [[ -z "$m0File" ]] || [[ -z "$mprageFile" ]]; then
  echo -e "$CONTAINER  One or more input files were not found! Exiting!"
  exit 1
fi


# Run the Matlab executable
time /msa/run_dwisplitshells.sh "${MCR_ROOT}" "${aslFile}" "${m0File}" "${mprageFile}" "${OUTPUT_DIR}"


# Check exit status
exit_status=$?
if [[ $exit_status != 0 ]]; then
  echo -e "$CONTAINER  An error occurred during execution of the Matlab executable. Exiting!"
  exit 1
fi


# Get a list of the files in the output directory
outputs=$(find $OUTPUT_DIR/* -maxdepth 0 -type f)


# If outputs exist, generate metadata, and exit
if [[ -z $outputs ]]; then
  echo "$CONTAINER  No results found in output directory... Exiting"
  exit 1
else
  cd $OUTPUT_DIR
  echo -e "$CONTAINER  Wrote: `ls`"
  echo -e "$CONTAINER  Done!"
fi


# Handle permissions of the outputs
chmod -R 777 $OUTPUT_DIR


# Exit
exit 0
