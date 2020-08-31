function holo_image = f_SLM_gen_holo_multiplane_image(app, xyzp, SLMm, SLMn, weight, objectiveNA, objectiveRI, illuminationWavelength)
    if (~exist('xyzp', 'var') || isempty(xyzp))
        xyzp = [app.XdisplacementEditField.Value, app.YdisplacementEditField.Value, app.ZOffsetumEditField.Value*10e-6];
    end
    if (~exist('SLMm', 'var') || isempty(SLMm)); SLMm = app.SLMheightEditField.Value; end
    if (~exist('SLMn', 'var') || isempty(SLMn)); SLMn = app.SLMwidthEditField.Value; end
    if (~exist('weight', 'var') || isempty(weight)); weight = 1; end
    if (~exist('objectiveNA', 'var') || isempty(objectiveNA)); objectiveNA = app.ManualNAEditField.Value; end
    if (~exist('objectiveRI', 'var') || isempty(objectiveRI)); objectiveRI = app.ObjectiveRIEditField.Value; end
    if (~exist('illuminationWavelength', 'var') || isempty(illuminationWavelength)); illuminationWavelength = app.WavelengthnmEditField.Value*10e-9; end

    holo_image = f_SLM_PhaseHologram_YS(xyzp, SLMm,SLMn,weight,objectiveNA,objectiveRI,illuminationWavelength);
end