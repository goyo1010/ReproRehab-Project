prompt = "What is the trial number of this file?";
trial = input(prompt);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This line calls the local function APDMdataconvert.m which asks the user
% choose the .h5 file to convert into a .m file and stores the IMU sensor
% data in a structure variable called "IMU".
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

APDMdataconvert

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These next lines of code will run the descriptive statistics for the
% lumbar sensors y-vector linear accelerations and store them as variables.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ymean = mean(IMU.Lumbar.accel(:,2));
ystd = std(IMU.Lumbar.accel(:,2));
ymin = min(IMU.Lumbar.accel(:,2));
ymax = max(IMU.Lumbar.accel(:,2));

% The following line of code calculates the linear coefficient of variation 
% of the sensor data for the y-vector.

yCV = ystd/ymean;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These next lines of code create an Excel table that exports these
% descriptive data from MATLAB into a new sheet based on the trial promt
% input from the user.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create MATLAB table
descriptives_table = table(ymean, ystd, ymin, ymax, yCV);

% Call all columns x rows of your MATLAB table
% descriptives_table(:,:);

% Create and write MATLAB table to an Excel file (.xlsx)
filename = 'Trial Descriptives.xlsx';
writetable(descriptives_table, filename, 'Sheet', trial, 'Range', 'A1');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% These next lines of code will run the sample entropy calculations based
% on the code developed by Hurd WJ, Morrow MM, & Kaufman KR (2013), which
% was developed on parameters proposed by Richman JS & Moorman JR (2000) and
% Pincus SM & Goldberger AL (1994).
% The physiologic time series uses a vector length of m = 2 and tolerance
% radius of r = 0.2. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function [e,A,B]
