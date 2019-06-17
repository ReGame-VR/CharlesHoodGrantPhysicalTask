%New_MasterArduino_WiiFitBoard

%%clear variables from workspace
clear;  %all


%% Setting the path

global bb f go flag_saving connected quitgui collecting filename ...
    deletedfile enable_results reset C sensor_avg_upright saveduration ...
    h_timerinput h_startbutton h_timerbutton flag_stop flag_timed...
    flag_start starttoggle Upper_time drivename h_resultsbutton;

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
    
    %% Make sure that MATLAB talks to the Balance Board

if ~exist('connected','var') || (isempty(connected)) || (connected == 0)

    % from WiiLAB wiimote.m
    bb = Wiimote();
    bb.Connect(); % connect to balance board

    connected = 1;

end

%% Balance Board Data

% check that the balance board is REALLY connected
if bb.isConnected() > 0

    %     bb.wm.GetBalanceBoardCoGState(); % returns rough values for the center-of-pressure into variable called 'cog' x,y [cm]. positive direction is right, back
    %     bb.wm.GetBalanceBoardSensorState(); % returns values for the 4 sensors into a variable called 'sensors' [no obvious units]
    %     bb.wm.GetBatteryState(); % 1 for full charge, 0 for absolutely empty

if ~exist('XMaxWeight','var') || ~exist('XMinWeight','var') || ~exist('YMaxWeight','var') || ~exist('zeroX','var') || ~exist('YMinWeight','var') || ~exist('zeroY','var')
    XMaxWeight = 14;
    XMinWeight = -14;
    YMaxWeight = 10;
    YMinWeight = -10;
    zeroX = 0;
    zeroY = 0;
end

C = [5, 5, 5, 5];
        sensor_avg_upright = [-4.9, -3.7, -0.35, -0.89];
        
        if(~exist('subID'))
           subID = 'default_';
           disp('subID given default value');
        end

        if ~exist('sensor_avg_upright','var') || isempty(sensor_avg_upright) || C(1) == 0
            cal = 1; % do this if the BB has not been calibrated
        else
            % do this if the BB has been calibrated
            answer = questdlg('Would you like to change the subject ID?', ...
                'Calibrate?', 'Yes', 'No','Yes');
            switch answer
                case 'Yes'
                    cal = 1;
                case 'No'
                    cal = 0;
            end
        end
       

        if cal == 1 %if yes was selected by the user 
            prompt = 'Enter the ID of the subject:\n';
            subID = input(prompt,'s');          
            %[C, quitgui, sensor_avg_upright ] = OneWeightCalibrate (bb); % calibrate
          %  [zeroX, zeroY, XMaxWeight, XMinWeight, YMaxWeight, YMinWeight] = getMaxWeight(bb); %weight shift bounds calibration
