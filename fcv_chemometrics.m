function [model_cvs, c_predicted, q, q_crit, q_cutoff] = fcv_chemometrics(data, params, TTLs, ts)
% function fcv_chemometrics(data, cv_matrix, conc_matrix, pcs, alpha)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% fcv_chemometrics
%
% Applies chemometric principal component regression to fcv data
% see pca_training_set.m and apply_pcr for detailed help.
%
% inputs: data           - fcv data in matrix form (m×n) where m is samples of
%                          the applied waveform, n is the number of applied
%                          waveforms over time, for multiple trials use cell
%                          array of matrices
%
%         params.          data structure containing chemometric specific parameters
%           cv_matrix    - cv template
%           conc_matrix  - concentration matrix
%           pcs          - number of principal components to use, if empty 
%                          calculated by f-test 
%           alpha        - default 0.05
%           plotfigs     - if true(1) plot figures for each trial - default false(0)
%
% inputs (optional)
%           TTLs         - trial TTL data
%           ts           - trial ts (only required if plotfigs is true)
%
% outputs: model_cvs   - chemometric fcv data 
%          c_predicted - chemometric i vs t data
%          q           - model residuals i vs t
%          q_crit      - threshold value for model fit
%          q_cuttoff   - residuals with threshold (q_crit) exceeding values
%                        removed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1
    error('No data, please provide fcv');
end
if nargin < 2
    error('No params, please provide parameters structure');
end
if nargin < 3
    TTLs = [];
end
if nargin < 4
    ts = [];
end

%for each trial
for i = 1:length(data)
    
    [vc, f, q_crit, k] = pca_training_set(params.cv_matrix, params.conc_matrix, params.pcs, params.alpha);

    [c_predicted{i}, q{i}, q_cutoff{i}, model_cvs{i}, residuals{i}] = apply_pcr(data{i}, vc, f, q_crit);
    
    if params.plotfigs && ~isempty(ts)
        %plot colour plot
        figure
        subplot(2,3,1)
        plot_fcvdata(data{i},ts{i})    
        c = colorbar('eastoutside');
        ylabel(c,'Current(nA)')
        title('Raw FCV data')
        %plot chemometric colour plot
        subplot(2,3,2)
        plot_fcvdata(model_cvs{i},ts{i})    
        c = colorbar('eastoutside');
        ylabel(c,'Current(nA)')
        title('Chemometric FCV data')
        %plot I vs T
        subplot(2,3,3)
        plot(smooth(c_predicted{i}(1,:),5),'k')
        title('I vs T');xlabel('Time(s)');ylabel('Current (nA)')

        %plot TTLS
        subplot(2,3,6)
        if ~isempty(TTLs)
            plot_TTLs(TTLs{i}, ts{i})
        end
        title('TTLs');xlabel('Time(s)');ylabel('TTLs')

        %plot model fit
        subplot(2,3,4)    
        plot(q{i},'k')    
        hold on 
        plot(q_crit*ones(size(q{i},2)),'r')
        title('Residuals');xlabel('Time(s)');ylabel('Q value')

        %plot residuals
        subplot(2,3,5)
        plot_fcvdata(residuals{i},ts{i})
        c = colorbar('eastoutside');
        ylabel(c,'Current(nA)')
        title('Residuals')
    elseif params.plotfigs && isempty(ts)
        fprintf('Please provide timestamps in order to plot chemometric figures\n')
    end
end