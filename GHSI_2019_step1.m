%% GHSI 2019 STEP 1


%% PRIPREMA GHSI PODATAKA

GHSI_2019_all_countries = readtable("GHSI_2019_extract_edit.xlsx")
% load GHSI_2019_all_countries

% provera postojanja duplikata

i=1;
duplikati=0;
redovi= size (GHSI_2019_all_countries,1);
while i<=redovi
    j=i+1;
    while j<=redovi
    if strcmp ((GHSI_2019_all_countries{i,1}), (GHSI_2019_all_countries{j,1}))
       duplikati=duplikati+1;
    end
    j=j+1;
    end
   i=i+1;
end
if duplikati==0
    disp('Drzave u GHSI tabeli se ne ponavljaju')
else 
    disp('Ima duplikata');
end

%% Izdvajanje 104 drzave u GHSI iz T tabele, sortiranje kao u T tabeli

load T_data_matrix_input.mat

% drzave iz T tabele i GHSI tabele

drzave_T_tabela = T_data_matrix_input.Properties.RowNames; % drzave kao nazivi redova
drzave_GHSI = GHSI_2019_all_countries.Country; % drzave u prvoj koloni

% drzave koje se poklapaju
zajednicke_drzave_logic = ismember(drzave_GHSI, drzave_T_tabela);

% nova tabela GHSI sa 104 drzave
GHSI_2019_104_drzave = GHSI_2019_all_countries(zajednicke_drzave_logic, :);

% Prva kolona (nazivi drzava) se potavlja kao naziv redova
GHSI_2019_104_drzave.Properties.RowNames = GHSI_2019_104_drzave{:,1};

% Redosled iz T tabele
redosled = T_data_matrix_input.Properties.RowNames;

% SORTIRANJE (reorderrows nije radio na tabeli)

% broj redova i kolona
num_cols = size(GHSI_2019_104_drzave, 2); % broj 2 predstavlja drugu dimenziju (kolone)
num_rows = length(redosled); % broj redova

% prazni cells za novu tabelu
sorted_data_cells = cell(num_rows, num_cols);

% 104 drzave, ali neodgovarajuci redosled
current_GHSI_row_names = GHSI_2019_104_drzave.Properties.RowNames;

num_matched_rows = 0;
for k = 1:num_rows
    current_country = redosled{k}; % redosled iz T tabele

  % trazenje drzave iz T tabele u GHSI tabeli i cuvanje broja reda u GHSI u kom se data drzava nalazi   
    [L, br_reda_drzave_u_GHSI] = ismember(current_country, current_GHSI_row_names); % L kao logical

    if L % ako se drzave poklapaju
        num_matched_rows = num_matched_rows + 1;
        % kopira se red iz GHSI tabele od 104 drzave
        sorted_data_cells(num_matched_rows, :) = table2cell(GHSI_2019_104_drzave(br_reda_drzave_u_GHSI, :));
    end
end

% konverzija u tabelu
GHSI_2019_104_drzave_sortirano = cell2table(sorted_data_cells(1:num_matched_rows,:));

% cuvanje imena varijabli
GHSI_2019_104_drzave_sortirano.Properties.VariableNames = GHSI_2019_104_drzave.Properties.VariableNames;

% namestanje redova
GHSI_2019_104_drzave_sortirano.Properties.RowNames = redosled(1:num_matched_rows);

% provera da li je isti broj drzava
if height(GHSI_2019_104_drzave_sortirano) == height(T_data_matrix_input)
    disp('Sve 104 drzave iz T tabele nalaze se i u GHSI tabeli (196 drzave) i prikazane su u novoj GHSI tabeli (104 drzave)');
else
    disp('Neke drzave iz T tabele se ne nalaze u GHSI tabeli');
end

disp('Drzave u GHSI tabeli se sortiraju prema T tabeli...')

GHSI_2019_104_drzave_sortirano_konacna_verzija = GHSI_2019_104_drzave_sortirano;
GHSI_2019_104_drzave_sortirano_konacna_verzija(:,1) = []; % brisanje prve kolone sa nazivima drzava
disp ('GHSI tabela sa 104 drzave sortirane prema T tabeli: ')
disp (GHSI_2019_104_drzave_sortirano_konacna_verzija)

%% boxcox transformacija i histogrami