%             [zeroX, zeroY, XMaxWeight, XMinWeight, YMaxWeight, YMinWeight] = getMaxWeight(bb); %weight shift bounds calibration
            answer = questdlg('Subject taking trial is short or tall?', ...
                             'View Data Folder?', 'Short', 'Tall','Yes');
            %change max/min weight based on short/tall
            switch answer
                case 'Short'
                    XMaxWeight = 12;
                    XMinWeight = -12;
                    YMaxWeight = 8;
                    YMinWeight = -8;    
                case 'Tall'
                    XMaxWeight = 14;
                    XMinWeight = -14;
                    YMaxWeight = 10;
                    YMinWeight = -10;
            end

        end
        dt = datetime('now');
        DateString = datestr(dt);
            dt = datetime('now');
            DateString = datestr(dt);
            DateString(regexp(DateString,'[-, ,:]'))=[];
            dateToday = datestr(now,'mmmm dd, yyyy');
            
            dim = 6; %The width of the green target square
            halfdim = dim / 2;
            devdim = dim + 3; %The width of the yellow target square       
            
            Atar = [XMinWeight/2, YMaxWeight - halfdim]; %Center coordinates of target A
            Btar = [XMaxWeight - halfdim, YMaxWeight - halfdim]; %Center coordinates of target B
            Ctar = [XMinWeight + halfdim, 0]; %Center coordinates of target C
            Dtar = [2 + halfdim, 0]; %Center coordinates of target D
            Etar = [0 - halfdim, YMinWeight + halfdim]; %Center coordinates of target E
            Ftar = [(XMaxWeight - 2) - halfdim, YMinWeight + halfdim]; %Center coordinates of target F

            %%%Setting up: formatting and saving the COP data to an excel
            %%%file            

            VRString = strcat(subID, 'VRData', DateString, '.txt');
            CoPString = strcat(subID,'CoPData', DateString, '.txt');
            
            VRdata = fopen(VRString,'w'); %Create a text file to save the collected data to at the end of the trial
            fprintf(VRdata,'\t\t\tCalibration results:\n\n');
            fprintf(VRdata,'\t zeroX \t zeroY \t XMaxWeight \t XMinWeight \t YMaxWeight \t YMinWeight\n');
            formatSpec = '\t %3.2f \t %3.2f \t %3.2f \t %3.2f \t %3.2f \t %3.2f \n';
            fprintf(VRdata, formatSpec, zeroX, zeroY, XMaxWeight, XMinWeight, YMaxWeight, YMinWeight);

            VRdata = fopen(VRString,'a'); %Create a text file to save the collected data to at the end of the trial
            fprintf(VRdata,'\n\n\t centerAx \t centerAy \t centerBx \t centerBy \t centerCx \t centerCy \t centerDx \t centerDy \t centerEx \t centerEy \t centerFx \t centerFy\n');
            formatSpec = '\t %3.2f \t %3.2f \t %3.2f \t %3.2f \t %3.2f \t %3.2f \t %3.2f \t %3.2f \t %3.2f \t %3.2f \t %3.2f \t %3.2f \n';
            fprintf(VRdata, formatSpec, Atar(1), Atar(2), Btar(1), Btar(2), Ctar(1), Ctar(2), Dtar(1), Dtar(2), Etar(1), Etar(2), Ftar(1), Ftar(2));
            
            VRdata = fopen(VRString,'a'); %Create a text file to save the collected data to at the end of the trial
            fprintf(VRdata, '\n\n\t trialNum \t date \t time \t targetlNum \t targetTime \t Weightshift success \t button success \t random or set sequence \t X coord of target \t Y coord of target \t COPtotalpath \t ScorePerTarget \t ScorePerTrial \t CumulativeScore \n\n');
            fclose(VRdata);

            CoPdata = fopen(CoPString,'w'); %Create a text file to save the collected center of pressure data to at the end of the trial
            fprintf(CoPdata, '\t time \t\t X \t\t Y\n\n');
            fclose(CoPdata); 
            
            
            %% !! PARAMETERS TO SET !!
dim = 6; %The width of the green target square
halfdim = dim / 2;
devdim = dim + 3; %The width of the yellow target square

%target locations on bb
Atar = [XMinWeight/2, YMaxWeight - halfdim]; %Center coordinates of target A
Btar = [XMaxWeight - halfdim, YMaxWeight - halfdim]; %Center coordinates of target B
Ctar = [XMinWeight + halfdim, 0]; %Center coordinates of target C
Dtar = [2 + halfdim, 0]; %Center coordinates of target D
Etar = [0 - halfdim, YMinWeight + halfdim]; %Center coordinates of target E
Ftar = [(XMaxWeight - 2) - halfdim, YMinWeight + halfdim]; %Center coordinates of target F
targets = [Etar; Ctar; Atar; Btar; Dtar; Ftar]; %All of the targets combined into one 2D array, in the correct order

score = 0;
cum_score = 0;
trial_score = 0;
timeout = 0;
time = 0;
valid = 0;
            
    

%comPortB = 'COM3'; %This is the arduino that controls the buttons   
delete(instrfindall);
setSeq = [4, 1, 3, 5, 2]; %Set the predefined sequence here
sequenceLength = numel(setSeq);

testTime = 10; %Set the amount of time you want for the subject to touch the button, in seconds
trialNum = 5; %Set the number of trials you would like to do in a row
waitTime = 0; %Set the amount of time the subject needs to be correctly weight shifted before the trial is counted as a success

