function [C_predicted, Q, Q_cutoff, model_cvs, residuals] = apply_pcr(D, Vc, F, Qcrit)

%% Apply PCR to new data
%D = background subtracted data
%Convert data into principal components (project data (D) onto the retained PCs (Vc))
Dproj = Vc'*D;

%Use regression coefficients (F) to predict concentrations of each analyte (C_predicted)
C_predicted = F*Dproj;

%Figure out residuals of the principal component model 
residuals = D-(Vc*Dproj);
model_cvs = D-residuals;

%Calculate Q values (squared residuals)
Q = diag(residuals'*residuals)';




%Find Q values that exceed threshold. Use this to remove the time points at
%which these occur. Replace with NaN
Q_exclusion = find(Q>Qcrit);
Q_cutoff = C_predicted;
Q_cutoff(Q_exclusion) = NaN;