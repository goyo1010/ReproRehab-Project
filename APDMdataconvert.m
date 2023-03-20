 function APDMdataconvert
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used to convert a .h5 file from APDM Opal sensors
% into a .mat file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Locate file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[filename, pathname] = uigetfile('*.h5','Select an APDM .h5 file');
cd(pathname)

% Read sensor data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First determine whether data is from a v1 or v2 opal
info = h5info(filename);
if strcmpi(info.Groups(1).Name,'/Processed')
    sensortype = 2;
else
    sensortype = 1;
end

% For V2 Opal sensor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if sensortype == 2
    
    % Determine number of sensors
    data_info1 = h5info(filename,'/Sensors');
    data_info2 = h5info(filename,'/Processed');

    num_sensors = length(data_info1.Groups);

    % Get annotation data
    button = h5read(filename,'/Annotations');
    IMU.button.push_time = button.Time;
    IMU.button.sensor = button.SensorID;
    IMU.button.label = cellstr(button.Annotation');

    sensor_names = cell(num_sensors,1); 
    vectorlengths = zeros(num_sensors,1);

    % Get sensor data
    for ii = 1:num_sensors
        % Get sensor data location
        sensor_data_loc1 = data_info1.Groups(ii).Name;
        sensor_data_loc2 = data_info2.Groups(ii).Name;

        % Get sensor label
        sensor_info = h5info(filename,[sensor_data_loc1,'/Configuration']);
        sensor_label = sensor_info.Attributes(1).Value;
        
        if strcmpi(sensor_label,'Left Foot')
            sensor_label = 'LFoot';
        elseif strcmpi(sensor_label,'Right Foot')
            sensor_label = 'RFoot';
        elseif strcmpi(sensor_label,'Left Wrist')
            sensor_label = 'LWrist';
        elseif strcmpi(sensor_label,'Right Wrist')
            sensor_label = 'RWrist';
        elseif strcmpi(sensor_label,'Lumbar')
            sensor_label = 'Lumbar';
        elseif strcmpi(sensor_label,'Sternum')
            sensor_label = 'Sternum';
        end

        sensor_names(ii) = {sensor_label};

        % Get sensor data
        IMU.(sensor_label).accel = h5read(filename,[sensor_data_loc1,'/Accelerometer'])';
        IMU.(sensor_label).gyro = h5read(filename,[sensor_data_loc1,'/Gyroscope'])';
        IMU.(sensor_label).magnet = h5read(filename,[sensor_data_loc1,'/Magnetometer'])';
        IMU.(sensor_label).orien = h5read(filename,[sensor_data_loc2,'/Orientation'])';
        IMU.(sensor_label).baro = h5read(filename,[sensor_data_loc1,'/Barometer']);
        IMU.(sensor_label).temp = h5read(filename,[sensor_data_loc1,'/Temperature']);
        IMU.(sensor_label).time = h5read(filename,[sensor_data_loc1,'/Time']);

%         % Record time vector length for each sensor
    vectorlengths(ii) = length(IMU.(sensor_label).time);
    end

    % Identify if there are different start and end times -- if so trim
    % data so that all sets start and end with the same time.
    
    startTimes = zeros(num_sensors,1);
    endTimes = zeros(num_sensors,1);
    for jj = 1:num_sensors
        startTimes(jj) = IMU.(char(sensor_names(jj))).time(1);
        endTimes(jj) = IMU.(char(sensor_names(jj))).time(end);
    end
    
    useStart = max(startTimes);
    useEnd = min(endTimes);
    
    for jj = 1:num_sensors
        delEntries = IMU.(char(sensor_names(jj))).time < useStart | IMU.(char(sensor_names(jj))).time > useEnd;
        IMU.(char(sensor_names(jj))).time(delEntries) = [];
        if ~isempty(IMU.(char(sensor_names(jj))).accel)
            IMU.(char(sensor_names(jj))).accel(delEntries,:) = [];
        end
        if ~isempty(IMU.(char(sensor_names(jj))).gyro)
            IMU.(char(sensor_names(jj))).gyro(delEntries,:) = [];
        end
        if ~isempty(IMU.(char(sensor_names(jj))).magnet)
            IMU.(char(sensor_names(jj))).magnet(delEntries,:) = [];
        end
        if ~isempty(IMU.(char(sensor_names(jj))).orien)
            IMU.(char(sensor_names(jj))).orien(delEntries,:) = [];
        end
        if ~isempty(IMU.(char(sensor_names(jj))).baro)
            IMU.(char(sensor_names(jj))).baro(delEntries) = [];
        end
        if ~isempty(IMU.(char(sensor_names(jj))).temp)
            IMU.(char(sensor_names(jj))).temp(delEntries) = [];
        end
        vectorlengths(jj) = length(IMU.(char(sensor_names(jj))).time);
    end
       
    % Identify if there are different numbers of data points, make sure all
    % data has the same number of data points as the data set with the most
    % data points
    
    [maxlength, indmax] = max(vectorlengths);

    for jj = 1:num_sensors
        if vectorlengths(jj) == maxlength
            % Remove empty fields
            if length(IMU.(char(sensor_names(jj))).accel) == length(IMU.(char(sensor_names(jj))).time)
            else
                IMU.(char(sensor_names(jj))) = rmfield(IMU.(char(sensor_names(jj))),'accel');
            end
            if length(IMU.(char(sensor_names(jj))).gyro) == length(IMU.(char(sensor_names(jj))).time)
            else
                IMU.(char(sensor_names(jj))) = rmfield(IMU.(char(sensor_names(jj))),'gyro');
            end
            if length(IMU.(char(sensor_names(jj))).magnet) == length(IMU.(char(sensor_names(jj))).time)
            else
                IMU.(char(sensor_names(jj))) = rmfield(IMU.(char(sensor_names(jj))),'magnet');
            end
            if length(IMU.(char(sensor_names(jj))).baro) == length(IMU.(char(sensor_names(jj))).time)
            else
                IMU.(char(sensor_names(jj))) = rmfield(IMU.(char(sensor_names(jj))),'baro');
            end
            if length(IMU.(char(sensor_names(jj))).temp) == length(IMU.(char(sensor_names(jj))).time)      
            else
                IMU.(char(sensor_names(jj))) = rmfield(IMU.(char(sensor_names(jj))),'temp');
            end

        elseif vectorlengths(jj) ~= maxlength
            index = 1:maxlength;
            % Linear interpolate a, w, and m data to match majority of other
            % sensors data points
           
            if length(IMU.(char(sensor_names(jj))).a) == length(IMU.(char(sensor_names(jj))).time)
                IMU.(char(sensor_names(jj))).accel = interp1(double(IMU.(char(sensor_names(jj))).time),IMU.(char(sensor_names(jj))).accel,double(IMU.(char(sensor_names(indmax))).time),'linear','extrap');
            else
                IMU.(char(sensor_names(jj))) = rmfield(IMU.(char(sensor_names(jj))),'accel');
            end
            if length(IMU.(char(sensor_names(jj))).gyro) == length(IMU.(char(sensor_names(jj))).time)
                IMU.(char(sensor_names(jj))).gyro = interp1(double(IMU.(char(sensor_names(jj))).time),IMU.(char(sensor_names(jj))).gyro,double(IMU.(char(sensor_names(indmax))).time),'linear','extrap');
            else
                IMU.(char(sensor_names(jj))) = rmfield(IMU.(char(sensor_names(jj))),'gyro');
            end
            if length(IMU.(char(sensor_names(jj))).magnet) == length(IMU.(char(sensor_names(jj))).time)
                IMU.(char(sensor_names(jj))).magnet = interp1(double(IMU.(char(sensor_names(jj))).time),IMU.(char(sensor_names(jj))).magnet,double(IMU.(char(sensor_names(indmax))).time),'linear','extrap');
            else
                IMU.(char(sensor_names(jj))) = rmfield(IMU.(char(sensor_names(jj))),'magnet');
            end
            if length(IMU.(char(sensor_names(jj))).baro) == length(IMU.(char(sensor_names(jj))).time)
                IMU.(char(sensor_names(jj))).baro = interp1(double(IMU.(char(sensor_names(jj))).time),IMU.(char(sensor_names(jj))).baro,double(IMU.(char(sensor_names(indmax))).time),'linear','extrap');
            else
                IMU.(char(sensor_names(jj))) = rmfield(IMU.(char(sensor_names(jj))),'baro');
            end
            if length(IMU.(char(sensor_names(jj))).temp) == length(IMU.(char(sensor_names(jj))).time)      
                IMU.(char(sensor_names(jj))).temp = interp1(double(IMU.(char(sensor_names(jj))).time),IMU.(char(sensor_names(jj))).temp,double(IMU.(char(sensor_names(indmax))).time),'linear','extrap');
            else
                IMU.(char(sensor_names(jj))) = rmfield(IMU.(char(sensor_names(jj))),'temp');
            end

            % Identify locations of missed data points
            [match, ~] = ismember(IMU.(char(sensor_names(indmax))).time,IMU.(char(sensor_names(jj))).time);
            index_createALL = index(~match);

            new_q = zeros(length(IMU.(char(sensor_names(indmax))).time),4);
            new_q(match,:) = IMU.(char(sensor_names(jj))).orien;

            % Use SLERP to interpolate quaternion
            for qq = 1:length(index_createALL)
                index_create = index_createALL(qq);     
                t1 = IMU.(char(sensor_names(indmax))).time(index_create - 1);
                t2 = IMU.(char(sensor_names(indmax))).time(index_create + 1);
                tc = IMU.(char(sensor_names(indmax))).time(index_create);

                t2 = t2 - t1;
                tc = tc - t1;
                tc = tc/t2;

                q1 = IMU.(char(sensor_names(jj))).q(index_create - 1,:);
                q2 = IMU.(char(sensor_names(jj))).q(index_create,:);
                qc = slerp(q1, q2, tc);

                new_orien(index_create,:) = qc;

            end

            % Correct missing data
            IMU.(char(sensor_names(jj))).orien = new_orien;      
        end
    end

    IMU.button.push_index = zeros(length(IMU.button.push_time),1);

    % Give button pushes an index
    for qq = 1:length(IMU.button.push_time)
        % First search for an exact time match
        findmatch = IMU.(char(sensor_names(1))).time == IMU.button.push_time(qq);
        if sum(findmatch) == 1
            IMU.button.push_index(qq) = find(IMU.(char(sensor_names(1))).time == IMU.button.push_time(qq));
        else
            [~,IMU.button.push_index(qq)] = min(abs(double(IMU.(char(sensor_names(1))).time) - double(IMU.button.push_time(qq))));
        end
    end

    IMU.time = double((IMU.(char(sensor_names(1))).time - IMU.(char(sensor_names(1))).time(1)))/(10^6); % convert time to seconds from micro seconds, start at 0
    IMU.button.push_time = double((IMU.button.push_time - IMU.(char(sensor_names(1))).time(1)))/(10^6);
    IMU.timeRAW = IMU.(char(sensor_names(indmax))).time;

    for ii = 1:num_sensors
        % Delete repeated time vectors (only one is now needed)
        IMU.(char(sensor_names(ii))) = rmfield(IMU.(char(sensor_names(ii))),'time');
    end
    
% % For V1 Opal sensor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% elseif sensortype == 1
%     % Read sensor data
%     caseIdList = h5read(filename,'/','CaseIdList');
%     monitorList = h5read(filename,'/','MonitorLabelList');
% 
%     vectorlengths = zeros(length(caseIdList),1);
% 
%     monitorName = cell(length(caseIdList),1);
%     
%     for jj = 1:length(caseIdList)
% 
%         groupName = caseIdList(jj).data;
%         sensorName = [groupName(1:2) groupName(4:9)];
%         time.(sensorName) = double(hdf5read(filename, [groupName '/Time']));
%        
%         if strcmpi(monitorList(jj).data,'Right Arm')
%             monitorName(jj) = {'RArm'};
%         elseif strcmpi(monitorList(jj).data,'Left Arm')
%             monitorName(jj) = {'LArm'};
%         elseif strcmpi(monitorList(jj).data,'Chest')
%             monitorName(jj) = {'torso'};
%         elseif strcmpi(monitorList(jj).data,'Left Arm Cuff')
%             monitorName(jj) = {'LArm2'};
%         else
%             monitorName(jj) = {monitorList(jj).data};
%         end
% 
%         IMU.(char(monitorName(jj))).a = hdf5read(filename, [groupName '/Calibrated/Accelerometers'])';
%         IMU.(char(monitorName(jj))).w = hdf5read(filename, [groupName '/Calibrated/Gyroscopes'])';
%         IMU.(char(monitorName(jj))).m = hdf5read(filename, [groupName '/Calibrated/Magnetometers'])';
%         IMU.(char(monitorName(jj))).q = hdf5read(filename, [groupName '/Calibrated/Orientation'])';
%         IMU.(char(monitorName(jj))).time = (time.(sensorName) - time.(sensorName)(1))/(10^6); % convert time to seconds starting at zero
% 
%         if strcmpi(monitorName(jj),'trigger')
%             IMU.(char(monitorName(jj))).button = hdf5read(filename, [groupName '/ButtonStatus']);
%         else
%         end
% 
%         % Record time vector length for each sensor
%         % vectorlengths(jj) = length(time.(sensorName));
%     end
% 
%     % Identify if there are different numbers of data points, make sure all
%     % data has the same number of data points as the data set with the most
%     % data points
%     [maxlength, indmax] = max(vectorlengths);
% 
%     for jj = 1:length(caseIdList)
%         if vectorlengths(jj) == maxlength
%         elseif vectorlengths(jj) ~= maxlength
%             index = 1:maxlength;
% 
%             % Linear interpolate a, w, and m data to match majority of other
%             % sensors data points
%             IMU.(char(monitorName(jj))).a = interp1(IMU.(char(monitorName(jj))).time,IMU.(char(monitorName(jj))).a,IMU.(char(monitorName(indmax))).time,'linear','extrap');
%             IMU.(char(monitorName(jj))).w = interp1(IMU.(char(monitorName(jj))).time,IMU.(char(monitorName(jj))).w,IMU.(char(monitorName(indmax))).time,'linear','extrap');
%             IMU.(char(monitorName(jj))).m = interp1(IMU.(char(monitorName(jj))).time,IMU.(char(monitorName(jj))).m,IMU.(char(monitorName(indmax))).time,'linear','extrap');
% 
%             % Identify locations of missed data points
%             [match, ~] = ismember(IMU.(char(monitorName(indmax))).time,IMU.(char(monitorName(jj))).time);
%             index_createALL = index(~match);
% 
%             new_q = zeros(length(IMU.(char(monitorName(indmax))).time),4);
%             new_q(match,:) = IMU.(char(monitorName(jj))).q;
% 
%             if strcmpi(monitorName(jj),'trigger')
%                 new_button = zeros(length(IMU.(char(monitorName(indmax))).time),1);
%                 new_button(match) = IMU.trigger.button;
%             end
% 
%             % Use SLERP to interpolate quaternion
%             for qq = 1:length(index_createALL)
%                 index_create = index_createALL(qq);     
%                 t1 = IMU.(char(monitorName(indmax))).time(index_create - 1);
%                 t2 = IMU.(char(monitorName(indmax))).time(index_create + 1);
%                 tc = IMU.(char(monitorName(indmax))).time(index_create);
% 
%                 t2 = t2 - t1;
%                 tc = tc - t1;
%                 tc = tc/t2;
% 
%                 q1 = IMU.(char(monitorName(jj))).q(index_create - 1,:);
%                 q2 = IMU.(char(monitorName(jj))).q(index_create,:);
%                 qc = slerp(q1, q2, tc);
% 
%                 new_q(index_create,:) = qc;
% 
%                 if strcmpi(monitorName(jj),'trigger')
%                     if IMU.trigger.button(index_create - 1) == IMU.trigger.button(index_create)
%                         new_button(index_create,:) = IMU.trigger.button(index_create);
%                     end
%                 end
%             end
% 
%             % Correct missing data
%             IMU.(char(monitorName(jj))).q = new_q;
% 
%             if strcmpi(monitorName(jj),'trigger')
%                     IMU.trigger.button = new_button;
%             end
% 
%         end
%     end
% 
%     IMU.time = IMU.(char(monitorName(indmax))).time;
% 
%     for bb = 1:length(caseIdList)
% 
%         % Delete repeated time vectors (only one is now needed)
%         IMU.(char(monitorName(bb))) = rmfield(IMU.(char(monitorName(bb))),'time');
% 
%         % Create vectors of button push indexes and times
%         if strcmpi(char(monitorName(bb)),'trigger')
% 
%             % Identify locations of button pushes
%             button_push = [0; diff(double(IMU.trigger.button))];
%             push_index = zeros(sum(diff(IMU.trigger.button)),1);
%             aa = 1;
%             for qq = 1:length(button_push)
%                 if button_push(qq) == 1
%                     push_index(aa) = qq;
%                     aa = aa + 1;
%                 else
%                 end
%             end
% 
%             IMU.button.push_index = push_index;
%             IMU.button.push_time = IMU.time(push_index);
%         else
%         end
% 
%     end
% 
%     if isfield(IMU,'trigger')
%         % Trigger data is no longer needed
%         IMU = rmfield(IMU,'trigger');
%     else
%     end
%     
% end

% Save data
save(filename(1:(end-3)), 'IMU', '-v7.3')

end
    
% function [qm] = slerp(qi, qn, t)
% %       Sagi Dalyot %
% 
% %       This routine aims for calculating a unit quaternion,  describing a rotation matrix,
% %       which lies between two known unit quaternions - q1 and q2,
% %       using a spherical linear interpolation - Slerp.
% %       Slerp follow the shortest great arc on a unit sphere,
% %       hence, the shortest possible interpolation path.
% %       Consequently, Slerp has constant angular velocity, 
% %       so it is the optimal interpolation curve between two rotations.
% %       (first published by Sheomake K., 1985 - Animating Rotation with Quaternion Curves)
% 
% %       end of file ->  explnation of rotation matrix and quaternions
% 
% %       in general:
% %       slerp(q1, q2, t) = q1*(sin(1-t)*teta)/sin(t) + q2*(sin(t*teta))/sin(teta)
% %       where teta is the angle between the two unit quaternions,
% %       and t is between [0,1]
% 
% %       two border cases will be delt:
% %       1: where q1 = q2 (or close by eps)
% %       2: where q1 = -q2 (angle between unit quaternions is 180 degrees).
% %       in general, if q1=q2 then Slerp(q; q; t) == q
% 
% 
% %       where qi=[w1 x1 y1 z1] - start unit quaternions
% %                      qn=[w2 x2 y2 z2] - end unit quaternions
% %                      t=[0 to 1]
% %                      eps=threshold value
% 
% if t==0 % saving calculation time -> where qm=qi
%     qm=qi;
%     
% elseif t==1 % saving calculation time -> where qm=qn
%     qm=qn;
%     
% else
% 
%     C=dot(qi,qn);                  % Calculating the angle beteen the unit quaternions by dot product
% 
%     teta=acos(C);
% 
% %         if (1 - C) <= eps % if angle teta is close by epsilon to 0 degrees -> calculate by linear interpolation
% %             qm=qi*(1-t)+qn*t; % avoiding divisions by number close to 0
% % 
% %         elseif (1 + C) <= eps % when teta is close by epsilon to 180 degrees the result is undefined -> no shortest direction to rotate
% %             q2(1) = qi(4); q2(2) = -qi(3); q2(3)= qi(2); q2(4) = -qi(1); % rotating one of the unit quaternions by 90 degrees -> q2
% %             qm=qi*(sin((1-t)*(pi/2)))+q2*sin(t*(pi/2));
% % 
% %         else
%             qm=qi*(sin((1-t)*teta))/sin(teta)+qn*sin(t*teta)/sin(teta);
% %         end
% end
% end
