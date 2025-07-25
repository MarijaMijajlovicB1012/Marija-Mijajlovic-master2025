%% transformacije

load T_data_matrix_input.mat

T_data_matrix_input.immunity_proxy_deaths= T_data_matrix_input.immunity_proxy_deaths.^(1/3);
T_data_matrix_input.fully_vaccinated = -sqrt(max(T_data_matrix_input.fully_vaccinated)- T_data_matrix_input.fully_vaccinated);
T_data_matrix_input.boosters = T_data_matrix_input.boosters.^(1/3);
T_data_matrix_input.pop_density = log(T_data_matrix_input.pop_density);
T_data_matrix_input.median_age = T_data_matrix_input.median_age.^2;
T_data_matrix_input.age_65_older= T_data_matrix_input.age_65_older.^(1/3);
T_data_matrix_input.cardiovasc = log(T_data_matrix_input.cardiovasc);
T_data_matrix_input.diabetes = T_data_matrix_input.diabetes.^(1/3);
T_data_matrix_input.HDI = -sqrt(max(T_data_matrix_input.HDI)- T_data_matrix_input.HDI);
T_data_matrix_input.mobility_retail = log(T_data_matrix_input.mobility_retail-min(T_data_matrix_input.mobility_retail));
T_data_matrix_input.mobility_grocery = log(T_data_matrix_input.mobility_grocery-min(T_data_matrix_input.mobility_grocery));
T_data_matrix_input.mobility_parks = (T_data_matrix_input.mobility_parks-min(T_data_matrix_input.mobility_parks)).^(1/3);
T_data_matrix_input.mobility_transit = (T_data_matrix_input.mobility_transit-min(T_data_matrix_input.mobility_transit)).^(1/3);
T_data_matrix_input.mobility_workplace = sqrt(T_data_matrix_input.mobility_workplace-min(T_data_matrix_input.mobility_workplace));
T_data_matrix_input.mobility_residential = - (max(T_data_matrix_input.mobility_residential)-T_data_matrix_input.mobility_residential).^(1/3);
T_data_matrix_input.R_mean = log(T_data_matrix_input.R_mean);

%% transformisana tabela

data1= T_data_matrix_input;

%% matrica outliera
TF= isoutlier(data1);

%% fja

function [data2] = substitue_outliers(TF, data1)
    data2 = table('Size', size(data1), 'VariableTypes', varfun(@class, data1, 'OutputFormat', 'cell'), 'VariableNames', data1.Properties.VariableNames);

    for i = 1:size(TF, 1)
        for j = 1:size(TF, 2)
            if TF(i, j) == 1
                data2{i, j} = nanmedian(data1{:, j}); 
            else
                data2{i, j} = data1{i, j}; 
            end
        end
    end

    % Preserve row names
    data2.Properties.RowNames = data1.Properties.RowNames;
end

data2 = substitue_outliers (TF,data1)

