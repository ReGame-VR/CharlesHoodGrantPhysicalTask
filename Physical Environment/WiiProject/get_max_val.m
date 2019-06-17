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

    % creat sound player
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

    answer = questdlg('Would you like to open the data folder?', ...
        'View Data Folder?', 'Yes', 'No','Yes');
    switch answer,
        case 'Yes',
            winopen(pathname);
        case 'No',
            cal = 0;
    end


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
            cal = 1; % do this if the BB has not been calibrated
        else
            % do this if the BB has been calibrated
            answer = questdlg('Would you like to calibrate the Balance Board now?', ...
                'Calibrate?', 'Yes', 'No','Yes');
            switch answer,
                case 'Yes',
                    cal = 1;
                case 'No',
                    cal = 0;
            end
        end

        if cal == 1
            [C, quitgui, sensor_avg_upright ] = OneWeightCalibrate (bb); % calibrate
        end

    end

%% Create GUI figure for displaying BB data

if first == 0
    
    saveduration = 10; % How long do you want to save the data for by default?
    cycletime = 1/30 ; % how long should each iteration take? [seconds]
    Upper_time = 3600; % longest allowable trial [s]
    
    screensize = get(0,'ScreenSize');
    % figure('units','normalized','outerposition',[0 0 1 1])
    f= figure('Visible','off','color',[0.8 0.8 0.8],'units','normalized','outerposition',[0 0 1 1],'Name','Wii Balance Board GUI');
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

    % Display save duration time
    text(x4, 0.65, 'Save Duration [seconds]', 'fontsize', 13);

    % Text indicating save status
    savestatustext = text(x4, 0.2, 'Recording OFF', 'fontsize', 13);
    savenametext = text(x4, 0.15, 'xx', 'fontsize', 13, 'visible', 'off');

    text(x4, 0.4, 'Seconds Elapsed', 'fontsize', 13);
    save_duration_text = text(x6, 0.4, 'xx', 'fontsize', 13);
    
    % Text indicating range
    text(x5, y1, 'X Range [cm]', 'fontsize', 13);
    text(x5, y3, 'Y Range [cm]', 'fontsize', 13);
    text(x5, y2, 'X Mean [cm]', 'fontsize', 13);
    text(x5, y4, 'Y Mean [cm]', 'fontsize', 13);

    xrange = text(0.85, y1, 'xx', 'fontsize', 13);
    xmean = text(0.85, y2, 'xx', 'fontsize', 13);

    yrange = text(0.85, y3, 'xx', 'fontsize', 13);
    ymean = text(0.85, y4, 'xx', 'fontsize', 13);


    % Flags for controlling condition statements
    flag_saving = 0;
    flag_start = 0;
    flag_stop = 0;
    flag_timed = 0;

    % Initialize variables
    reset = 1;

    % creates gui buttons
    h_startbutton = start_button_toggle; % for starting to save data
    h_quitbutton = quit_button; % for quitting the program
    h_resultsbutton = results_button; % for pausing the program
    h_resetbutton = reset_button; % for resetting the program
    h_timerbutton = timer_button; % for deciding whether to use the automatic timer or the manual timer

    h_timerinput = timer_input(x6, 0.915, saveduration); % make the timer input box

    tStart = tic; % Start timer
    
end

