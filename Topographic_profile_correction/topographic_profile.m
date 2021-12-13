%
%--------------------------------------------------------------------------
% FILE NAME:
%   topographic_profiles
%
% DESCRIPTION
%   load topographic profiles according to designated lines. Data is obtained
%   from DaVis lineplot extraction out of a high res digital elevation model
%   of the model's surface.
%
% REQUIRED FUNCTIONS
%   - inpaint_nans (John D'Erico)
% <a href="matlab:
% web('https://www.mathworks.com/matlabcentral/fileexchange/4551-inpaint_nans')"
% >inpaint_nans</a>.
%
% INPUT:
%   - profile (str) name of profile line
%   - save (str) 'yes' or 'no' for saving figures
%   - threshval (double) Threshold value for outlier detection (default = 1)
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
    
    INPUT.profile   = 'test_profile';
    INPUT.save      = 'yes';
    INPUT.threshval = 1;
  
% SET PATHS
% ======================================================================= %    
    
    folder_now  = pwd;
    folder_topo = [pwd '/' num2str(INPUT.profile)];
    
    save_name   = [INPUT.profile '_pngs'];
    folder_save = [folder_now '/' save_name];
    mkdir(save_name);
    
% GET .TXT FILES
% ======================================================================= %
       
    cd(folder_topo)
    files = dir('*.txt');
    files(strncmp({files.name}, '.', 1)) = []; %remove files and dir starting with '.'
    
    np = length(files);
   
for iRead = 38%1:1:np

    db = importdata(files(iRead).name);
    x  = db(:,1) - median(db(:,1));
    y  = db(:,3);

    % Keep uncorrected values
    xnc = x;
    ync = y;

    % Check for data holes and fix it
    dx = (x(1:end-1)+x(2:end))/2;
    dy = diff(y);

    % Assign uncorrected derivative to dync
    dxnc = dx;
    dync = dy;
    
    [idx, ~] = find(abs(dy)>INPUT.threshval);
    dy(idx)  = NaN;
    
    if isempty(idx)
      maxy_val = ceil(max(dync));  
    else
      maxy_val = ceil(max(dync(idx)));
    end
    miny_val = -maxy_val;
    
    cd(folder_now)
    dy = fct_inpaint_nans(dy,3);
    cd(folder_topo)

    y  = cumsum(dy) - mean(cumsum(dy));

    % Interpolate it back to get lost point back
    yv = interp1(dx,y,x,'linear','extrap');

    % Assign corrected values
    xc = x;
    yc = yv;

    % Get rid of loaded values
    clearvars x y db dy dx yv

    dxc = (xc(1:end-1)+xc(2:end))/2;
    dyc = diff(yc);

    % PLOTTING
    % =================================================================== %
    
    figure(1)
    clf
    set(gcf,'Units','normalized','Position',[.1 .1 .7 .7])
    warning('off','MATLAB:legend:IgnoringExtraEntries'); 

subplot(2,2,1)
    l1 = xline(0,'-.','Color',[.5 .5 .5]);
    hold on
    l2 = yline(0,'-.','Color',[.5 .5 .5]);
    l1.Annotation.LegendInformation.IconDisplayStyle = 'off';
    l2.Annotation.LegendInformation.IconDisplayStyle = 'off';

    plot(xnc,smoothdata(ync,'gaussian',5),'-.','LineWidth',2);

    title(['uncorrected ', strrep(INPUT.profile,'_',' ') ' at time: ' num2str(iRead-1) ' min'])
    xlabel('Width (mm)')
    ylabel('Height (mm)')
    legend('uncorrected')

    hAx=gca;
    hAx.LineWidth=2;
    hAx.FontSize = 10;

    axis square
    axis([-120 120 -30 30])
    xticks([-120 -90 -60 -30 0 30 60 90 120])
    yticks([-20 -10 0 10 20])

    box on
    set(gca, 'Layer', 'Top')

subplot(2,2,2)
    l1 = xline(0,'-.','Color',[.5 .5 .5]);
    hold on
    l2 = yline(0,'-.','Color',[.5 .5 .5]);
    l1.Annotation.LegendInformation.IconDisplayStyle = 'off';
    l2.Annotation.LegendInformation.IconDisplayStyle = 'off';

    plot(xc,smoothdata(yc,'gaussian',5),'-.','LineWidth',2);

    title(['corrected ', strrep(INPUT.profile,'_',' ') ' at time: ' num2str(iRead-1) ' min'])
    xlabel('Width (mm)')
    ylabel('Height (mm)')
    legend('corrected')

    hAx=gca;
    hAx.LineWidth=2;
    hAx.FontSize = 10;

    axis square
    axis([-120 120 -30 30])
    xticks([-120 -90 -60 -30 0 30 60 90 120])
    yticks([-20 -10 0 10 20])

    box on
    set(gca, 'Layer', 'Top')
    
subplot(2,2,3)
    
    l1 = xline(0,'-.','Color',[.5 .5 .5]);
    hold on
    l2 = yline(0,'-.','Color',[.5 .5 .5]);
    l1.Annotation.LegendInformation.IconDisplayStyle = 'off';
    l2.Annotation.LegendInformation.IconDisplayStyle = 'off';

    plot(dxnc,smoothdata(dync,'gaussian',1),'-.','LineWidth',2);
    plot(dxnc(idx),dync(idx),'go')
    
    title(['uncorrected derivative at time: ' num2str(iRead-1) ' min'])
    xlabel('Width (mm)')
    ylabel('Height (mm)')
    legend('uncorrected','outliers','Location','SouthWest')
    
    hAx=gca;
    hAx.LineWidth=2;
    hAx.FontSize = 10;

    axis square
    axis([-30 30 miny_val maxy_val])
    xticks([-30 -15 0 15 30])
    yticks(miny_val:1:maxy_val)

    box on
    set(gca, 'Layer', 'Top')
    
subplot(2,2,4)
    
    l1 = xline(0,'-.','Color',[.5 .5 .5]);
    hold on
    l2 = yline(0,'-.','Color',[.5 .5 .5]);
    l1.Annotation.LegendInformation.IconDisplayStyle = 'off';
    l2.Annotation.LegendInformation.IconDisplayStyle = 'off';

    plot(dxc,smoothdata(dyc,'gaussian',1),'-.','LineWidth',2);
    
    title(['corrected derivative at time: ' num2str(iRead-1) ' min'])
    xlabel('Width (mm)')
    ylabel('Height (mm)')
    legend('corrected','Location','SouthWest')

    hAx=gca;
    hAx.LineWidth=2;
    hAx.FontSize = 10;

    axis square
    axis([-30 30 miny_val maxy_val])
    xticks([-30 -15 0 15 30])
    yticks(miny_val:1:maxy_val)

    box on
    set(gca, 'Layer', 'Top')
    drawnow
        
    % SAVING PROFILES
    % =================================================================== %
    switch INPUT.save
        case 'yes'
            cd(folder_save)
            print('-dpng','-r300','-noui',['Topo_profile_',INPUT.profile,'_',...
                num2str(iRead-1,'%4.4d') '.png'])
            cd(folder_topo)
        case 'no'
        otherwise
            error('unclear if saving is requested. Check spelling')
    end

end
cd(folder_now)
