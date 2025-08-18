%% GHSI 2019 STEP 4


%% full RF model sa svim varijablama, bar chart i cuvanje u png formatu


Mdl = load('trenirani_random_forest_model.mat').Mdl;
load("nazivi_kolona.mat","nazivi_kolona");
input_vars = nazivi_kolona;

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

saveas (gcf,'importance_full_RF.png');

%% Partial Dependence Plots (PDPs) i Individual Conditional Expectation (ICE) plots

% Partial Dependence Plots (PDPs) predstavljaju grafike proseka uticaja varijabli na
% prediktovanu varijablu

% Individual Conditional Expectation (ICE) plots predstavljaju grafike svih
% uticaja pojedinacne varijable na prediktovanu varijablu na osnovu kojih
% se racuna prosek odnosno PDP

% trazenje top 3 prediktora iz full RF modela
[~, idx] = maxk(importance, 3);
topPredictors_full = input_vars(idx);
disp('Top 3 prediktora:');
disp(topPredictors_full);
% top 3 prediktora po vaznosti su: imunity_proxy_deaths, PC age i onset (ocekivano)
ocekivani_top_prediktori= input_vars([1,5,11]); 
% da bi se kasnije proverilo da li mogu sredjeni nazivi(bez _) ili
% automatski iz modela

% Kreiranje ICE plotova
figure

% ICE plot za prvi prediktor
ax1 = subplot(1, 3, 1); % definisanje osa da bi f-ja plotPartialDependance radila 
plotPartialDependence(Mdl, topPredictors_full{1}, ...
    'Conditional', 'centered');
title(['ICE plot za ', topPredictors_full{1}]);

% ICE plot za drugi prediktor
ax2 = subplot(1, 3, 2);
plotPartialDependence(Mdl, topPredictors_full{2}, ...
    'Conditional', 'centered');
title(['ICE plot za ', topPredictors_full{2}]);

% ICE plot za treci prediktor
ax3 = subplot(1, 3, 3);
plotPartialDependence(Mdl, topPredictors_full{3}, ...
    'Conditional', 'centered');
title(['ICE plot za ', topPredictors_full{3}]);

% Optional: Adjust the overall title and spacing
sgtitle('ICE Plots za top 3 prediktora (Full RF Model)');
saveas(gcf, 'ICE_plots_full_RF.png');

%% Reduced RF model

Mdl_reduced = load ('redukovani_random_forest_model.mat').Mdl_reduced;
reducedInputVars = input_vars(~ismember(input_vars,topPredictors_full)); % redukovani prediktori

% importance i bar chart

% racunanje importanca
importance_reduced = predictorImportance (Mdl_reduced); 

% top 3 prediktora RF_reduced modela
[~, idx] = maxk(importance, 3);
topPredictors_reduced = reducedInputVars(idx);
disp('Top 3 prediktora redukovanog RF modela:');
disp(topPredictors_reduced);

% bar chart
figure
bar(importance_reduced);
xlabel('Prediktori');
ylabel('Vaznost');
title('Vaznost varijabli u predikciji R_t redukovanog modela');

% provera da li moze pripremljena verzija bez '_' ili automatska iz modela 
if isequal (sort(ocekivani_top_prediktori),sort(topPredictors_full))
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

saveas (gcf,'importance_RF_reduced.png');

%% ICE plotovi za top 3 prediktora RF_reduced modela

% ICE plotovi
figure

% ICE plot za prvi prediktor
ax1 = subplot(1, 3, 1); % definisanje osa da bi f-ja plotPartialDependance radila 
plotPartialDependence(Mdl_reduced, topPredictors_reduced {1}, ...
    'Conditional', 'centered');
title(['ICE plot za ', topPredictors_reduced{1}]);

% ICE plot za drugi prediktor
ax2 = subplot(1, 3, 2);
plotPartialDependence(Mdl_reduced, topPredictors_reduced{2}, ...
    'Conditional', 'centered');
title(['ICE plot za ', topPredictors_reduced{2}]);

% ICE plot za treci prediktor
ax3 = subplot(1, 3, 3);
plotPartialDependence(Mdl_reduced, topPredictors_reduced{3}, ...
    'Conditional', 'centered');
title(['ICE plot za ', topPredictors_reduced{3}]);

% naslov
sgtitle('ICE Plots za top 3 prediktora (Reduced RF Model)');
saveas(gcf, 'ICE_plots_reduced_RF.png');


%% PDPs za principal_mobility_1 i principal_GHSI_1

% redukovana tabela koriscena za redukovani RF model

load("x_normalizovano_redukovano.mat","X_normalizovano_redukovano");

[PD, X1, X2] = partialDependence(Mdl_reduced, {'PC_Mobility_1', 'PC_GHSI_1'}, X_normalizovano_redukovano);

%% surface plot

% surface plot
figure;
surf(X1, X2, PD);
xlabel('PC_Mobility_1');
ylabel('PC_GHSI_1');
zlabel('Partial Dependence');
title('3D Partial Dependence Plot (Reduced RF)');
saveas(gcf, 'PDP_surface_reduced_RF.png');


%% africke drzave (heatmap)

br_africke_drzave = readtable ("african_row_numbers.csv");
indexi_drzava = table2array (br_africke_drzave); % numericki niz drzava
africke_drzave_imena = X_normalizovano_redukovano.Properties.RowNames(indexi_drzava);
disp('Afričke države zadate rednim brojevima:');
disp(africke_drzave_imena);

% podaci iz tabele sa PCs, za africke drzave
africke_drzave = X_normalizovano_redukovano(indexi_drzava,:);

% heatmap

figure;
imagesc(X1, X2, PD);
set(gca, 'YDir', 'normal'); % pravac y ose
colormap('jet');
colorbar;
xlabel('PC_Mobility_1');
ylabel('PC_GHSI_1');
title('Heatmap Partial Dependence (Reduced RF)');
saveas(gcf, 'PDP_heatmap_reduced_RF.png');

hold on

% scatter africkih drzava oznacenih kruzicima
scatter(africke_drzave.PC_Mobility_1, africke_drzave.PC_GHSI_1, 50, 'o', 'filled', ...
    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'r');

% labels
for i = 1:height(africke_drzave)
    x = africke_drzave.PC_Mobility_1(i);
    y = africke_drzave.PC_GHSI_1(i);
    ime_drzave = africke_drzave.Properties.RowNames{i};

    text(x + 0.1, y, ime_drzave, 'FontSize', 8, 'Interpreter', 'none');
end

% legenda
legend('African countries');

saveas(gcf, 'PDP_heatmap_african_countries.png');


