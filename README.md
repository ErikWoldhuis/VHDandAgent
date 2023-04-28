# Prepare Windows Virtual Machine to be uploaded to Azure

[![PSScriptAnalyzer](https://github.com/BJD1997/Prepare-VM-for-Azure/actions/workflows/powershell.yml/badge.svg)](https://github.com/BJD1997/Prepare-VM-for-Azure/actions/workflows/powershell.yml)

This script can be run inside a Windows VM that is going to be uploaded into Azure. 
The script is based on the [instructions](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/prepare-for-upload-vhd-image) provided by Microsoft to prepare a VHD for Azure. Included in this script is also the installation of the Azure VM agent. 

Please make sure you run this script as Administrator.

After running this script you have to make a choice to run [sysprep or not.](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/prepare-for-upload-vhd-image#determine-when-to-use-sysprep)
Then follow instructions on how to [convert the VM disk to a VHD fixed size](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/prepare-for-upload-vhd-image#convert-the-virtual-disk-to-a-fixed-size-vhd) and [upload to Azure Blob storage.](https://docs.microsoft.com/en-us/azure/devtest-labs/devtest-lab-upload-vhd-using-storage-explorer)
