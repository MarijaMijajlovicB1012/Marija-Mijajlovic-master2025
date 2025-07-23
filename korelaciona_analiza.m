%% Pearson and P value za data2
load data2
numeric_data2= data2.Variables; % zbog inf
[koef, pValue] = corrcoef(numeric_data2);
disp('Pearsonovi koeficijenti su: ')
disp(koef);
disp('P vrednosti su: ');
disp(pValue);



%% Heatmap koeficijenata

var_names = {
    'immunity proxy'; 'fully vaccinated'; 'boosters'; 'stringency'; 'pop. density';
    'median age'; 'older population'; 'cardiovasc'; 'diabetes'; 'HDI';
    'mobility retail'; 'mobility grocery'; 'mobility parks'; 'mobility transit';
    'mobility workplace'; 'mobility residential'; 'onset'; 'Ravg'
    };

% Colormap (Dark Red to White to Dark Blue)
num_colors_in_cmap = 256;
cmap = interp1([-1 -0.6 -0.2 0 0.2 0.6 1], ...
    [0.5 0 0; 0.75 0.25 0.25; 0.95 0.75 0.75; 1 1 1; 0.75 0.75 0.95; 0.25 0.25 0.75; 0 0 0.5], ...
    linspace(-1, 1, num_colors_in_cmap), 'linear');
cmap(cmap < 0) = 0; cmap(cmap > 1) = 1;


figure; 

% IMAGESC jer heatmap nije imao text opciju za cell
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

title('Koeficijenti korelacije i p vrednost');

cb = colorbar; 
cb.Label.String = 'Koeficijent korelacije'; 
cb.Ticks = [-1 -0.8 -0.6 -0.4 -0.2 0 0.2 0.4 0.6 0.8 1]; 

% Dodavanje p vrednosti
hold on; 

[rows, cols] = size(pValue);

for i = 1:rows
    for j = 1:cols
        currentPValue = pValue(i, j);
        currentKoef = koef(i, j); % Coefficient for text color decision

        if currentPValue > 0.05
            annotation_text = ' '; % P > 0.05
        elseif currentPValue > 0.01 && currentPValue <= 0.05
            annotation_text = '*'; % 0.01 < P <= 0.05
        elseif currentPValue > 0.001 && currentPValue <= 0.01
            annotation_text = '**'; %0.001 < P <= 0.01
        else 
            annotation_text = '***'; % P < 0.001
        end

  
        % Boja teksta (*)
        if currentKoef < -0.4 || currentKoef > 0.4 % Veca korelacija- cell tamne boje--tekst bele boje
            text_color = 'w';
        else % Manja korelacija- cell svetle boje--tekst crne boje
            text_color = 'k';
        end

        % Centriranje teksta u odnosu na cell 
        text(j, i, annotation_text, ... % col_index, row_index
             'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'middle', ...
             'Color', text_color, ...
             'FontSize', 10, ...
             'FontWeight', 'bold');
    end
end

hold off;

% Figure size
set(gcf, 'Position', [100 100 800 700]); % [left bottom width height]



%% Scatter plot paneli

% Funkcija za pojedinacni scatter
function plot_and_annotate_scatter(ax, x_data, y_data, current_x_var_name_display, y_var_name_display, coeff, p_val)
    % Tacno odredjena osa 'ax'
    scatter(ax, x_data, y_data, 'filled');
    
    hold(ax, 'on'); % ista osa unutar scattera

    % linearna regresija sa fitlm
    mdl = fitlm(x_data, y_data);
    x_fit_line = sort(x_data); % sortiranje od min do max x (duzina linije regresije)
    y_fit_line = predict(mdl, x_fit_line); 
    plot(ax, x_fit_line, y_fit_line, 'r-', 'LineWidth', 1.5); % linija regresije

    hold(ax, 'off'); % nije vise ista osa 

    xlabel(ax, current_x_var_name_display);
    ylabel(ax, y_var_name_display);
    title(ax, sprintf('%s vs. %s', current_x_var_name_display, y_var_name_display));
    grid(ax, 'on'); % linije unutar scattera

    % koeficijent i p vrednost
    coeff_str = sprintf('r = %.2f', coeff); % 2f broj decimala
    p_val_str = sprintf('p = %.3f', p_val); 
    
    % Pozicioniranje text boxa
    x_limits = xlim(ax);
    y_limits = ylim(ax);
    x_text_pos = x_limits(1) + 0.05 * (x_limits(2) - x_limits(1));
    y_text_pos_r = y_limits(2) - 0.05 * (y_limits(2) - y_limits(1)); % za koeficijent
    y_text_pos_p = y_limits(2) - 0.15 * (y_limits(2) - y_limits(1)); % za p vrednost

    % koeficijent
    text(ax, x_text_pos, y_text_pos_r, coeff_str, ...
         'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', ...
         'FontSize', 9, 'FontWeight', 'bold', 'BackgroundColor', 'w', 'EdgeColor', 'k'); % White background, black border
    
    % p vrednost
    text(ax, x_text_pos, y_text_pos_p, p_val_str, ...
         'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', ...
         'FontSize', 9, 'FontWeight', 'bold', 'BackgroundColor', 'w', 'EdgeColor', 'k');
