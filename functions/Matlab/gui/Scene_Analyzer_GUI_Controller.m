% =========================================================================
%%%
%%% class Scene_Analyzer_GUI_Controller
%%%
%%% Controller class  used for Scene_Analyzer_GUI
%%% Defines methods for accepting of inputs and converting it to commands
%%% for the model or view
%%%
%%% Author: Bhagyraj Dharmana, Automotive Safety Technologies GmbH, for AUDI AG, bhagyaraj.dharmana@astech-auto.de

% =========================================================================
classdef Scene_Analyzer_GUI_Controller < handle
    
    properties
        cModel; % Model class
        cView;  % View class
        sGuiHandles; % Handles to the Gui elements
    end %properties
    
    methods
        function this = Scene_Analyzer_GUI_Controller(cModel)
            this.cModel = cModel;
            this.cView = Scene_Analyzer_GUI_View(this);
            this.sGuiHandles = this.GetGuiHandles;
        end %cCsvSignalView_Controller
        
        function sHandles = GetGuiHandles(this)
            % Get handles to the GUI elements
            sHandles = this.cView.GetGuiHandles();
        end %GetGuiHandles
        
        function OpenTraceFolder(this)
            this.cModel.OpenFolder(this.sGuiHandles);
        end % OpenTraceFolder
        
        function RunEval(this)
            this.cModel.StartEvaluation(this.sGuiHandles);
        end % RunEval
        
        function plotCurves(this)
            this.cModel.plotIdSpecificData(this.sGuiHandles);
        end%plotCurves
    end
    
    methods (Static)
    end %Static
    
end %Scene_Analyzer_GUI_Controller