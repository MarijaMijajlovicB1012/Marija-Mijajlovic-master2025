%% GHSI 2019 STEP 3


%% ucitavanje tabele sa PCs, definisanje inputa i outputa

load("tabela_sa_PCs.mat","tabela_sa_PCs"); % ucitavanje samo tabele, ne svih koriscenih varijabli
load("nazivi_kolona.mat","nazivi_kolona");
load("R_mean_vector.mat","R_mean_vector");

response_idx = find(strcmp(nazivi_kolona,'R_mean')); % trazenje R_mean kolone da bi se izbacila
input_vars = nazivi_kolona; % nazivi prediktora
input_vars(response_idx)= []; % brisanje R_mean kolone koja je response (output)
X= tabela_sa_PCs(:,input_vars); % input
R_t = R_mean_vector; % output

%% normalizacija

X_normalizovano = normalize (X);
R_t = normalize(R_t);

%% kreiranje strukture

% sadrzi podesavanja optimizacije hiperparametara
MojaStruktura = struct();
MojaStruktura.UseParallel = true; % potreban Parallel Computing Toolbox
MojaStruktura.Optimizer = 'bayesopt';   % Bayesian Optimization
MojaStruktura.AcquisitionFunction = 'expected-improvement-per-second-plus'; % specifikacija Bayesove optimizacije
MojaStruktura.Repartition = 1; % podela prilikom cross validation-a (1 je default, podela podataka je random)
MojaStruktura.ShowPlots = false; % prikazivanje plota za pracenje progresa, false da se ne bi usporavao program
MojaStruktura.Verbose = 1; % prikazivanje osnovnog progresa u comman window-u (1/true; 0/false)
MojaStruktura.MaxObjectiveEvaluations = 500; % broj pokusaja (iteracija) optimizacije da bi se naslo najbolje resenje

%% treniranje random foresta

% tajmer
tic;

Mdl = fitrensemble(X_normalizovano, R_t, ...
    'Method', 'Bag', ... % metod random foresta, bagging (bootstrap aggregating), vise decision trees na random setovima podataka
    'OptimizeHyperparameters', {'MinLeafSize', 'NumLearningCycles'}, ... % optimizacija pojedinacnog stabla i broja ciklusa ucenja (broja stabala)
    'HyperparameterOptimizationOptions', MojaStruktura, ...
    'PredictorNames', X_normalizovano.Properties.VariableNames, ... % imena kolona input-a 
    'ResponseName', 'R_t'); % ime output-a (u tabeli je R_mean, ali ovo je varijabla za treniranje)

% zaustavljanje tajmera
vreme_treniranja = toc;
vreme_treniranja = vreme_treniranja/60;
fprintf('Treniranje modela trajalo je %.2f minuta.\n', vreme_treniranja);

% cuvanje modela 
save('trenirani_random_forest_model.mat', 'Mdl');


%% vaznost varijabli u predvidjanju R_t i bar chart

% racunanje vaznosti
importance = predictorImportance (Mdl); 

% bar chart
figure
bar(importance);
xlabel('Prediktori');
ylabel('Vaznost');
title('Vaznost varijabli u predikciji R_t');
nazivi_prediktora = {
    'immunity proxy'; 'PC vaccine'; 'stringency'; 'pop. density';...
    'PC age'; 'cardiovasc'; 'diabetes'; 'PC mobility 1'; 'PC mobility 2'; 'PC mobility 3';...
    'onset'; 'PC GHSI 1'; 'PC GHSI 2'; 'PC GHSI 3'
    };

xticklabels (nazivi_prediktora);
xtickangle (45) % nazivi pod uglom od 45 stepeni
grid on;


%% trazenje top 3 prediktora,redukovani model (bez top 3 prediktora)

% top 3 prediktora
[~, idx] = maxk(importance, 3);
topPredictors = input_vars(idx);
disp('Top 3 prediktora:');
disp(topPredictors);
% top 3 prediktora po vaznosti su: imunity_proxy_deaths, PC age i onset (ocekivano)
ocekivani_top_prediktori= input_vars([1,5,11]); 
% da bi se kasnije proverilo da li mogu sredjeni nazivi(bez _) ili
% automatski iz modela

%% redukovani model (bez top 3 prediktora)

% uklanjanje top 3 prediktora iz naziva prediktora
reducedInputVars = input_vars(~ismember(input_vars,topPredictors)); % redukovani prediktori
% Uklanjanje top 3 prediktora iz podataka
X_normalizovano_redukovano = X_normalizovano(:, reducedInputVars);

% tajmer
tic;

% Redukovani model bez top 3 prediktora
Mdl_reduced = fitrensemble(X_normalizovano_redukovano (:, reducedInputVars), R_t, ...
    'Method', 'Bag', ...
    'OptimizeHyperparameters', {'MinLeafSize', 'NumLearningCycles'}, ...
    'HyperparameterOptimizationOptions', MojaStruktura, ...
    'PredictorNames', reducedInputVars, ...
    'ResponseName', 'R_t');

vreme_treniranja_redukovani = toc;
vreme_treniranja_redukovani = vreme_treniranja_redukovani/60;
fprintf('Treniranje redukovanog modela trajalo je %.2f minuta.\n', vreme_treniranja_redukovani);

% cuvanje modela 
save('redukovani_random_forest_model.mat', 'Mdl_reduced');



%% importance i bar chart

% racunanje vaznosti
importance_reduced = predictorImportance (Mdl_reduced); 

% bar chart
figure
bar(importance_reduced);
xlabel('Prediktori');
ylabel('Vaznost');
title('Vaznost varijabli u predikciji R_t redukovanog modela');

% provera da li moze pripremljena verzija bez '_' ili automatska iz modela 
if isequal (sort(ocekivani_top_prediktori),sort(topPredictors))
    nazivi_prediktora_reduced = {               % bez supscripta (_) u nazivu
     'PC vaccine'; 'stringency'; 'pop. density';...
     'cardiovasc'; 'diabetes'; 'PC mobility 1'; 'PC mobility 2'; 'PC mobility 3';...
     'PC GHSI 1'; 'PC GHSI 2'; 'PC GHSI 3'
    };
else 
    nazivi_prediktora_reduced = reducedInputVars; % automatski ako nisu ocekivana top 3 prediktora
end
    
    xticklabels (nazivi_prediktora_reduced);
xtickangle (45) % nazivi pod uglom od 45 stepeni
grid on;



