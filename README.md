# ReproRehab-Project
This repository contains files pertaining to the ReproRehab project for Gregory Brusola and Michael Furtado at UTMB. In this folder the following files and folders are described. The purpose of this project was to convert data from the APDM Opal IMU sensors .h5 file into a MATLAB readable .m file that then runs calculations on linear acceleration data from the y-axis of the lumbar and left and right wrist IMU sensors. Descriptive statistics and sample entropy calculations follow.

## FILES
- APDMAnalysis.m - The general MATLAB script that runs calculations on linear acceleration data gathered from the APDM Opal IMU sensors. It uses the functions APDMdataconvert.m and sampenc.m.
- APDMAnalysis_Gait.m - The MATLAB script that runs calculation on linear acceleration data gather from the LUMBAR APDM Opal IMU sensor. It uses the functions APDMdataconvert.m and Ent_Samp.m.
- APDMAnalysis_LtUE.m - The MATLAB script that runs calculation on linear acceleration data gather from the LEFT WRIST APDM Opal IMU sensor. It uses the functions APDMdataconvert.m and Ent_Samp.m.
- APDMAnalysis_RtUE.m - The MATLAB script that runs calculation on linear acceleration data gather from the RIGHT WRIST APDM Opal IMU sensor. It uses the functions APDMdataconvert.m and Ent_Samp.m.
- APDMAnalysis_v2.m - The general MATLAB script that runs calculations on linear acceleration data gathered from the APDM Opal IMU sensors. It uses the functions APDMdataconvert.m and Ent_Samp.m.
- APDMdataconvert.m - The MATLAB code that allows data to be converted from the APDM Opal .h5 file into a .m file for MATLAB
- Ent_Samp.m - The MATLAB code that receives 3 inputs to output sample entropy of a time series trial. The code was developed by the Nonlinear Analysis Core from the Unviersity of Nebraska at Omaha based on the method described by Richmen and Moorman (2000).
- sampenc.m - The MATLAB code that receives 3 inputs to output sample entropy of a time series. This code was developed by Dr. Melissa Morrow and colleages at the Mayo Clinic based on a similar method as the Nonlinear Analysis Core.

## FOLDERS
- Old Trial Data (Gait) - Contains gait files for tandem walk single and dual-task conditions based on the modified Walking and Remembering Test. This folder contains pratice trials files.
- RP Gait Trials - Contains gait files for tandem walk single and dual-task conditions based on the modified Walking and Remembering Test. This folder contains files of actual trials for the complex gait task.
- RP UE Trials - Contains UE motor tasks files using the 9-Hole Peg Test during single and dual-task conditions based on the framework from the modified Walking and Remembering Test. This folder contains files of actual trials for the the UE motor task.