button = 0;
count = 1; %Position in data array
datacount = 1; %Position in center of pressure data array
side = 0; %Variable to determine which weight shift number is needed. 1 is left, 2 is right
dataToWrite = [0, 0, 0, 0, 0, 0, 0]; %Initialize the data array with 0s
%The 6 values are cputime, trial num, trial time, weight shift success, button success,
%and random or set sequence

%This makes it so you don't have to manually add the arduino path each time
%This is specific to this computer, arduino packages may be somewhere else
%for a different computer
addpath(genpath('C:\MATLAB\SupportPackages\R2015b'));

%%SERIAL SETUP
comPortL = 'COM14';%'COM3'; %Set the com port the arduino is connected to here. To find that type instrfind
%ardLight = setupSerial(comPortL); %Let setupSerial set up the serial connection at the defined port
s=serial(comPortL,'BaudRate',19200);   %%TESTING BAUD RATE 19200 TO HELP BUFFER ISSUE/LAG
s.InputBufferSize = 512;
fopen(s);
get(s)  %show serial diagnostics

%% Create GUI figure for displaying BB data

    saveduration = 10; % How long do you want to save the data for by default?
    cycletime = 1/30 ; % how long should each iteration take? [seconds]
    Upper_time = 3600; % longest allowable trial [s]
    
    screensize = get(0,'ScreenSize');
  
    mntrs = get(0, 'MonitorPositions');
    %Displays the score after the trial
    scorefig = figure('Position', [0 0 500 500], 'Name', 'Score Window');
    axis off;
    set(gcf,'color','white')
    
    %     text(.7, .1, 'Current Score: ', 'fontsize', 13);
%     scoreForm = text(0.85, .1, '0', 'fontsize', 13);
%     scorefig = figure('Position', [0 0 500 500], 'Name', 'Score Window');
    text(.1, .7, 'trial score: ', 'fontsize', 26);
    scoreForm = text(0.5, .7, '0', 'fontsize', 26);
    text(.1, .6, 'total score: ', 'fontsize', 26);
    cumScore = text(0.5, .6, '0', 'fontsize', 26);
    msg = text(.1, .5, ' ', 'fontsize', 26);
    set(scorefig,'Visible','on'); % show the figure
    
    f = figure('Visible','off','color',[0.8 0.8 0.8],'units','normalized','outerposition',[0 0 1 1],'Name','Wii Balance Board GUI');
