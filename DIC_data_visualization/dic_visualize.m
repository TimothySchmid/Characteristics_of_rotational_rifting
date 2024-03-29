%
%--------------------------------------------------------------------------
% FILE NAME:
%   dic_visualize
%
% DESCRIPTION
%   load topographic profiles according to designated lines. Data is obtained
%   from DaVis lineplot extraction out of a high res digital elevation model
%   of the model's surface.
%
% REQUIRED FUNCTIONS
%   - fct_define_plot_var
%   - fct_disp_devs
%   - fct_vel_devs
%   - fct_vector_plot
%
% INPUT:
%   - experimentname (str) name of experiment
%   - disp_type (str) 'incremental' or 'cumulative'
%   - plot_val (str) chose from:
%       - 'Dx'
%       - 'Dy'
%       - 'Dz'
%       - 'D2d'
%       - 'D3d'
%
%       - 'Exx'
%       - 'Exy'
%       - 'Eyx'
%       - 'Eyy'
%       - 'Gavg'
%       - 'Div'
%       - 'I1'
%       - 'I2'
%       - 'Theta_P'
%       - 'Emin'
%       - 'Emax'
%       - 'Gmax'
%       
%       - 'U'
%       - 'V'
%       - 'W'
%       - 'V2d'
%       - 'V3d'
%
%       - 'exx'
%       - 'exy'
%       - 'eyx'
%       - 'eyy'
%       - 'omega'
%       - 'theta'
%       - 'ang_vel'
%       - 'i1'
%       - 'i2'
%       - 'theta_p'
%       - 'emin'
%       - 'emax'
%       - 'gmax'
%
%   - image_interval (double) image interval
%   - time_step (double) which time step
%   - save (str) 'yes' or 'no' for saving figures
%
% ASSUMPTIONS AND LIMITATIONS:
%   None
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
    
    INPUT.disp_type      = 'cumulative';
    INPUT.plot_val       = 'Dy';
    
    INPUT.image_interval = 60;
    INPUT.time_step      = 70;
    INPUT.save           = 'no';
    
% SET PATHS
% ======================================================================= %  

    folder_now = pwd;
    folder_exp = [pwd '/' INPUT.experimentname];
    folder_png = [pwd '/' INPUT.experimentname '/png'];
    
    switch INPUT.disp_type
        case 'incremental'
            data_name = ['incr_' INPUT.experimentname '.h5'];
        case'cumulative'
            data_name = ['cum_' INPUT.experimentname '.h5'];
        otherwise
            error('displacement type unclear. Please check spelling')
    end
    
% LOAD DATA FROM .h5 FILES
% ======================================================================= %
 
cd(folder_exp)

% Load coordinates and scaling values
    COORDS.dx   = h5read(data_name,'/dx');
    COORDS.dy   = h5read(data_name,'/dy');
    COORDS.dz   = COORDS.dx;     

    GRID.nx   = double(h5read(data_name,'/nx'));
    GRID.ny   = double(h5read(data_name,'/ny'));
    GRID.dt   = INPUT.time_step;

    x    = h5read(data_name,'/x');
    y    = h5read(data_name,'/y');
    
% Coordinates correction and grid
    x = x - mean(x)+180;
    y = y - mean(y);
    
    [X,Y]   = ndgrid(x,y);

    Dx = (h5read(data_name,'/vx'));
    Dy = (h5read(data_name,'/vy'));
    Dz = (h5read(data_name,'/vz'))*COORDS.dz;
       
    
 % FIX DISPLACEMENT MATRICES - FILL HOLES ETC.
 % ====================================================================== %
 
 % create mask row
    Dz(Dz==0) = NaN;
    mask_row  = ~isnan(Dz(round(size(Dz,1)/2),:));
    idx_start = find(mask_row,1,'first');
    idx_end   = find(mask_row,1,'last');
    
 % crop coordinates
    COORDS.x = x;
    COORDS.y = y(idx_start:idx_end);
    
   [COORDS.X,COORDS.Y]   = ndgrid(COORDS.x,COORDS.y);
    
 % crop displacements
    DISP.Dx = Dx(:,idx_start:idx_end);
    DISP.Dy = Dy(:,idx_start:idx_end);
    DISP.Dz = Dz(:,idx_start:idx_end);

    cd(folder_now)
    
    COORDS.X = COORDS.X + DISP.Dx;
    COORDS.Y = COORDS.Y + DISP.Dy;
    
% DISPLACEMENT AND DISPLACEMENT DERIVED VALUES
% ======================================================================= %

[DISP,DISP_DEVS] = fct_disp_devs(DISP,COORDS,GRID);

% VELOCITY AND VELOCITY DERIVED VALUES
% ======================================================================= %

[VEL,VEL_DEVS] = fct_vel_devs(DISP,COORDS,GRID,INPUT);
     
% ASSIGN PLOTTING VALUE
% ======================================================================= %

PLT = fct_define_plot_var(INPUT,DISP,DISP_DEVS,VEL,VEL_DEVS);
        
% PLOT FIGURE
% ======================================================================= %

    figure(1)
    clf
    set(gcf,'Units','normalized','Position',[.2 .4 .7 .45])
    colormap(parula(16))
    
% Pseudocolor ------------------------------------------------------------ 

       pcolor(COORDS.X,COORDS.Y,PLT.val)
       shading interp
       hold on
  
% Quiver -----------------------------------------------------------------

      nvec = 16;
      fct_vector_plot(nvec,COORDS,VEL)
      hold on

   % LineFrame -----------------------------------------------------------

      plot(COORDS.X(:,1),COORDS.Y(:,1),'k-','LineWidth',2)
      plot(COORDS.X(:,end),COORDS.Y(:,end),'k-','LineWidth',2)
      plot(COORDS.X(1,:),COORDS.Y(1,:),'k-','LineWidth',2)
      plot(COORDS.X(end,:),COORDS.Y(end,:),'k-','LineWidth',2)

   % Limits and colors ---------------------------------------------------
  
    axis equal
    
    rim = 20;

    xlim([floor(COORDS.X(1,1))   - rim, ceil(COORDS.X(end,1)) + rim])
    ylim([floor(COORDS.Y(1,end)) - rim, ceil(COORDS.Y(end,1)) + rim])

    xlabel('Length [mm]')
    ylabel('Width [mm]')
    title(['Minute: ', num2str(GRID.dt)])

    c = colorbar('Location','eastoutside');
    c.Label.String = PLT.lab;
    c.Label.FontSize = 12;
    caxis([-max(max(PLT.val)) max(max(PLT.val))])
    caxis([min(min(PLT.val)) -min(min(PLT.val))])
    drawnow
    
% SAVE FIGURE
% ======================================================================= %

switch INPUT.save
    case 'yes'
        cd(folder_exp)
        mkdir('png')
        cd(folder_png)
        print('-dpng','-r600','-noui',['Min_',...
            num2str(INPUT.time_step,'%4.4d') '.png'])
    case 'no'
    otherwise
        error('Unclear if saving is requested. Check spelling')
end
cd(folder_now)