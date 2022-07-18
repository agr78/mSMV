%% Prepare RDFs for healthy subjects
cd data/simulation
load('optimal_params.mat')
cd ..
cd 'healthy_subjects/control'
for j = 1:10
    if j < 10
        filename = strcat('00',num2str(j),'romeo_RDF');
        load(filename)
        iFreq_raw = Mask.*iFreq_raw;
        iFreq = Mask.*iFreq;
        iMag = Mask.*iMag;
    else
        filename = strcat('0',num2str(j),'romeo_RDF');
        load(filename)
        iFreq_raw = Mask.*iFreq_raw;
        iFreq = Mask.*iFreq;
        iMage = Mask.*iMag;
    end
    filename = strcat('romeo_RDF_anon_',string(j),'.mat');
    save(filename)
    clearvars -except j 
end