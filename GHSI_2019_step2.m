%% GHSI 2019 STEP 2


%% pravljenje posebnih matrica za PCA

load omicron_i_GHSI_tabela

age_related = omicron_i_GHSI_tabela (:,{'median_age','age_65_older'});
vaccine_related = omicron_i_GHSI_tabela (:,{'fully_vaccinated','boosters'});
GHSI_related = omicron_i_GHSI_tabela (:,{'GHSI Overall','GHSI Prevent','GHSI Detect'...
                                    'GHSI Respond','GHSI Health','GHSI Norms','GHSI Risk','HDI'});
mobility_related = omicron_i_GHSI_tabela (:, {'mobility_retail','mobility_grocery'...
                                          'mobility_parks','mobility_transit','mobility_workplace'...
                                            'mobility_residential'});

%% standardizacija matrica za PCA

age_related_standardzovano = (age_related - mean(age_related)) ./ std(age_related);
vaccine_related_standardizovano = (vaccine_related - mean(vaccine_related)) ./ std(vaccine_related);
GHSI_related_standardizovano = (GHSI_related- mean(GHSI_related)) ./ std(GHSI_related);
mobility_related_standardzovano = (mobility_related - mean(mobility_related)) ./ std(mobility_related);

%% PCA

% obavezno '~' , da bi se preskocilo racunanje tsquared
[coeff_age_related, score_age_related, latent_age_related, ~,explained_age_related] = pca(age_related_standardzovano{:,:});
[coeff_vaccine_related, score_vaccine_related, latent_vaccine_related, ~,explained_vaccine_related] = pca(vaccine_related_standardizovano{:,:});
[coeff_GHSI_related, score_GHSI_related, latent_GHSI_related, ~,explained_GHSI_related] = pca(GHSI_related_standardizovano{:,:});
[coeff_mobility_related, score_mobility_related, latent_mobility_related, ~,explained_mobility_related] = pca(mobility_related_standardzovano{:,:});

principle_age_1 = score_age_related (:,1);
principle_vaccine_1 = score_vaccine_related(:,1);
principle_GHSI_1 = score_GHSI_related(:,1);
principle_GHSI_2 = score_GHSI_related (:,2);
principle_GHSI_3 = score_GHSI_related (:,3);
principle_mobility_1 = score_mobility_related(:,1);
principle_mobility_2 = score_mobility_related(:,2);
principle_mobility_3 = score_mobility_related(:,3);

%% grupisanje PCs, originala i R_mean

% age
age_grupisano = table (omicron_i_GHSI_tabela.median_age, omicron_i_GHSI_tabela.age_65_older, ...
                        principle_age_1, ...
                        omicron_i_GHSI_tabela.R_mean, ...
                        'VariableNames', {'Median_Age', 'Age_65_older', 'PrincipleAge1', 'R_mean'});
disp ('Grupisana age-related tabela: ');
disp(head(age_grupisano));

% vaccine
vaccine_grupisano = table (omicron_i_GHSI_tabela.fully_vaccinated, omicron_i_GHSI_tabela.boosters,...
                            principle_vaccine_1,...
                            omicron_i_GHSI_tabela.R_mean,...
                            'VariableNames',{'Fully vaccinated', 'Boosters', 'Principle_vaccine_1', 'R_mean'});
disp ('Grupisana vaccine-related tabela: ');
disp(head(vaccine_grupisano));

% GHSI
ghsi_var_names = {'GHSI Overall', 'GHSI Prevent', 'GHSI Detect', 'GHSI Respond', ...
                  'GHSI Health', 'GHSI Norms', 'GHSI Risk', 'HDI'};