%% Get BB Data
    if first == 0
        
        % initialize
        quitgui = 0; % 1 for quit

        while quitgui == 0

            % get rid of old data
            if reset == 1
                
                set(xrange, 'String', 'xx', 'Color', 'k' );
                set(xmean, 'String', 'xx', 'Color', 'k' );
                set(yrange, 'String', 'xx', 'Color', 'k' );
                set(ymean, 'String', 'xx', 'Color', 'k' );
                set(h_startbutton, 'Enable', 'on')
                set(h_resetbutton, 'Enable', 'off')
                set(save_duration_text, 'String', 'xx', 'color', 'k');
                set(savestatustext, 'Color', 'k', 'String', 'Recording OFF');
                set(savenametext,'visible','off');
                
                clear first
                if exist('first','file')
                    delete first.mat
                end

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

                if flag_timed == 1
                    set(h_timerinput,'Enable','on');
                end

                set(f,'Visible','on'); % show the figure
                tStart = tic; % reset stopwatch

            end

            while go == 1
                iter = iter + 1; %increment iteration counter

                data.bb.time(iter) = toc(tStart); % find the elapsed time now
                cog = bb.wm.GetBalanceBoardCoGState(); % find the center of pressure
                sensors = (bb.wm.GetBalanceBoardSensorState()-sensor_avg_upright)./C; % find the force on each sensor, calibrated

                % fix iteration duration
                t_el = toc(tStart);
                if t_el/iter < cycletime
                    pausetime = (cycletime*iter) - t_el;
                    pause (pausetime)
                end

                % save data when triggered
                if flag_saving % this condition only executes the following when we want to save data
                    if flag_start

                        flag_start = 0;
                        timestartsaving = toc(tStart);
                        iterstartsaving = iter;
                        set(savestatustext, 'Color', 'r', 'String', 'Recording ON');

                        starttype = get(h_startbutton, 'Style');

                        switch starttype
                            case 'pushbutton'
                                set(h_startbutton, 'Enable', 'off')
                                starttoggle = 0;
                            case 'togglebutton'
                                starttoggle = 1;
                        end
                        
                        trials = trials+1;

                        color = 'r';

                    end
                    currentsaveduration = toc(tStart) - timestartsaving;
                    set(save_duration_text, 'String', currentsaveduration);
                    datalog(iter,:) = [iter,data.bb.time(iter),cog(1),-cog(2),sensors(1),sensors(2),sensors(3),sensors(4)];
                end

                % change text on GUI
                set(x_copDisp, 'String', cog(1));
                set(y_copDisp, 'String', -cog(2));
                set(bb_BLDisp, 'String', sensors(1));
                set(bb_BRDisp, 'String', sensors(2));
                set(bb_TLDisp, 'String', sensors(3));
                set(bb_TRDisp, 'String', sensors(4));
                weight = sum(sensors);
                set(bb_Totaldisp, 'String', weight);

                data.bb.copx(iter) = cog(1);
                data.bb.copy(iter) = -cog(2);
                data.bb.BLforce(iter) = sensors(1);
                data.bb.BRforce(iter) = sensors(2);
                data.bb.TLforce(iter) = sensors(3);
                data.bb.TRforce(iter) = sensors(4);

                % plot the CoP
                size = weight/1.5;
                if size < 1
                    size = 1;
                end

                if weight > 5
                    subplot('position',[.1  .1  .8  .7]);
                    plot(cog(1), -cog(2),'ko', 'MarkerFaceColor',color, 'MarkerSize', size);
                    axis([-22.5 22.5 -13 13]);
                    xlabel('X [cm]')
                    ylabel('Y [cm]')
                    set(gca, 'fontsize', 13); grid on;
                else
                    subplot('position',[.1  .1  .8  .7]);
                    plot(100, 100,'wo', 'MarkerFaceColor','w', 'MarkerSize', size);
                    axis([-22.5 22.5 -13 13]);
                    xlabel('X [cm]')
                    ylabel('Y [cm]')
                    set(gca, 'fontsize', 13); grid on;
                end

                set(0,'CurrentFigure',f)

                % stop saving data
                if ((currentsaveduration >= saveduration) == 1) && (starttoggle == 0) && flag_saving == 1
                    flag_stop = 1;
                end
                
                % do this at the end of a recording period
                if (flag_stop == 1)
                    
                    flag_saving = 0;
                    flag_stop = 0;

                    flag_timed = get(h_timerbutton,'Value');
                    
                    if flag_timed == 1
                        set(h_timerinput,'Enable','on');
                    end

                    set(h_timerbutton,'Enable','on');
                    set(savestatustext, 'Color', 'k', 'String', 'Recording OFF');
                    set(h_startbutton, 'Enable', 'on');
                    
                    color = 'k';                    
                    fclose all;
                    play(player); % go "ding"

                    % after one trial is recorded, do this
                    if trials == 1
                        set(h_resultsbutton, 'Enable', 'on')
                        set(h_resetbutton, 'Enable', 'off')                        
                    end
                    
                end

            end