%     f = figure('Visible','off','color',[0.8 0.8 0.8],'units','normalized','Position', [0 0 mntrs(1,3) mntrs(1,4)],'Name','Wii Balance Board GUI');
    % maxfig(f,1);

    subplot('position', [.1  .8  .8  .2]);
    set(gca, 'visible','off','Units', 'normalized');

    x1 = -.1;
    x2 = .05;
    x3 = .15;
    x4 = .26;
    x5 = .7;
    x6 = 0.5;
    
    y0 = .7;
    y1 = .6;
    y2 = .5;
    y3 = .3;
    y4 = .2;
    y5 = .1;

    % COP Text
    x_copDispLbl = text(x1,0.9,'CoP X [cm] = ','fontsize', 13);
    y_copDispLbl = text(x1,0.8,'CoP Y [cm] = ','fontsize', 13);
    x_copDisp = text(x2, 0.9, 'xx','fontsize', 13);
    y_copDisp = text(x2, 0.8, 'xx','fontsize', 13);

    % Force sensor values
    bb_BLDispLbl = text(x1, 0.6, 'Bottom Left force [kgf] = ','fontsize', 13);
    bb_BRDispLbl = text(x1, 0.5, 'Bottom Right force [kgf] = ','fontsize', 13);
    bb_TLDispLbl = text(x1, 0.4, 'Top Left force [kgf] = ','fontsize', 13);
    bb_TRDispLbl = text(x1, 0.3, 'Top Right force [kgf] = ','fontsize', 13);
    bb_TotalispLbl = text(x1, 0.15, 'Total force [kgf] = ','fontsize', 13);

    bb_BLDisp = text(x3, 0.6, 'xx','fontsize', 13);
    bb_BRDisp = text(x3, 0.5, 'xx','fontsize', 13);
    bb_TLDisp = text(x3, 0.4, 'xx','fontsize', 13);
    bb_TRDisp = text(x3, 0.3, 'xx','fontsize', 13);
    bb_Totaldisp = text(x3, 0.15, 'xx','fontsize', 13);

    % Text indicating some Parameters
    text(x5, y1, 'Number of trials:', 'fontsize', 13);
    text(x5, y3, 'Current sequence: ', 'fontsize', 13);
    text(x5, y2, 'Light Number: ', 'fontsize', 13);
    text(x5, y4, 'Elapsed Time: ', 'fontsize', 13);
 
    xrange = text(0.85, y1, 'xx', 'fontsize', 13);
    xmean = text(0.85, y2, 'xx', 'fontsize', 13);

    yrange = text(0.85, y3, 'xx', 'fontsize', 13);
    ymean = text(0.85, y4, 'xx', 'fontsize', 13);
    
    %set up target locations on bb
    for i=1:6
        point(1) = targets(i, 1) - halfdim;
        point(2) = targets(i, 1) + halfdim;
        point(3) = targets(i, 2) - halfdim;
        point(4) = targets(i, 2) + halfdim;
                        
        % points of the target square.
        X=[point(1), point(2)];
        Y=[point(3), point(3)];
        X1=[point(2), point(2)];
        Y1=[point(3), point(4)];
        X2=[point(1), point(1)];
        Y2=[point(4), point(4)];
        
        subplot('position',[.1  .1  .8  .7]);
        axis([-22.5 22.5 -13 13]);
        line(X,Y);
%         line(X2_cor,Y1_cor,'Color','r');
        line(X1,Y1);
        line(X,Y2);
        line(X2,Y1);
%         line(X_cor,Y_cor,'Color','r');
%         line(X1_cor,Y1_cor,'Color','r');
%         line(X_cor,Y2_cor,'Color','r');
        xlabel('X [cm]');
        ylabel('Y [cm]');
        set(gca, 'fontsize', 13); grid on;
%         legend({'Original targets', 'Targets after calibration'},'FontSize',8,'FontWeight','bold')
        
        
    end
    % Text indicating SCORE Parameters
%     text(.2, .1, 'Score on trial:', 'fontsize', 13);
%     text(.2, .3, 'Cumulative score: ', 'fontsize', 13);

    % Initialize variables
    reset = 1;

%% Get BB Data
   % initialize
        quitgui = 0; % 1 for quit

        while quitgui == 0   %%this loop keeps the gui displayed

            % get rid of old data
            if reset == 1
                
                                reset = 0; % don't need to reset anymore
                timestartsaving = 0; currentsaveduration = 0;
                iter = 0; % loop iteration number
                go = 1; % set go = 1 to execute loop, after reaching saveduration, go set to 0, stopping the loop
                collecting =1;
                trials = 0; % number of trials so far
                color = 'k';
                deletedfile = 0;
                enable_results = 0;
                starttoggle = 1;
                clear answer
                datalog = zeros(2*Upper_time/cycletime,8);
                fclose all;

%                 if flag_timed == 1
%                     set(h_timerinput,'Enable','on');
%                 end
                
%                 formatSpecScore = {'Your score is: %4.2f.' 'Your Cumulative score is: %4.2f'};
%                 str = sprintf(formatSpecScore,score, cum_score);
%                 ScoreTrialBox = msgbox({'Your score is: 0.00.' 'Your Cumulative score is: 0.00'});
%                 set(ScoreTrialBox,'color',.85*[1 1 0]);

                set(f,'Visible','on'); % show the figure
                tStart = tic; % reset stopwatch
                
            end  %%end of reset loop
            
            while go == 1   %%%%%CORRESPONDS WITH LINE 460 ON ORIGINAL
                
                for j = 1:trialNum  %%%
                                    
