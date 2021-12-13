%
%--------------------------------------------------------------------------
% FILE NAME:
%   tip_picker
%
% DESCRIPTION
%   For empty images, use the backspace button. For values use left mouse
%   click to track rift boundary fault tips. The process runs twice, once
%   for each boundary fault
%
% INPUT:
%   - experimentname (str) name of profile line
%   - mod_length (double) length of analysed area
%   - mod_width (double) width of analysed area
%   - prop.dir (str) propagation direction (eastward or westward)
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
    warning('off','MATLAB:MKDIR:DirectoryExists'); 

% INPUT
% ======================================================================= %

    INPUT.experimentname = 'test';
    INPUT.mod_length     = 733;
    INPUT.mod_width      = 282;
    INPUT.prop_dir       = 'westward';
    
% SET PATHS
% ======================================================================= %    

    folder_now  = pwd;
    folder_exp  = [folder_now,'/',INPUT.experimentname];
    folder_data = [folder_exp,'/tip_data'];
    
    cd(folder_exp)
    mkdir tip_data

% LOAD DATA, CREATE BINARY AND LOOP THROUGH ALL SLICES
% ======================================================================= %

    files = dir('*.png');
    files(strncmp({files.name}, '.', 1)) = []; %remove files and dir starting with '.'
    nt    = length(files);
    
    for ifault = 1:2
        cd(folder_exp)
        
        xcoordvec = [];
        ycoordvec = [];
     
        for it = 1:1:nt
            I_png                =  imread(files(it).name);
            
            [INPUT.im_width,INPUT.im_length,~] =  size(I_png);
            
            cd(folder_now)
            clf
            figure(1)

            imshow(I_png)
            set(gcf,'Units','Normalized','Position',[.05 .05 .9 .9],'PaperPositionMode','auto')
            axis equal
            title(['Time step: ',num2str(it), ' Fault: ',num2str(ifault)])
            drawnow
            cd(folder_exp)
            
% TIP PICKING
% ======================================================================= %
            
            [xcoord,ycoord] = ginput(1);
            
            if isempty(xcoord)
                xcoord = 0;
                ycoord = 0;
            else
                % flipping coordinates to right hand system if needed
                switch INPUT.prop_dir
                    case 'westward'
                        xcoord     = INPUT.im_length-xcoord;
                    case 'eastwards'
                    otherwise
                        error('unknown propagation direction. Check spelling')
                end
            end
            
            xcoordvec = [xcoordvec;xcoord];
            ycoordvec = [ycoordvec;ycoord];
            
        end
        close(figure(1))
        
        xcoordvec = [0 xcoordvec'];
        ycoordvec = [0 ycoordvec'];
        
        % Save coordinates
            cd(folder_data)
            savevar        =   [folder_data '/COORDINATES_FAULT_' num2str(ifault) '.mat'];
            save(savevar, 'xcoordvec','ycoordvec');
    end
        % Save dimensions
            cd(folder_data)
            savevar        =   [folder_data '/DIMENSIONS'];
            save(savevar, 'INPUT');