ghsi_grupisano = table(omicron_i_GHSI_tabela.("GHSI Overall"), ...
                       omicron_i_GHSI_tabela.('GHSI Prevent'), ...
                       omicron_i_GHSI_tabela.('GHSI Detect'), ...
                       omicron_i_GHSI_tabela.('GHSI Respond'), ...
                       omicron_i_GHSI_tabela.('GHSI Health'), ...
                       omicron_i_GHSI_tabela.('GHSI Norms'), ...
                       omicron_i_GHSI_tabela.('GHSI Risk'), ...
                       omicron_i_GHSI_tabela.HDI, ...
                       principle_GHSI_1, principle_GHSI_2, principle_GHSI_3, ...
                       omicron_i_GHSI_tabela.R_mean, ...
                       'VariableNames', [ghsi_var_names, 'Principle_GHSI_1', 'Principle_GHSI_2', 'Principle_GHSI_3', 'R_mean']);
disp ('Grupisana GHSI-related tabela: ');
disp(head(ghsi_grupisano));

% mobility
mobility_grupisano = table (omicron_i_GHSI_tabela.mobility_retail, omicron_i_GHSI_tabela.mobility_grocery, ...
                            omicron_i_GHSI_tabela.mobility_parks, ...
                            principle_mobility_1, principle_mobility_2, principle_mobility_3, ...
                            omicron_i_GHSI_tabela.R_mean, ...
                            'VariableNames', {'Mobility_retail', 'Mobility_grocery', 'Mobility_parks',...
                            'Principle_mobility_1', 'Principle_mobility_2', 'Principle_mobility_3', 'R_mean'});
disp ('Grupisana mobility-related tabela: ');
disp(head(mobility_grupisano));

%% koeficijenti korelacije, tabele keoficijenata

[coef_age_grupisano] = corrcoef(age_grupisano.Variables); % Variables da bi se koristila numericka matrica
age_var_names = age_grupisano.Properties.VariableNames;
coef_table_age = array2table(coef_age_grupisano, 'RowNames', age_var_names, 'VariableNames', age_var_names);
disp('Tabela koeficijenata korelacije za age-related podatke:');
disp(coef_table_age);

[coef_vaccine_grupisano] = corrcoef(vaccine_grupisano.Variables);
vaccine_var_names = vaccine_grupisano.Properties.VariableNames;
coef_table_vaccine = array2table(coef_vaccine_grupisano, 'RowNames', vaccine_var_names, 'VariableNames', vaccine_var_names);
disp('Tabela koeficijenata korelacije za vaccine-related podatke:');
disp(coef_table_vaccine);

[coef_GHSI_grupisano]= corrcoef (ghsi_grupisano.Variables);
ghsi_var_names = ghsi_grupisano.Properties.VariableNames;
coef_table_ghsi = array2table(coef_GHSI_grupisano, 'RowNames', ghsi_var_names, 'VariableNames', ghsi_var_names);
disp('Tabela koeficijenata korelacije za GHSI-related podatke:');
disp(coef_table_ghsi);

[coef_mobility_grupisano] = corrcoef(mobility_grupisano.Variables);
mobility_var_names = mobility_grupisano.Properties.VariableNames;
coef_table_mobility = array2table(coef_mobility_grupisano, 'RowNames', mobility_var_names, 'VariableNames', mobility_var_names);
disp('Tabela koeficijenata korelacije za mobility-related podatke:');
disp(coef_table_mobility);

%% procenat varijabilnosti podataka i broj PCs potreban da procenat bude >=85%


% Age-related, procenat varijanse PC
cumulative_explained_age = cumsum(explained_age_related); % vektor cumulativno sabranih varijansi
disp(' ');
disp('Age-related:');
for i = 1:length(cumulative_explained_age) % prolazi se kroz ceo vektor kumulativnog zbira
    fprintf('Prvih %d PC predstavlja %.2f%% varijanse.\n', i, cumulative_explained_age(i));
    if cumulative_explained_age(i) >= 85
        fprintf('Treba uzeti prvih %d PC da bi se predstavilo >= 85%% varijanse.\n', i);
        break
    end
end