%                     trial_score = 0;
                    figure(scorefig);  %displays the figure with the trial/total score
                    set(scoreForm, 'String', trial_score);
                    set(cumScore, 'String', cum_score);
                    
                    if j>1
                        %text(.1, .5, 'Good job! Try to beat this score!', 'fontsize', 26);
                        set(msg,'String', 'Good job! Try to beat this score!');
                    end
                    
                    trialBox = msgbox('Press the SPACEBAR to start the next trial or press the Q key to quit');
                    movegui(trialBox, 'north');
                    
                    currkey = getkey;
                    while currkey ~= 32 && currkey ~= 113 %Get stuck in this while loop until the user presses key 32 (SPACEBAR) or key 113 (Q)
                        currkey = getkey;
                    end
                    delete(trialBox); %Get rid of the message box after the user presses the SPACEBAR or Q
                    
                    if currkey == 113 %Check for a press of key 113 (Q)
                        go = 2
                        quitgui = 1
                        break
                    end
                    
                    %%%!!!!check what this does exactly to the score box
                    set(msg, 'String', ' ');
                    trial_score = 0;
                    set(scoreForm, 'String', trial_score);
   
                    %% 
                    
                    
                    decide = randi([0,1]) %Randomly choose random or set sequence
                    %%% 0 IS SET SEQUENCE 1 IS RANDOM
    
 %%%START OF LOOPING THROUGH THE 5 TARGETS 
                    for i = 1:sequenceLength
                        figure(f); %Reset the figure
                        set(0,'CurrentFigure',f)
                        button = 0;
                        wghtScs = 0;
                        btnScs = 0;
                        timeout = 0;
                        time = 0;
                        valid = 0;
                        targetTime = 10.00;
                        COP_length = 0;
                        COP_distance = 0;
                        p1 = zeros(1,2);
                        p2 = zeros(1,2); %initialize the coordinates of two points to be both (0,0)
                       
                        
                        
                        %%% i IS CURRENT ATTEMPT 1-5 NOW
                        
                        %%%%SET UP THE ORDER OF TARGETS
                        
                        if decide == 0 %Use the set sequence
                            lightNum = setSeq(i);
                        elseif decide == 1   %use a random target
                              lightNum = randi([1,6]);
                           
                            if i == 1
                                pastLightNum(i) = lightNum;
                            else 
                                while lightNum == pastLightNum(i-1)  %if the random target is the same as the last one use a new random one
                                    lightNum = randi([1,6]);
                                end
                                pastLightNum(i) = lightNum;
                            end
                        end
                        
                        %target X,Y coordinates: x1,x2,y1,y2
                        point(1) = targets(lightNum, 1) - halfdim;
                        point(2) = targets(lightNum, 1) + halfdim;
                        point(3) = targets(lightNum, 2) - halfdim;
                        point(4) = targets(lightNum, 2) + halfdim;
                        
                        % points of the target square.
                        X=[point(1), point(2)];
                        Y=[point(3), point(3)];
                        X1=[point(2), point(2)];
                        Y1=[point(3), point(4)];
                        X2=[point(1), point(1)];
                        Y2=[point(4), point(4)];
                        
                        %devtarget X,Y coordinates: x1,x2,y1,y2
                        devtarget(1) = targets(lightNum, 1) - devdim;
                        devtarget(2) = targets(lightNum, 1) + devdim;
                        devtarget(3) = targets(lightNum, 2) - devdim;
                        devtarget(4) = targets(lightNum, 2) + devdim;
                        
                        % points of the target square.
                        devX=[devtarget(1), devtarget(2)];
                        devY=[devtarget(3), devtarget(3)];
                        devX1=[devtarget(2), devtarget(2)];
                        devY1=[devtarget(3), devtarget(4)];
                        devX2=[devtarget(1), devtarget(1)];
                        devY2=[devtarget(4), devtarget(4)];
               
                        tic
                        newTrial = true;  %%set the trial as new for the first iteration
                        togglePoint = 1;
                        
                 
                        
                        %%%TARGET COMMAND SIGNALS
                        target = lightNum; 
                        target = num2str(target);
                        start_signal = '1';
                        continue_signal = '0';
                        green_signal = '1';
                        yellow_signal = '2';
                        red_signal = '3';
                        motor_signal = '1';
                        
                        % flushinput(s);
                        %flushoutput(s);
                        %% 
                        %use this to listen for signal to end the target
                        %attempt from the arduino 
                        %will send for either end of time or a touch
                        target_end_signal = 0;  
                        first_loop_signal = 0;
                        loop_counter = 0;
                        disp('starting target loop');  %%TEST 
                        
                        while (target_end_signal == 0) 
                            pause(0.005); %%0.001
                            
                            %if there is serial data from arduino break the
                            %loop and input data
                            %%%%check the contents of the message to make
                            %%%%sure its from the correct target!!!
                            %%%doing this to prevent false failure signal
                         
                            x = s.BytesAvailable;
                           if (x > 0)
                            % Read until newline
                             in = fgetl(s);
                             target_end_signal = 1
                             break

                          end
                            
                            if (loop_counter == 0);
                                first_loop_signal = 1;
                                disp('first loop');  %%TEST
                               
                            else
                                first_loop_signal = 0;
                            end
                    
                            loop_counter = loop_counter + 1; 
                            
                            iter = iter + 1; %increment iteration counter

                            %data.bb.time(iter) = toc(tStart); % find the elapsed time now
                            cog = bb.wm.GetBalanceBoardCoGState(); % find the center of pressure
                            CoPDataArr(datacount, :) = [cputime, cog(1), -cog(2)];
                            datacount = datacount + 1;
                            sensors = (bb.wm.GetBalanceBoardSensorState()-sensor_avg_upright)./C; % find the force on each sensor, calibrated
                            
                            if (newTrial)
                                p1(1) = cog(1);
                                p1(2) = -cog(2);
                                newTrial = false;