GHSI_transformisana= GHSI_2019_104_drzave_sortirano_konacna_verzija;
varNames = GHSI_2019_104_drzave_sortirano_konacna_verzija.Properties.VariableNames;
numVars = length(varNames); % broj kolona

for i=1:numVars

[GHSI_transformisana{:,i}] = boxcox(GHSI_2019_104_drzave_sortirano_konacna_verzija{:,i});

figure
subplot(1, 2, 1);
histogram(GHSI_2019_104_drzave_sortirano_konacna_verzija{:,i});
grid on; 
title([varNames{i},' pre transformacije', ]);

subplot(1, 2, 2);
histogram(GHSI_transformisana{:,i});
grid on;
title([varNames{i},' nakon boxcox transformacije ', ])

end

disp ('Transformisana GHSI tabela: ')
disp (GHSI_transformisana)

%% Outliers

disp ('Provera autlajera pre i posle transformacije...')

TF_pre_transformacije = isoutlier(GHSI_2019_104_drzave_sortirano_konacna_verzija);
TF_posle_transformacije = isoutlier(GHSI_transformisana);

if sum  (TF_pre_transformacije)== 0
    disp('U GHSI tabeli pre transformacije nema autlajera.')
    else
    disp('U GHSI tabeli pre transformacije ima autlajera.');
end

if sum  (TF_posle_transformacije)== 0 
    disp('U GHSI tabeli posle transformacije nema autlajera.');
else
    disp('U GHSI tabeli posle transformacije ima autlajera.');
end


%% Skewness 

varNames = GHSI_2019_104_drzave_sortirano_konacna_verzija.Properties.VariableNames;
numVars = length(varNames); % broj kolona

% cell za skewness vrednost
skewness_vrednost_pre = cell(1, numVars);
skewness_vrednost_posle = cell (1,numVars);

for i = 1:numVars
    currentVarName = varNames{i}; % ime trenutne kolone
    
    trenutna_kolona_pre = GHSI_2019_104_drzave_sortirano_konacna_verzija.(currentVarName); 
    trenutna_kolona_posle = GHSI_transformisana.(currentVarName);

    % racunanje skewnessa za svaku kolonu
        skewness_vrednost_pre{i} = skewness(trenutna_kolona_pre);
        skewness_vrednost_posle{i} = skewness(trenutna_kolona_posle);

end
% pravljenje tabele, {:} sluzi da bi se niz vrednosti mogao ubaciti u tabelu
skewness_pre = table(skewness_vrednost_pre{:}, 'VariableNames', varNames);
skewness_posle = table (skewness_vrednost_posle{:}, 'VariableNames', varNames);

disp('Skewness varijabli pre transformacije: ');
disp(skewness_pre);
disp ('Skewness varijabli posle transformacije')
disp (skewness_posle)


%% pravljenje objedinjene tabele


% promena imena varijabli, dodavanje GHSI 

% rec koju dodajemo
rec = 'GHSI ';
currentVarNames = GHSI_transformisana.Properties.VariableNames;

% cell u kom ce biti ime
newVarNames = cell(size(currentVarNames));

for i = 1:length(currentVarNames)

    newVarNames{i} = [rec,currentVarNames{i} ]; % dodajemo GHSI pre imena varijable
end

% dodajemo nova imena kolonama
GHSI_transformisana.Properties.VariableNames = newVarNames;

% disp('Tabela nakon izmene naziva varijabli:');
% disp(GHSI_transformisana);



% provera redosleda drzava

disp('Provera redosleda drzava u GHSI i omicron tabeli pre spajanja...')

load data2.mat % transformisana omicron tabela iz prvog zadatka (praksa za master)

redosled_omicron = data2.Properties.RowNames;
redosled_GHSI = GHSI_transformisana.Properties.RowNames;

if isequal(redosled_omicron, redosled_GHSI)
    disp('Redosled drzava u omicron i GHSI tabeli je isti. ');
else
    disp('Redosled drzava se razlikuje.');
end



% objedinjavanje tabela

omicron_17_kolona = data2 (:,1:17);
omicron_18_kolona = data2 (:, 18);

omicron_i_GHSI_tabela = horzcat (omicron_17_kolona, GHSI_transformisana, omicron_18_kolona);

disp('Objedinjena tabela: ')
disp (omicron_i_GHSI_tabela)
