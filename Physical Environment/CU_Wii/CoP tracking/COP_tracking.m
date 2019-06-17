% bbrecord is a script that runs a user friendly interface for viewing
% center of pressure data from a Wii Balance Board
%
% It uses the WiiLab patch that includes balance board support,
% http://klab.wikidot.com/wii-proj) 
% 
% System requirements: Windows XP & Matlab R2007a
%
% Authors of bbrecord: Members of the University of Colorado, Boulder 
% Neuromechanics Lab (PI Alaa Ahmed)

% versions 1_1-1_4: Andrew Kary
% version 1_0: Helen J. Huang, Sergio Perez

% this version fixes an error that existed in version 1_3 in which
% sequential trials could not be recorded using timed recording.

% Future ideas:
% fix the mysterious issue, don't use the run twice hack
% clean up the code, use data structures
% add functionality for opening and plotting old trial data using winopen

%% Setting the path
% close all; clc; clear all;
% first = 1;

global bb f go flag_saving connected quitgui collecting filename ...
    deletedfile enable_results reset C sensor_avg_upright saveduration ...
    h_timerinput h_startbutton h_timerbutton flag_stop flag_timed...
    flag_start starttoggle Upper_time drivename h_resultsbutton;

% housekeeping
if ~exist('connected','var') || isempty(connected)
    clear all;
    delete first.mat;
end
close all; clc; clear first