%                                 disp(p1);
%                                 disp(p2);
                            else
                                if(togglePoint)
                                   p2(1) = cog(1);
                                   p2(2) = -cog(2);
                                else
                                   p1(1) = cog(1);
                                   p1(2) = -cog(2);
                                end
%                                 disp(p1);
%                                 disp(p2);
                                togglePoint = 1 - togglePoint; % toggle the point the current COP coordinates are written to.
                                COP_distance = sqrt((abs(p1(1)-p2(1)))^2 + (abs(p1(2)-p2(2)))^2); % calculate the distance between the current consequtive COP point
                                COP_length = COP_length + COP_distance;
                            end  %end of it(newTrial)
                            
                            %%%%%CHECK THE SERIAL BUFFER FOR TARGET
                            %%%%%RESPONSE
%                          if (s.BytesAvailable > 0)
%                               pause(0.002);
%                             % Read until newline
%                             in = fgetl(s);
%                              target_end_signal = 1;
%                              break
% 
%                          end
                            
                            
                          
                            % fix iteration duration
                            t_el = toc(tStart);
                            if t_el/iter < cycletime
                                 pausetime = (cycletime*iter) - t_el;
                                 pause (pausetime)
                            end

                            % change text on GUI
                            set(xrange, 'String', trialNum);
                            set(xmean, 'String', lightNum);
                            set(yrange, 'String', i);
                            set(ymean, 'String', toc);

                            set(x_copDisp, 'String', cog(1));
                            set(y_copDisp, 'String', -cog(2));
                            set(bb_BLDisp, 'String', sensors(1));
                            set(bb_BRDisp, 'String', sensors(2));
                            set(bb_TLDisp, 'String', sensors(3));
                            set(bb_TRDisp, 'String', sensors(4));
                            weight = sum(sensors);
                            set(bb_Totaldisp, 'String', weight);


                            % plot the CoP
                            size = weight/1.5;
                            if size < 1
                                size = 1;
                            end
                            
                            %CHECKING TARGET COLOR, SERIAL COMM 
                            
                            if devtarget(1)<=cog(1)&& cog(1)<=devtarget(2) && devtarget(3)<=-cog(2)&& -cog(2)<=devtarget(4) % COP is inside yellow area
                                wghtScs = 1;
                                if point(1)<=cog(1)&& cog(1)<=point(2) && point(3)<=-cog(2)&& -cog(2)<=point(4) % COP is inside the green area
                                    greenStart = tic; %Reset stopwatch
                                    %while point(1)<=cog(1)&& cog(1)<=point(2) && point(3)<=-cog(2)&& -cog(2)<=point(4) && toc < testTime
                                        figure(f); %Reset the figure

                                        % change text on GUI
                                        set(xrange, 'String', trialNum);
                                        set(xmean, 'String', lightNum);
                                        set(yrange, 'String', i);
                                        set(ymean, 'String', toc);
                                        set(x_copDisp, 'String', cog(1));
                                        set(y_copDisp, 'String', -cog(2));
                                        set(bb_BLDisp, 'String', sensors(1));
                                        set(bb_BRDisp, 'String', sensors(2));
                                        set(bb_TLDisp, 'String', sensors(3));
                                        set(bb_TRDisp, 'String', sensors(4));
                                        weight = sum(sensors);
                                        set(bb_Totaldisp, 'String', weight);

                                        % plot the CoP
                                        size = weight/1.5;
                                        if size < 1
                                            size = 1;
                                        end                           
                                        pause(.01);

                                        subplot('position',[.1  .1  .8  .7]);
                                        plot(cog(1), -cog(2),'go', 'MarkerFaceColor','g', 'MarkerSize', size);
                                        %line(X1,Y1);
                                        %line(X,Y2);
                                        %line(X2,Y1);
                                        axis([-22.5 22.5 -13 13]);
                                        xlabel('X [cm]')
                                        ylabel('Y [cm]')
                                        set(gca, 'fontsize', 13); grid on;
                                        %serial