% Vaccine-related
cumulative_explained_vaccine = cumsum(explained_vaccine_related);
disp(' ');
disp('Vaccine-related:');
for i = 1:length(cumulative_explained_vaccine)
    fprintf('Prvih %d PC predstavlja %.2f%% varijanse.\n', i, cumulative_explained_vaccine(i));
    if cumulative_explained_vaccine(i) >= 85
        fprintf('Treba uzeti prvih %d PC da bi se predstavilo >= 85%% varijanse.\n', i);
        break
    end
end

% GHSI-related 
cumulative_explained_GHSI = cumsum(explained_GHSI_related);
disp(' ');
disp('GHSI-related:');
for i = 1:length(cumulative_explained_GHSI)
    fprintf('Prvih %d PC predstavlja %.2f%% varijanse.\n', i, cumulative_explained_GHSI(i));
    if cumulative_explained_GHSI(i) >= 85
        fprintf('Treba uzeti prvih %d PC da bi se predstavilo >= 85%% varijanse.\n', i);
        break
    end
end


% Mobility-related
cumulative_explained_mobility = cumsum(explained_mobility_related);
disp(' ');
disp('Mobility-related:');
for i = 1:length(cumulative_explained_mobility)
    fprintf('Prvih %d PC predstavlja %.2f%% varijanse.\n', i, cumulative_explained_mobility(i));
    if cumulative_explained_mobility(i) >= 85
        fprintf('Treba uzeti prvih %d PC da bi se predstavilo >= 85%% varijanse.\n', i);
        break
    end
end

%% kreiranje matrice sa PCs umesto originalnih varijabli

tabela_sa_PCs = omicron_i_GHSI_tabela;

% Zamena Age-related varijabli sa PC_Age
% Uklanjanje originalne varijable
tabela_sa_PCs = removevars(tabela_sa_PCs, {'median_age', 'age_65_older'});
% Ubacivanje PC_Age 
tabela_sa_PCs = addvars(tabela_sa_PCs, principle_age_1, 'After', 'pop_density', 'NewVariableNames', 'PC_Age');

% Zamena Vaccine-related varijabli sa PC_Vaccine
tabela_sa_PCs = removevars(tabela_sa_PCs, {'fully_vaccinated', 'boosters'});
tabela_sa_PCs = addvars(tabela_sa_PCs, principle_vaccine_1, 'After', 'immunity_proxy_deaths', 'NewVariableNames', 'PC_Vaccine');

% Zamena GHSI-related varijabli sa GHSI-PCs
tabela_sa_PCs = removevars(tabela_sa_PCs, {'GHSI Overall','GHSI Prevent','GHSI Detect','GHSI Respond',...
                                         'GHSI Health','GHSI Norms','GHSI Risk','HDI'});
tabela_sa_PCs = addvars(tabela_sa_PCs, principle_GHSI_1, 'After', 'onset', 'NewVariableNames', 'PC_GHSI_1');
tabela_sa_PCs = addvars(tabela_sa_PCs, principle_GHSI_2, 'After', 'PC_GHSI_1', 'NewVariableNames', 'PC_GHSI_2');
tabela_sa_PCs = addvars(tabela_sa_PCs, principle_GHSI_3, 'After', 'PC_GHSI_2', 'NewVariableNames', 'PC_GHSI_3');

% Zamena Mobility-related varijabli sa Mobility-PCs
tabela_sa_PCs = removevars(tabela_sa_PCs, {'mobility_retail','mobility_grocery','mobility_parks',...
                                         'mobility_transit','mobility_workplace','mobility_residential'});
tabela_sa_PCs = addvars(tabela_sa_PCs, principle_mobility_1, 'Before', 'onset', 'NewVariableNames', 'PC_Mobility_1');
tabela_sa_PCs = addvars(tabela_sa_PCs, principle_mobility_2, 'After', 'PC_Mobility_1', 'NewVariableNames', 'PC_Mobility_2');
tabela_sa_PCs = addvars(tabela_sa_PCs, principle_mobility_3, 'After', 'PC_Mobility_2', 'NewVariableNames', 'PC_Mobility_3');

