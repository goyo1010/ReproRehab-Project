% This user input prompts the user for the trial number of the file.
trial = input("What is the trial number of this file?");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This line calls the function APDMdataconvert.m which asks the user
% choose the .h5 file to convert into a .m file and stores the IMU sensor
% data in a structure variable called "IMU".
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

APDMdataconvert

% Ask the user for the MATLAB file to be loaded and calculations to be run.
file = uigetfile('*.mat','Select a MATLAB .mat file');
load(file);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These next lines of code will run the descriptive statistics for the
% lumbar sensors y-vector linear accelerations and store them as variables
% from the file loaded in the previous section.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% calculate the mean of the data
ymean = mean(IMU.RWrist.accel(:,2));

% calculate the standard deviation of the data
ystd = std(IMU.RWrist.accel(:,2));

% calculate the minimum and maximum value of the data
ymin = min(IMU.RWrist.accel(:,2));
ymax = max(IMU.RWrist.accel(:,2));

% calculate the linear coefficient of variation of the sensor data for the 
% y-vector.

yCV = ystd/ymean;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These next lines of code will run the sample entropy calculations based
% on the code developed by Hurd WJ, Morrow MM, & Kaufman KR (2013), which
% was based on the calculations and parameters proposed by Richman JS & 
% Moorman JR (2000) and Pincus SM & Goldberger AL (1994).
%
% The physiologic time series uses a vector length of m = 2 and tolerance
% radius of R = 0.2 (proposed by Pincus & Golderberger to lie between 0.10
% and 0.20), which is then multipled by the data's SD to produce r. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data = IMU.RWrist.accel(:,2);
m = 2;
R = 0.2;
sample_entropy = Ent_Samp(data,m,R);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These next lines of code create an Excel table that export these
% descriptive data from MATLAB into a new Excel sheet based on the trial 
% prompt input from the user.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create MATLAB table
descriptives_table = table(ymean, ystd, ymin, ymax, yCV, sample_entropy);

% Call all columns x rows of your MATLAB table
% descriptives_table(:,:);

% Create and write from the MATLAB table to an Excel file (.xlsx)
filename = 'Trial Descriptive Data.xlsx';
writetable(descriptives_table, filename, 'Sheet', trial, 'Range', 'A1');