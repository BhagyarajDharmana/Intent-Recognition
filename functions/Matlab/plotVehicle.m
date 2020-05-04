% =========================================================================
%%%
%%% function plotVehicle
%%%
%%% Plotting of the vehicle as bounding box at corresponding position with
%%% given orientation angle (yaw)
%%%
%%% Possible calls:
%%% plotVehicle() - plotting of the ego vehicle in green color in the point
%%% [0,0] with yaw angle equal to zero and predefined length and width 
%%%
%%% plotVehicle(faPos, fAngle) - plotting of the vehicle in the point faPos
%%% containing X- and Y-coordinate of the vehicle position with orientation
%%% equal to fAngle and predefined length and width
%%%
%%% plotVehicle(faPos, fAngle, strColor) - plotting of the vehicle in the 
%%% point faPos containing X- and Y-coordinate of the vehicle position with 
%%% orientation equal to fAngle and predefined length and width. Color of 
%%% the vehicle is specified with strColor
%%%
%%% plotVehicle(faPos, fAngle, strColor, strMountingPos) - plotting of the
%%% vehicle in the point faPos containing X- and Y-coordinate of the 
%%% vehicle position with orientation equal to fAngle and mounting position
%%% equal to strMountingPos. Color of the vehicle is specified with strColor. 
%%% 
%%% plotVehicle(faPos, fAngle, strColor, fLength, fWidth) - plotting of the
%%% vehicle in the point faPos containing X- and Y-coordinate of the 
%%% vehicle position with orientation equal to fAngle and length of fLength
%%% and width of fWidth. Color of the vehicle is specified with strColor. 
%%%
%%% Author: Victor Chernukhin, Automotive Safety Technologies GmbH, for AUDI AG, victor.chernukhin@astech-auto.de
%%%
%%%	$ProjectName$
%%% $PathRelative$
%%% $Date: 2018-01-08 09:23:44 +0100 (Mo, 08 Jan 2018) $
%%% $Revision: 2334 $
%%% $Author: fl71nd4 $
%%%
%%% (C) 2016 AUDI AG
%%%
% =========================================================================
function faVehicle_patch = plotVehicle(varargin)
% Plotting of the vehicle with triangle showing direction
fDefaultWidth = 1;
fDefaultLength = 2;
switch length(varargin)%nargin 
    case {0} %default parameter are being set
        faPos = [0,0];
        fAngle = 0;
        strColor = 'green';
        strMountingPos = 'MHA';
        fWidth = fDefaultWidth;
        fLength = fDefaultLength;        
    case 2 %pos and angle
        if length(varargin{1}) < 2
            error('plotVehicle: Position of the vehicle should be input in format [PosX, PosY]');
        end;
        faPos = varargin{1};       
        fAngle = varargin{2};
        fWidth = fDefaultWidth;
        fLength = fDefaultLength;
    case 3
        faPos = varargin{1};
        if length(varargin{1}) < 2
            error('plotVehicle: Position of the vehicle should be input in format [PosX, PosY]');
        end;
        fAngle = varargin{2};
        strColor = varargin{3};
        fWidth = fDefaultWidth;
        fLength = fDefaultLength;
    case 4
        faPos = varargin{1};
        if length(varargin{1}) < 2
            error('plotVehicle: Position of the vehicle should be input in format [PosX, PosY]');
        end;
        fAngle = varargin{2};
        strColor = varargin{3};
        strMountingPos = varargin{4};
        fWidth = fDefaultWidth;
        fLength = fDefaultLength;
    case 5
        faPos = varargin{1};
        if length(varargin{1}) < 2
            error('plotVehicle: Position of the vehicle should be input in format [PosX, PosY]');
        end;
        if length(varargin{5}) < 2
            error('plotVehicle: Velocity of the vehicle should be input in format [VelX, VelY]');
        end
        fAngle = varargin{2};
        strColor = varargin{3};
        strMountingPos = varargin{4};
        fWidth = fDefaultWidth;
        fLength = fDefaultLength;       
        faVelVecEnd = varargin{5}; % velocity vector
    case 9
        faPos = varargin{1};
%         if length(varargin{1}) < 2
%             error('plotVehicle: Position of the vehicle should be input in format [PosX, PosY]');
%         end;
%         if length(varargin{5}) < 2
%             error('plotVehicle: Velocity of the vehicle should be input in format [VelX, VelY]');
%         end
        fAngle = varargin{2};
        strColor = varargin{3};
        strMountingPos = varargin{4};
        fWidth = varargin{5};
        fLength = varargin{6};
        nMountingPoint = varargin{7};
        faVelVecEnd = varargin{8};
        faAcc = varargin{9};
        if nMountingPoint ~= MLBevoTrafoLib.REFPOINT_OBJECT_MIDDLE
            [faPos(1), faPos(2),...
            faTarget_LocalVxMBB, faTarget_LocalVyMBB,...
            faTarget_LocalAxMBB, faTarget_LocalAyMBB] = MLBevoTrafoLib.RefPointTrafo(nMountingPoint, ...
            MLBevoTrafoLib.REFPOINT_OBJECT_MIDDLE, ...
            faPos(1), faPos(2), ...
            faVelVecEnd(1), faVelVecEnd(2), ...
            faAcc(1), faAcc(2), ...
            fAngle, fWidth, fLength);
        end;
        % ToDo: update option for velocity vector plot