% find the path for this m file
thisone = mfilename('fullpath');
backslashes = find(thisone == '\');
thispath = thisone(1:(backslashes(end)-1));
cd (thispath) % make sure that we are in the directory of this file
% check if this is the first time that bbrecord has been run 
if ~exist('first.mat','file') || isempty(drivename)
    first = 1;    
else
    load first;
end

if first == 1
    
    % find the address of the directory
    [stat,drive] = fileattrib;

    % find all of the slashes
    slashes = find('\' == drive.Name);

    % find the address of the folder that the directory is nested inside of
    drivename = drive.Name( 1 : slashes(end)-1 );

    % add the path of the home folder, CU_Wii
    addpath([drivename '\CU_Wii'])
    
    % add the path containing the Wii balance board function we wrote
    addpath([drivename '\CU_Wii\WiiBBFunctions'])

    % add the path containing simple graphics functions of WiiLAB
    addpath([drivename '\WiiLAB\WiiLAB_Matlab\EG111-H'])

    % add the path containing the Wiimote functions of WiiLAB
    addpath([drivename '\WiiLAB\WiiLAB_Matlab\WiimoteFunctions'])

    % create sound player
    [Y,FS] = audioread('bloop.au');
    
    player = audioplayer(Y, FS);
    
    save first first
end

%% Make sure that MATLAB talks to the Balance Board

if ~exist('connected','var') || (isempty(connected)) || (connected == 0)

    % from WiiLAB wiimote.m
    bb = Wiimote();
    bb.Connect(); % connect to balance board

    connected = 1;

end

%% !! PARAMETERS TO SET !!

if first == 0
    % set path for saving data
    pathname = [drivename '\CU_Wii\Data'];

    % change to that directory
    cd(pathname);

%     answer = questdlg('Would you like to open the data folder?', ...
%         'View Data Folder?', 'Yes', 'No','Yes');
%     switch answer,
%         case 'Yes',
%             winopen(pathname);
%         case 'No',
%             cal = 0;
%     end


end

%% Balance Board Data

% check that the balance board is REALLY connected
if bb.isConnected() > 0

    %     bb.wm.GetBalanceBoardCoGState(); % returns rough values for the center-of-pressure into variable called 'cog' x,y [cm]. positive direction is right, back
    %     bb.wm.GetBalanceBoardSensorState(); % returns values for the 4 sensors into a variable called 'sensors' [no obvious units]
    %     bb.wm.GetBatteryState(); % 1 for full charge, 0 for absolutely empty

%% Calibrate
    if first == 0

        if ~exist('sensor_avg_upright','var') || isempty(sensor_avg_upright) || C(1) == 0
%             cal = 1; % do this if the BB has not been calibrated
        else
            % do this if the BB has been calibrated
         end

%         if cal == 1
%             [C, quitgui, sensor_avg_upright ] = OneWeightCalibrate (bb); % calibrate
%         end
        


       
    end
%End of balance board setup
%% !! PARAMETERS TO SET !!
    XMaxWeight = 14;
    XMinWeight = -14;
    YMaxWeight = 10;
    YMinWeight = -10;
    zeroX = 0;
    zeroY = 0;
dim = 4; %The width of the green target square
halfdim = dim / 2;
devdim = dim + 3; %The width of the yellow target square

Atar = [XMinWeight/2, YMaxWeight - halfdim]; %Center coordinates of target A
Btar = [XMaxWeight - halfdim, YMaxWeight - halfdim]; %Center coordinates of target B
Ctar = [XMinWeight + halfdim, 0]; %Center coordinates of target C
Dtar = [2 + halfdim, 0]; %Center coordinates of target D
Etar = [0 - halfdim, YMinWeight + halfdim]; %Center coordinates of target E
Ftar = [(XMaxWeight - 2) - halfdim, YMinWeight + halfdim]; %Center coordinates of target F
targets = [Etar; Ctar; Atar; Btar; Dtar; Ftar]; %All of the targets combined into one 2D array, in the correct order


screensize = get(0,'ScreenSize');
f1 = figure('Name','Wii Balance Board COP tracking','units','normalized','outerposition',[0 0 1 1]);
clf(f1);
% set(f1,'WindowKeyPressFcn',@keyPressCallback);

% set(f1,'WindowKeyPressFcn',[cogg(1)]= keyPressCallback);
% figure('units','normalized','outerposition',[0 0 1 1]);
   % Create push button
%     btn = uicontrol('Style', 'pushbutton', 'String', 'Clear',...
%         'Position', [20 20 50 20],...
%         'Callback', 'cla'); 


choices = {'start','stop'};
% title('LEFT Calibration');


    %# create GUI figure - could set plenty of options here, of course
% guiFig = figure;

%# create callback that stores the state in UserData, and picks from
%# one of two choices

% cbFunc = @(hObject,eventdata)set(hObject,'UserData',~get(hObject,'UserData'),...
%           'string',choices{1+get(hObject,'UserData')});
%       
% 
% %# create the button
% uicontrol('parent',f1,'style','pushbutton',...
%           'string','start','callback',cbFunc,'UserData',true); %,...
          %'units','normalized','position',[0.4 0.4 0.2 0.2]);
 
set(f1,'Visible','on'); % show the figure 

disp('Openning the file...');
COPdata = fopen('COPcoordinates.txt','w'); %Create a text file to save the collected data to at the end of the trial
fprintf(COPdata, 'COPx\t\tCOPy coordinates\n');
fclose(COPdata);
uiwait(msgbox({'Press SPACEBAR if you want to record COP coordinates.';'Close Matlab figure if you want to quit.'},'Wii Message','modal'))
   while (1) 
       
                    
   cogg = bb.wm.GetBalanceBoardCoGState(); % find the center of pressure  
   
   if (ishandle(f1))
        set(f1,'KeyPressFcn',@(fig_obj, eventDat) keyPressCallback(fig_obj, eventDat, cogg));
   else
       quitgui = 1;
       break;
   end
   
%     if (cogg(1)<xmin)
%         xmin = cogg(1);
%     end
    if (ishandle(f1))
        plot(cogg(1), -cogg(2),'ko', 'MarkerFaceColor','k', 'MarkerSize', 10);
        axis([-22.5 22.5 -13 13]);
        xlabel('X [cm]')
        ylabel('Y [cm]')
%         title('LEFT Calibration')

        set(gca, 'fontsize', 13); grid on;
        
        
                        for i=1:6
                        %target X,Y coordinates: x1,x2,y1,y2
                        point(1) = targets(i, 1) - dim;
                        point(2) = targets(i, 1) + dim;
                        point(3) = targets(i, 2) - dim;
                        point(4) = targets(i, 2) + dim;
                        
                        % points of the target square.
                        X=[point(1), point(2)];
                        Y=[point(3), point(3)];
                        X1=[point(2), point(2)];
                        Y1=[point(3), point(4)];
                        X2=[point(1), point(1)];
                        Y2=[point(4), point(4)];
                        
                       line(X,Y);
                       line(X1,Y1);
                       line(X,Y2);
                       line(X2,Y1);                        

                       end
        
        
         pause(0.001);    
    else
        quitgui = 1;
        break;
    end

   end

rng('shuffle')



%% Create GUI figure for displaying BB data

if first == 0
    
    saveduration = 10; % How long do you want to save the data for by default?
    cycletime = 1/30 ; % how long should each iteration take? [seconds]
    Upper_time = 3600; % longest allowable trial [s]

    % Initialize variables
    reset = 1;


    
end

%% Get BB Data
    if first == 0
        
        % initialize
        quitgui = 0; % 1 for quit
         
    else
        first = 0;
        save first first
%         run (thisone) 
        delete first.mat;
        % this runs the script a second time. this is really a hack, but it
        % solves a mysterious problem. for an unknown reason, the script
        % would not work right until the second time it was run.
        % clear ardButton;
        
    end

%     close all

else
    error('BB is not connected. Try restarting MATLAB')
end