%% Plot the traces
            if quitgui == 0  && deletedfile == 0
                
                set(h_startbutton, 'Enable', 'off')
                
                % load the data
                frame = datalog(:,1);
                time = datalog(:,2);
                copx = datalog(:,3);
                copy = datalog(:,4);
                f1 = datalog(:,5);
                f2 = datalog(:,6);
                f3 = datalog(:,7);
                f4 = datalog(:,8);
                
                % find the indices corresponding to beginnings and ends
                start_indices = find( diff(frame) > 1 ) + 1;
                end_indices = find( diff(frame) < -1 );
                end_indices(length(end_indices)+1) = max(frame); % otherwise it will miss the last end

                subplot('position',[.1  .1  .8  .7]);

                weight = (f1+f2+f3+f4);
                thresh = weight > 5;

                % change visible text
                set(x_copDisp, 'String', 'xx' );
                set(y_copDisp, 'String', 'xx' );
                set(bb_BLDisp, 'String', 'xx' );
                set(bb_BRDisp, 'String', 'xx' );
                set(bb_TLDisp, 'String', 'xx' );
                set(bb_TRDisp, 'String', 'xx' );
                set(bb_Totaldisp, 'String', 'xx' );

                % pick colors
                cc=hsv(length(start_indices));
                
                trace_ind = 1;
                while trace_ind <= length(start_indices)
                    xy = find(thresh( start_indices(trace_ind)+...
                        1:end_indices(trace_ind)) )+start_indices(trace_ind) ;
                    currentsaveduration = time(end_indices(trace_ind)) ...
                        - time(start_indices(trace_ind));

                    % plot figures
                    plot(copx(xy),copy(xy),'color',cc(trace_ind,:))
                    hold on
                    plot(copx(xy),copy(xy),'o','color',cc(trace_ind,:))
                    axis([-22.5 22.5 -13 13]);
                    set(gca, 'fontsize', 13);
                    grid on;
                    xlabel('X [cm]')
                    ylabel('Y [cm]')

                    % change visible text to X and Y ranges & means
                    set(xrange, 'String', range(copx(xy)), 'color', cc(trace_ind,:) );
                    set(xmean, 'String', mean(copx(xy)), 'color', cc(trace_ind,:) );
                    set(yrange, 'String', range(copy(xy)), 'color', cc(trace_ind,:) );
                    set(ymean, 'String', mean(copy(xy)), 'color', cc(trace_ind,:) );
                    
                    % show the elapsed time for that trial
                    set(save_duration_text, 'String', currentsaveduration, 'color', cc(trace_ind,:));
                    
                    save trace_ind trace_ind                     
                    
                    ind = trace_ind;
                    if trace_ind == length(start_indices)
                        trace_ind = trace_ind + 1; % don't wait for the button to be pressed
                    else
                        % wait for the button to be pressed
                        while trace_ind == ind
                            load trace_ind;
                            pause(.01)
                        end
                    end
                    
                end

                % start fresh
                set(h_resetbutton, 'Enable', 'on')
                set(h_resultsbutton, 'String', 'SHOW RESULTS', 'enable', 'off')
                hold off

                title = 'BB_Trial_'; % not formatted in TeX
                date = datestr(now, 'yyyy-mm-dd-HH-MM-SS');
                
                % write the data for each trial to a separate file
                for ii = 1 : length(start_indices);
                    
                    % pick the filename
                    
                        filename = strcat(title,date,'-',num2str(ii),...
                        '_of_',num2str(length(start_indices)),'.txt');
                    
                    % create and open the text file for read and append
                    % access
                    fid = fopen(filename,'a+'); 

                    % write column titles
                    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', ...
                        'Cycle', 'Time [s]', 'CoP X [cm]', 'CoP Y [cm]', ...
                        'Back Left Force [kgf]', 'Back Right Force [kgf]'...
                        , 'Front Left Force [kgf]', 'Front Right Force [kgf]');

                    % write data
                    for jj = start_indices(ii):end_indices(ii);%1:end_indices(length(end_indices))
                        fprintf(fid,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n', datalog(jj,:));
                    end

                    % close the text file
                    fclose(fid);
                end

                % tell the user what the filename is
                stext1 = strcat({'Saved as '}, strcat(title,date,'-',...
                    '*','_of_',num2str(length(start_indices)),'.txt') );
                set(savestatustext, 'Color', 'b', 'String', stext1, 'interpreter', 'none');

                delete first.mat trace_ind.mat;
                deletedfile = 1;

            end

            pause(.1) % this just makes debugging easier

        end

    else
        first = 0;
        save first first
        run (thisone) 
        delete first.mat;
        % this runs the script a second time. this is really a hack, but it
        % solves a mysterious problem. for an unknown reason, the script
        % would not work right until the second time it was run.
        
    end

    close all

else
    error('BB is not connected. Try restarting MATLAB')
end


trace_ind = 1;
                while trace_ind <= length(start_indices)
                    xy = find(thresh( start_indices(trace_ind)+...
                        1:end_indices(trace_ind)) )+start_indices(trace_ind) ;
                    currentsaveduration = time(end_indices(trace_ind)) ...
                        - time(start_indices(trace_ind));
                    save trace_ind trace_ind                     
                    
                    ind = trace_ind;
                    if trace_ind == length(start_indices)
                        trace_ind = trace_ind + 1; % don't wait for the button to be pressed
                    end
                end
%arduinoCom = serial('COM3','BaudRate' 9600)
%fopen(arduinoCom);
left = min(copx(xy))
right = max(copx(xy))

%fprintf(arduinoCom, '%i%i', left, right);
%fscanf(arduinoCom);

% Send this information to arduino. Can it be saved and then have a new
% program run?  