%         faVelVecEnd = varargin{5}; % velocity vector
    case 6
        faPos = varargin{1};
        if length(varargin{1}) < 2
            error('plotVehicle: Position of the vehicle should be input in format [PosX, PosY]');
        end;
%         if length(varargin{5}) < 2
%             error('plotVehicle: Velocity of the vehicle should be input in format [VelX, VelY]');
%         end
        fAngle = varargin{2};
        strColor = varargin{3};
        strMountingPos = varargin{4};
        fWidth = fDefaultWidth;
        fLength = fDefaultLength;       
        faVelVecEnd = varargin{5}; % velocity vector        
        faLever = varargin{6};
    case 7      
        faPos = varargin{1};
        if length(varargin{1}) < 2
            error('plotVehicle: Position of the vehicle should be input in format [PosX, PosY]');
        end;
        fAngle = varargin{2};
        strColor = varargin{3};
        strMountingPos = varargin{4};       
        faVelVecEnd = varargin{5}; % velocity vector
        fWidth = varargin{6}(1);
        fLength = varargin{6}(2);
%     case 8      
%         faPos = varargin{1};
%         if length(varargin{1}) < 2
%             error('plotVehicle: Position of the vehicle should be input in format [PosX, PosY]');
%         end;
%         fAngle = varargin{2};
%         strColor = varargin{3};
%         strMountingPos = varargin{4};       
%         faVelVecEnd = varargin{5}; % velocity vector
%         fWidth = varargin{6}(1);
%         fLength = varargin{6}(2);        
%         strLineType = varargin{7};
    otherwise
        error('plotVehicle: False number of input parameters. Please check function description for correct input');
end;

% Coordinates of the vehicle bounding box
if ~exist('strMountingPos', 'var')
    strMountingPos = 'MBB';
end;

if strcmp(strMountingPos, 'MBB')
    VehicleBoundingBox = @(x,y,l,w) [x-l/2, x+l/2, x+l/2, x-l/2; y+w/2, y+w/2, y-w/2, y-w/2];
    % Triangle for showing of the driving direction
    PatchDirTriangle = @(x, y, l, w) [x+l/2, x+l/2 - l/5, x+l/2 - l/5; y, y + w/2 - w/3, y - w/2 + w/3];
elseif strcmp(strMountingPos, 'MHA')       
    VehicleBoundingBox = @(x,y,l,w) [x-1.5, x+l/2+(l/2-1.5), x+l/2+(l/2-1.5), x-1.5; y+w/2, y+w/2, y-w/2, y-w/2];    
    % Triangle for showing of the driving direction
    PatchDirTriangle = @(x, y, l, w) [x+l/2+(l/2-1.5), x+l/2+(l/2-1.5) - l/5, x+l/2+(l/2-1.5) - l/5; y, y + w/2 - w/3, y - w/2 + w/3];
elseif strcmp(strMountingPos ,'Lever')    
    if exist('faLever', 'var')
        VehicleBoundingBox = @(x,y,l,w) [x-(l/2+faLever), x+(l/2-faLever), x+(l/2-faLever), x-(l/2+faLever); y+w/2, y+w/2, y-w/2, y-w/2];
    end;
    % Triangle for showing of the driving direction
    PatchDirTriangle = @(x, y, l, w) [x+(l/2-faLever), x+(l/2-faLever) - l/5, x+(l/2-faLever) - l/5; y, y + w/2 - w/3, y - w/2 + w/3];
end;


RotationMatrix = @(fAngle) ( [cos(fAngle) -sin(fAngle); sin(fAngle)  cos(fAngle)]);

faVehicle_patch = VehicleBoundingBox(0,0, fLength, fWidth);
faDir_patch = PatchDirTriangle(0,0, fLength, fWidth);
faVehicle_patch = repmat(faPos',1,size(faVehicle_patch,2)) + RotationMatrix(fAngle)*faVehicle_patch;
faDir_patch = bsxfun(@plus, faPos' , RotationMatrix(fAngle)*faDir_patch);
if ~exist('strColor', 'var')
     patch(faVehicle_patch(1,:), faVehicle_patch(2,:),'g');
else
     patch(faVehicle_patch(1,:),faVehicle_patch(2,:),strColor);
end;
%xlabel('posX, [m]');
%ylabel('posY, [m]');
%title('Visualising the trace data')
%hold on;
grid on;
if exist('strLineType', 'var')
     patch(faDir_patch(1,:), faDir_patch(2,:), 'b', 'LineStyle', strLineType);
else
     patch(faDir_patch(1,:), faDir_patch(2,:), 'b');
end;
% plot(faPos(1), faPos(2), 'Marker','o', 'Color','b');
% Plot velocity vector
if exist('faVelVecEnd', 'var')
    if ~isempty(faVelVecEnd)
        quiver(faPos(:,1), faPos(:,2), faVelVecEnd(:,1), faVelVecEnd(:,2))
    end;
end;
%axis([0 120 0 80]);