%                         target = lightNum;
%                         start_signal = '1';
%                         continue_signal = '0';
%                         green_signal = '1';
%                         yellow_signal = '2';
%                         red_signal = '3';
%                         motor_signal = '1';
                                          %%%send the green light signal
                                          if (first_loop_signal == 1) %check if should tell target to record time
                                              send = strcat(target,start_signal,green_signal,motor_signal);
                                              fprintf(s,'%s\n',send,'sync');  
                                             
                                          elseif (first_loop_signal ~= 1)
                                              send = strcat(target,continue_signal,green_signal,motor_signal);
                                              fprintf(s,'%s\n',send,'sync');
                                              
                                          end
                                          
                                        %fprintf(s,'%s\n',(1000*lightNum)+100); %Send the GREEN light number to the arduino
                                        cog = bb.wm.GetBalanceBoardCoGState(); % find the center of pressure
                                        CoPDataArr(datacount, :) = [cputime, cog(1), -cog(2)];
                                        datacount = datacount + 1;
%                                         sensors = (bb.wm.GetBalanceBoardSensorState()-sensor_avg_upright)./C; % find the force on each sensor, calibrated

                                if(togglePoint)
                                   p2(1) = cog(1);
                                   p2(2) = -cog(2);
                                else
                                   p1(1) = cog(1);
                                   p1(2) = -cog(2);
                                end
