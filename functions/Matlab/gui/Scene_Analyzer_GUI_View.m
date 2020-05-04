% =========================================================================
%%%
%%% class Scene_Analyzer_GUI_View
%%%
%%% View class  used for Scene_Analyzer_GUI_View
%%% Defines methods for changing of GUI view as well as getting information
%%% from the GUI handles
%%%
%%% Author: Bhagyaraj Dharmana, Automotive Safety Technologies GmbH, for AUDI AG, bhagyaraj.dharmana@astech-auto.de
%%%

% =========================================================================
classdef Scene_Analyzer_GUI_View < handle
    
    properties
        cGUI;        % Matlab GUI
        cModel;      % Model class
        cController; % Controller class
    end
    
    properties (Access = private)
        sHandles;
    end
    
    methods
        
        function this = Scene_Analyzer_GUI_View(cController)
            this.cController = cController;
            this.cModel = cController.cModel;
            this.cGUI = Scene_Analyzer_GUI('cController', this.cController);
            this.sHandles = guidata(this.cGUI);
            set(this.sHandles.figure1,'HandleVisibility','on');
        end %Scene_Analyzer_GUI_View
        
        function sGuiHandles = GetGuiHandles(this)
            sGuiHandles = this.sHandles;
        end %GetGuiHandles
    end %methods
    
    
end %Scene_Analyzer_GUI_View