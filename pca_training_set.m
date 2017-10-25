function [Vc, F, Qcrit, K] = pca_training_set(A,C,pcs,alpha)

%pcs - number of principal components to use, supplied or left empty and calculated by F test

if nargin < 3; pcs = []; alpha = 0.05; end 
if nargin < 4; alpha = 0.05; end

%% Filename: principalComponentsRegression.m
%% Marios Panayi 05/05/2017
% Key references consulted:
% Kramer, R. (1998). Chemometric Techniques for Quantitative Analysis. CRC Press. 10.1201/9780203909805
% Keithley, R. B., Heien, M. L., & Wightman, R. M. (2009). Multivariate concentration determination using principal component regression with residual analysis. Trends in Analytical Chemistry?: TRAC, 28(9), 1127–1136. http://doi.org/10.1016/j.trac.2009.07.002
% Keithley, R. B., & Wightman, R. M. (2011). Assessing Principal Component Regression Prediction of Neurochemicals Detected with Fast-Scan Cyclic Voltammetry. ACS Chemical Neuroscience, 2(9), 514–525. http://doi.org/10.1021/cn200035u
% In conjunction with Keithley script (courtesy of Clio Korn): singleanalytecolorplot.m

%% Pre-analysis: Load training sets and data (background subtract and smooth)

%A = Input training set cv matrix (rows x cols -> points in scan x cvs)
%C = Input training set concentration matrix (rows x cols -> analytes x concentrations)


%% Step 1 run PCA on training set CVs
%Method being used = singular value decomposition (svd)
%Output: u = eigen vectors. Normalized values (i.e. sum of squared values = 1)
%Output: s = diagonal matrix of square root of eigen values i.e. square values to get eigen values (lambda)

[u,s,v]=svd(A);

%Calculate eigen values and associated variance
lambda = diag(s.^2);
lambda_variance = lambda/sum(lambda);

%Dimensions of training set to be used as variables later
num_scanpoints = size(A,1);
num_trainingsetCVs = size(A,2);

%% Step 2 Malinowski's F-test

%Figure out the cumulative variance associated withe each eigen value
lambda_cumulative_variance = zeros(num_trainingsetCVs,1);
lambda_cumulative_variance(1) = lambda_variance(1);
for i = 2:num_trainingsetCVs
    lambda_cumulative_variance(i) = lambda_cumulative_variance(i-1) + lambda_variance(i);
end

%Calculate Reduced Eigen Vectors (REV)
%This is part of Malinowski's F test
%REVs are just controlling each eigenvalue by its degrees of freedom, normalizing the eigenvectros so they can be compared to eachother
%REVs are the numerator in Malinowski's F-test
%norms - Calculate the normalising degrees of freedom for Malinoski's F-test
%lambda_error - Calculate the error in each eigenvalue for for Malinoski's F-test
%denominator - denominator for Malinoski's F-test

%pre-define variables
REV = zeros(num_trainingsetCVs,1);
norms = zeros(num_trainingsetCVs,1);


r = num_scanpoints;
c = num_trainingsetCVs;

for n = 1:num_trainingsetCVs
    norms(n) = (r-n+1)*(c-n+1);
    REV(n) = lambda(n)/(norms(n));
end

sum_lambda_error = zeros(num_trainingsetCVs,1);
sum_norms = zeros(num_trainingsetCVs,1);
denominator = zeros(num_trainingsetCVs,1);

for n = 1:num_trainingsetCVs
    sum_lambda_error(n) = sum(lambda(n+1:end));
    sum_norms(n) = sum(norms(n+1:end));
    denominator(n) = sum_lambda_error(n)/sum_norms(n);
end

%Malinowski's F
F_statistic = zeros(num_trainingsetCVs-1,1);
for n = 1:num_trainingsetCVs-1
    F_statistic(n) = REV(n)/denominator(n);
end

%Malinowski's Fcritical values with different v2 values
F_critical = zeros(num_trainingsetCVs-1,1);
alpha = .05;
for n = 1:num_trainingsetCVs-1
    F_critical(n) = finv(1-alpha,1,num_trainingsetCVs-n);
end

%Compare F values to respective F-criticals, determine how many PCs to retain based on removing 1 PC until it reaches significance.
siginficant_Ftest = find(F_statistic>F_critical);
if isempty(pcs) 
    num_retainedPCs = max(siginficant_Ftest);
else
    num_retainedPCs = pcs;
end

%% Extract number of PCs based on Malinowski's F-test Unless specified
%Vc = retained eigen vectors
Vc = u(:,1:num_retainedPCs);
%Aproj = projection of original data on the basis of the reatined PCs
%This reduces the data set down to the retained PC scores
Aproj = Vc'*A;

%% ILS regression on retained PCs -> i.e. Principal component regression (PCR)
%Using the retained PC scores, an Inverse Least Square(ILS) regression is conducted to predict the known concentrations (C) from the PCs
%This process provides us with the regression coefficients (F) which are technically run as separate ILS regressions for each analyte (usually DA & pH)
%The formula here is just the ILS solution to the equation C = F*Aproj,
%where F is the unknown. Solving for F gives -> F = C*Aproj'*inv(Aproj*Aproj');
%We can now predictunknown concentrations (C_unknown) from new data(A_unknown)->
%C_unknown = F*Vc'*A_unknown;or C_unknown = Fcal*A_unknown where Fcal = F*Vc'

F = C*Aproj'*inv(Aproj*Aproj');

%When applying the regression coefficients (i.e. multiplying by F) to new data, we must convert those data into the retained PC scores first i.e. multiply by Vc. 
%To save time in later calculations, Fcal (the calibration matrix) is created 
%C_unknown = Fcal*A_unknown where Fcal = F*Vc'
Fcal = F*Vc';

%If we had concentrations of an analyte and wanted to know what the model
%predicts the data should look like we would need to solve the equation:
%(1) A_unknown = K*C_unknown
%We know: 
%(2) C_unknown = Fcal*A_unknown
%Substitue (2) into (1) and we get: 
%(3)A_unknown = K*Fcal*A_unknown
%Solving this we get:
%(4) K = inv(Fcal)
%However, Fcal is not square so cannot be inverted. Instead we must use the
%pseudoinverse: K = pinv(Fcal)
K = pinv(Fcal);

%Plotting and inspecting K provides a qualitative control for the what the
%PCR considers each analyte to look like. It is the cyclic voltammetric
%representation of the regression vector for each analyte in the relevant
%multivariate calibration space. Doe sit look like DA/pH?

%Calculate a significance threshold for Q: Qalpha
%This involves determining the Zscore for a given significance threshold
%Zcrit calculated from a normal distribution with M=0 and SD=1 (i.e. standardised)
%Qcrit is then calulated from a combination of the significance threshold
%and the amount of variance not fit by the retained principal components (eigenvalues that were rejected)
%Doing this allows Qcrit to be a significance threshold specific to your
%training set, and allows you to determine model fit of Principal
%Componenents when applying them to new data


alpha = .05;
Z_crit = norminv(1-alpha,0,1);
theta = zeros(3,1);
for i = 1:3
   theta(i) = sum(lambda(num_retainedPCs+1:end).^i);
end
h0 = 1-((2*theta(1)*theta(3))/(3*(theta(2)^2)));
Qcrit = theta(1)*((((Z_crit* sqrt(2*theta(2)*(h0^2)))/theta(1)) + 1 +((theta(2)*h0*(h0-1))/(theta(1)^2)))^(1/h0));