end


% zajednicka y osa za sve scattere
y_var_name_display = 'Ravg';
y_var_name_lookup = 'Ravg';
idx_Ravg = find(strcmp(var_names, y_var_name_lookup));
y_data = numeric_data2(:, idx_Ravg);

disp('Generisanje scatter plotova...');


%% Pojedinacni scatter plotovi
disp('Kreirajju se pojedinacni scatter plotovi...');
individual_x_vars = {'immunity proxy', 'stringency', 'pop. density', 'HDI', 'onset'};

for k = 1:length(individual_x_vars)
    current_x_var_name_display = individual_x_vars{k};
    current_x_var_name_lookup = individual_x_vars{k};

    idx_x_var = find(strcmp(var_names, current_x_var_name_lookup));
    x_data = numeric_data2(:, idx_x_var); % x osa
    coeff = koef(idx_x_var, idx_Ravg);    % koeficijent
    p_val = pValue(idx_x_var, idx_Ravg);  % p vrednost
    
    figure; % za svaki scatter
    ax = gca; % trenutna plotting area 
    plot_and_annotate_scatter(ax, x_data, y_data, current_x_var_name_display, y_var_name_display, coeff, p_val);
end
disp('Pojedinacni scatter plotovi kreirani');


%% 1x2 scatter plotovi
disp('Kreiraju se 1x2 scatter plotovi...');

% Panel 1: Fully Vaccinated & Boosters
figure;
subplot_vars_1 = {'fully vaccinated', 'boosters'}; 
for k = 1:length(subplot_vars_1)
    ax = subplot(1, 2, k); % subplot (1 row, 2 columns, k-th plot)
    current_x_var_name_display = subplot_vars_1{k};
    current_x_var_name_lookup = subplot_vars_1{k};

    idx_x_var = find(strcmp(var_names, current_x_var_name_lookup));
    x_data = numeric_data2(:, idx_x_var);
    coeff = koef(idx_x_var, idx_Ravg);
    p_val = pValue(idx_x_var, idx_Ravg);

    plot_and_annotate_scatter(ax, x_data, y_data, current_x_var_name_display, y_var_name_display, coeff, p_val);
end
sgtitle('Ravg vs. Fully Vaccinated & Boosters'); % Naslov za zajednicki figure

% Panel 2: Median Age & Older Population
figure; 
subplot_vars_2_display = {'median age', 'age 65+'};
subplot_vars_2_lookup = {'median age', 'older population'};
for k = 1:length(subplot_vars_2_display)
    ax = subplot(1, 2, k);
    current_x_var_name_display = subplot_vars_2_display{k};
    current_x_var_name_lookup = subplot_vars_2_lookup{k};

    idx_x_var = find(strcmp(var_names, current_x_var_name_lookup));
    x_data = numeric_data2(:, idx_x_var);
    coeff = koef(idx_x_var, idx_Ravg);
    p_val = pValue(idx_x_var, idx_Ravg);

    plot_and_annotate_scatter(ax, x_data, y_data, current_x_var_name_display, y_var_name_display, coeff, p_val);
end
sgtitle('Ravg vs. Age Demographics');

% Panel 3: Cardiovascular & Diabetes
figure; 
subplot_vars_3 = {'cardiovasc', 'diabetes'};
for k = 1:length(subplot_vars_3)
    ax = subplot(1, 2, k);
    current_x_var_name_display = subplot_vars_3{k};
    current_x_var_name_lookup = subplot_vars_3{k};

    idx_x_var = find(strcmp(var_names, current_x_var_name_lookup));

    x_data = numeric_data2(:, idx_x_var);
    coeff = koef(idx_x_var, idx_Ravg);
    p_val = pValue(idx_x_var, idx_Ravg);

    plot_and_annotate_scatter(ax, x_data, y_data, current_x_var_name_display, y_var_name_display, coeff, p_val);
end
sgtitle('Ravg vs. Health Conditions');
disp('1x2 scatter plotovi kreirani');


%% 2x3 scattera
disp('Kreiraju se 2x3 scatter plotovi...');
figure;
mobility_x_vars = {'mobility retail', 'mobility grocery', 'mobility parks', ...
                   'mobility transit', 'mobility workplace', 'mobility residential'};

for k = 1:length(mobility_x_vars)
    ax = subplot(2, 3, k); % subplot (2 rows, 3 columns, k-th plot)
    current_x_var_name_display = mobility_x_vars{k};
    current_x_var_name_lookup = mobility_x_vars{k};

    idx_x_var = find(strcmp(var_names, current_x_var_name_lookup));
    x_data = numeric_data2(:, idx_x_var);
    coeff = koef(idx_x_var, idx_Ravg);
    p_val = pValue(idx_x_var, idx_Ravg);

    plot_and_annotate_scatter(ax, x_data, y_data, current_x_var_name_display, y_var_name_display, coeff, p_val);
end
sgtitle('Ravg vs. Mobility Indicators');
disp('2x3 panel plot kreiran');

disp('Svi scatter polotvi kreirani');

