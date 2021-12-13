%
%--------------------------------------------------------------------------
% FILE NAME:
%   tip_picker_visualize
%
% DESCRIPTION
%   Plot rift tip positions of rift boundary faults over time and save it
%   if requested
%
% INPUT:
%   - experimentname (str) name of profile line
%   - save (str) save figures ('yes')or not ('no')
%
% FURTHER INFORMATION:
%
%  For more information, see <a href="matlab:
%  web('https://doi.org/10.1016/j.tecto.2021.229174')
%  ">Schmid et al., 2021</a>.
%
%  For more information, see <a href="matlab:
%  web('https://github.com/TimothySchmid/Characteristics_of_rotational_rifting.git')
%  ">Git hub repository</a>.
%
%  Latest DaVis readimx version for MacOS and Windows: <a href="matlab:
%  web('https://www.lavision.de/en/downloads/software/matlab_add_ons.php')
%  ">DaVis readimx</a>.
%--------------------------------------------------------------------------

% Author: Timothy Schmid, MSc., geology
% Institute of Geological Sciences, University of Bern
% Baltzerstrasse 1, Office 207
% 3012 Bern, CH
% email address: timothy.schmid@geo.unibe.ch
% November 2021; Last revision: 10/12/2021 
% Successfully tested on a Mac 64 bit using macOS Mojave
% (Vers. 10.14.6) and MATLABR2020b


% GENERAL STUFF
% ======================================================================= %

    clear            % clear the current Workspace
    close all        % close all figure windows
    clc              % clear the Command Window
    format long      % long format 
    
% INPUT
% ======================================================================= %

    INPUT.experimentname = 'test';
    INPUT.save           = 'yes';
    
% SET PATHS
% ======================================================================= %    

    folder_now  = pwd;
    folder_exp  = [folder_now,'/',INPUT.experimentname];
    folder_data = [folder_exp,'/tip_data'];
    
    cd(folder_data)

% LOAD DATA FOR BOUNDARY FAULTS
% ======================================================================= %
    
    subst       = INPUT.save;
    loadvar     = 'DIMENSIONS';
    load(loadvar);
    INPUT.save  = subst;
    
    loadvar     =  'COORDINATES_FAULT_1.mat';
    load(loadvar);

    x(1,:) = xcoordvec;    clear xcoordvec
    y(1,:) = ycoordvec;    clear ycoordvec

    loadvar     = 'COORDINATES_FAULT_2.mat';
    load(loadvar);

    x(2,:) = xcoordvec;    clear xcoordvec
    y(2,:) = ycoordvec;    clear ycoordvec

% RECREATE PHYSICAL COORDINATES AND NORMALISING FACTOR
% ======================================================================= %

    scaling  = (INPUT.mod_length/INPUT.im_length + INPUT.mod_width/INPUT.im_width) / 2;
    x        = x*scaling;
    x_max    = max(max(x));
    x        = smoothdata(x,2,'gaussian',5);
    
    time_vec = 0:size(x,2)-1;
    t_max    = max(time_vec);

% GROWTH
% ======================================================================= %

    dx_dt(1,:) = diff(x(1,:))./diff(time_vec);
    dx_dt(2,:) = diff(x(2,:))./diff(time_vec);
    dx_max     = max(max(dx_dt));
    
    dt         = (time_vec(1:end-1)+time_vec(2:end))./2;
    dt_max     = max(dt);

% GROWTH RATE
% ======================================================================= %

    dx2_dt2(1,:) = diff(dx_dt(1,:))./diff(dt);
    dx2_dt2(2,:) = diff(dx_dt(2,:))./diff(dt);
    dx2_max      = max(max(dx2_dt2));
    
    dt2          = (dt(1:end-1)+dt(2:end))./2;
    dt2_max      = max(dt2);

% PREPARE SAVING
% ======================================================================= %

switch INPUT.save
    case 'yes'
        images = [folder_exp '/plots'];
        if exist(images,'dir')
            disp('Folder exists... adding new pictures to it.')
        else
            mkdir (images)
        end
    case 'no'
    otherwise
        error('Unclear if saving is requested')
end

% PLOTTING
% ======================================================================= %

    hrlines = 60.*[1/t_max 2/t_max 3/t_max 4/t_max];
    
    % position over time
    figure(1)
    plot([hrlines;hrlines],[zeros(1,4);ones(1,4)],'-k','HandleVisibility','off')
    hold on
    plot(time_vec/t_max,x(1,:)/x_max,'-','LineWidth',2)
    plot(time_vec/t_max,x(2,:)/x_max,'-','LineWidth',2)

    hAx=gca;
    hAx.LineWidth=1.5;
    hAx.FontSize = 16;
    title(strrep(INPUT.experimentname,'_',' '))
    legend('Boundary fault 1','Boundary fault 2','location','southeast')
    xlabel('Normalised time','FontSize',20)
    ylabel('Normalised distance','FontSize',20)
    axis([0 1 0 1])
    axis square
    set(gca, 'Layer', 'Top')

    switch INPUT.save
        case 'yes'
            saveas(gcf,[images '/tiplocation'],'epsc')
            print(gcf,'-dpng','-r300','-noui',[images '/tiplocation.png'])
        case 'no'
        otherwise
            error('Unclear if saving is requested')
    end
    
    % growth rate over time
    figure(2)
    plot([hrlines;hrlines],[zeros(1,4);ones(1,4)],'-k','HandleVisibility','off')
    hold on
    plot(dt/dt_max,dx_dt(1,:)/dx_max,'-','LineWidth',2)
    plot(dt/dt_max,dx_dt(2,:)/dx_max,'-','LineWidth',2)

    hAx=gca;
    hAx.LineWidth=1.5;
    hAx.FontSize = 16;
    title(strrep(INPUT.experimentname,'_',' '))
    legend('Boundary fault 1','Boundary fault 2')
    xlabel('Normalised time','FontSize',20)
    ylabel('Normalised growth rate','FontSize',20)
    axis([0 1 0 1])
    axis square
    set(gca, 'Layer', 'Top')

    switch INPUT.save
        case 'yes'
            saveas(gcf,[images '/growth_rate'],'epsc')
            print(gcf,'-dpng','-r300','-noui',[images '/growth_rate.png'])
        case 'no'
        otherwise
            error('Unclear if saving is requested')
    end
    
cd(folder_now)