%                                 disp(p1);
%                                 disp(p2);
                                togglePoint = 1 - togglePoint; % toggle the point the current COP coordinates are written to.
                                COP_distance = sqrt((abs(p1(1)-p2(1)))^2 + (abs(p1(2)-p2(2)))^2); % calculate the distance between the current consequtive COP point
                                COP_length = COP_length + COP_distance; % update total COP length
                                              
                                            
                                        if toc(greenStart) > 1
                                            timeout = 1;
                                            if button == 1
                                                btnScs = 1;
                                                %score = score + 1;
                                                break
                                            end
                                            
                                        end
                  
                                   % end
                                  
                                    
                                                               

                                else % COP is outside the green area, inside yellow area
                             
                                    figure(f); %Reset the figure
                                    subplot('position',[.1  .1  .8  .7]);
                                    plot(cog(1), -cog(2),'yo', 'MarkerFaceColor','y', 'MarkerSize', size);
                                    axis([-22.5 22.5 -13 13]);
                                    line(X,Y);
                                    line(X1,Y1);
                                    line(X,Y2);
                                    line(X2,Y1);
                                    xlabel('X [cm]')
                                    ylabel('Y [cm]')
                                    set(gca, 'fontsize', 13); grid on;
                                    %serial
                                    if (first_loop_signal == 1) %check if should tell target to record time
                                              send = strcat(target,start_signal,yellow_signal,motor_signal);
                                              fprintf(s,'%s\n',send,'sync');
                                             
                                          elseif (first_loop_signal ~= 1)
                                              send = strcat(target,continue_signal,yellow_signal,motor_signal);
                                              fprintf(s,'%s\n',send,'sync');
                                              
                                    end
                                    
                                    %fprintf(s,'%f',(1000*lightNum)+ 1); %Send the YELLOW light number to the arduino
                                end %%end of yellow/green area loop
                                
                            

                            else % not enough weightshift, red area
                    
                                figure(f); %Reset the figure
                                subplot('position',[.1  .1  .8  .7]);
                                plot(cog(1), -cog(2),'ro', 'MarkerFaceColor','r', 'MarkerSize', size);
                                axis([-22.5 22.5 -13 13]);
                                xlabel('X [cm]')
                                ylabel('Y [cm]')
                                set(gca, 'fontsize', 13); grid on;
                                %SEND APPROPRIATE SERIAL STRING COMMAND
                                if (first_loop_signal == 1) %check if should tell target to record time
                                              send = strcat(target,start_signal,red_signal,motor_signal);
                                              fprintf(s,'%s\n',send,'sync');
                                              
                                          elseif (first_loop_signal ~= 1)
                                              send = strcat(target,continue_signal,red_signal,motor_signal);
                                              fprintf(s,'%s\n',send,'sync');
 
                                          end
                                
                                %fprintf(s,'%f',(1000*lightNum)+10); %Send the RED light number to the arduino

                            end  %%end of in yellow loop

                        end  % End of target comm loop
                        
%                         if (s.BytesAvailable > 0)
%                                pause(0.002);
%                              % Read until newline
%                              in = fgetl(s);
%                         end
                        %%%PROCESS SERIAL RESPONSE FROM TARGET
                                                      %Split parts by commas
                            parts = strsplit(in, ',');
                            disp(parts);
                            % Separate values
                             for idx=1:numel(parts)
                                part = parts{1, idx};
        
                                 % Sanity check
                                 %%split the input string by the value
                                 %%names
                                 %one set of 5 target values for each trial
                                    if length(part) > 1
                                       value_name = part(1);
                                       value = str2double(part(2:end));
                                       switch value_name
                                           case 't'
                                               target_num = value
                                           case 'f'
                                               if (value == '1') %%TARGET TIMEOUT, END ATTEMPT
                                                  
                                                   disp('Time ran out!');
                                                   
                                               elseif (value == '0')  %%%TARGET SUCCESS, END ATTEMPT
                                                   
                                                   disp('Target success!');
                                                   
                                               end 
                                           case 's'
                                               score(i) = value;
                                           case 'r'
                                               rem_time(i) = value;
                                           case 'x'
                                               x_distance(i) = value;
                                           case 'y'
                                               y_distance(i) = value;
                                           case 'a'
                                               acc_score(i) = value;                                             
                                           %the value variables should be
                                           %filled through the 5 targets
                                       end
                                 %do stuff with numbers
                                  disp(value_name)
                                  disp(value)
                                    end
                             end 
                             

                        
                    end   %%%END OF LOOPING THROUGH 5 TARGETS
                    
                    
                end
                figure(scorefig);
                %text(.1, .5, 'Good job! Try to beat this score!', 'fontsize', 26);
                set(msg,'String', 'Good job! Try to beat this score!');
                %fprintf(s,'%f',333); %Send the 333 to signalize THE END
                go=0;
                quitgui=1;
                clear ardButton;
                fclose(s);
            end

            %pause(.001) % this just makes debugging easier

        end

         %%%COP DATA
         clear ardButton;
         fclose(s);

%%%%end of "if bb.isConnected() > 0"  loop         
else %else, the BB is not connected  
error('BB is not connected. Try restarting MATLAB')
end



% clear ardButton;
fclose(s);
% bb.Disconnect();