disp(' ');
disp('Matrica sa zamenjenim varijablama:');
disp(head(tabela_sa_PCs));



%% nazivi kolona i R mean vektor

nazivi_kolona = tabela_sa_PCs.Properties.VariableNames;
disp('Nazivi kolona: ')
disp (nazivi_kolona);

R_mean_vector = tabela_sa_PCs.R_mean;
disp('Vektor R mean vrednosti: ');
disp(R_mean_vector);

%% cuvanje tabele, naziva kolona i R mean vektora

save ('tabela_sa_PCs');
save('nazivi_kolona');
save('R_mean_vector');
disp ('Sacuvani tabela,, nazivi kolona i R mean vektor');


%% korelaciona analiza 

[koef, pValue] = corrcoef(tabela_sa_PCs.Variables); % numericka matrica
% disp('Pearsonovi koeficijenti su: ')
% disp(koef);
% disp('P vrednosti su: ');
% disp(pValue);

%% Heatmap koeficijenata

% imena varijabli bez '_' da bi se izbegao subscript
var_names = {
    'immunity proxy'; 'PC vaccine'; 'stringency'; 'pop. density';...
    'PC age'; 'cardiovasc'; 'diabetes'; 'PC mobility 1'; 'PC mobility 2'; 'PC mobility 3';...
    'onset'; 'PC GHSI 1'; 'PC GHSI 2'; 'PC GHSI 3'; 'R mean'
    };

% Colormap (Dark Red to White to Dark Blue)
num_colors_in_cmap = 256;
cmap = interp1([-1 -0.6 -0.2 0 0.2 0.6 1], ...
    [0.5 0 0; 0.75 0.25 0.25; 0.95 0.75 0.75; 1 1 1; 0.75 0.75 0.95; 0.25 0.25 0.75; 0 0 0.5], ...
    linspace(-1, 1, num_colors_in_cmap), 'linear');
cmap(cmap < 0) = 0; cmap(cmap > 1) = 1;

figure; 

imagesc(koef);  
colormap(cmap);
clim([-1 1]);  

axis equal tight; % kvadrati
set(gca, 'YDir', 'reverse'); % Set Y-axis reverse da bi varijable isle odozgo

set(gca, 'XTick', 1:length(var_names));
set(gca, 'YTick', 1:length(var_names));
set(gca, 'XTickLabel', var_names);
set(gca, 'YTickLabel', var_names);

xtickangle(45); % X-axis labels 45 stepeni 

title('Koeficijenti korelacije');

cb = colorbar; 
cb.Label.String = 'Koeficijent korelacije'; 
cb.Ticks = [-1 -0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8 1]; 

%% Heatmap P vrednosti 

% Colormap (White to Dark Blue)
num_colors_in_cmap = 256;
cmap_p_value= interp1([0 0.5 1], ...
                                 [1 1 1;
                                  0.5 0.5 1;
                                  0 0 0.5], ...
                                 linspace(0, 1, num_colors_in_cmap)); 

cmap_p_value(cmap_p_value < 0) = 0;
cmap_p_value(cmap_p_value > 1) = 1;

figure;
imagesc(pValue);
colormap(cmap_p_value);
clim([0 1]);

axis equal tight; 
set(gca, 'YDir', 'reverse');

set(gca, 'XTick', 1:length(var_names));
set(gca, 'YTick', 1:length(var_names));
set(gca, 'XTickLabel', var_names);
set(gca, 'YTickLabel', var_names);

xtickangle(45);

title('P vrednost');

cb = colorbar;
cb.Label.String = 'P vrednost';
cb.Ticks = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];

% Figure size
set(gcf, 'Position', [100 100 800 700]); % [left bottom width height]



