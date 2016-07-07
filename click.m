function [ ] = click(face_hint, start_directory, whiskers)
%CLICK automates the entirety of the Clack whisker tracker. 
%Input 'facehint' and 'start_directory' as a string and "whiskers" as an integer
%Tom Vajtay 07/2016 Rutgers University
%  

working_directory = cd;
addpath(cd)
addpath matlab
addpath(start_directory);

    function clacker(face_hint, path, whiskers)
        cd(working_directory);
        tracer = sprintf('python python/batch.py "%s" -e trace -f *.tif', path);
        dos(tracer);

        cd(path)
        files = dir('*.whiskers');
        cd(working_directory); 
        M = size(files);
        M = M(1);
        for n = 1:M
            file = files(n);
            measures = file.name;
            measures = measures(1:end-8);
            measures = [measures 'measurements'];
            fprintf(1,'Measuring %s\n',file.name);
            stringm = sprintf('measure --face %s "%s\\%s" "%s\\%s" ', face_hint, path, file.name, path, measures);
            dos(stringm);
        end
        fprintf('Measurement complete\n')

        cd(path)
        files = dir('*.measurements');
        cd(working_directory); 
        M = size(files);
        M = M(1);
        for n = 1:M
            file = files(n);
            fprintf(1,'Classifying %s\n',file.name);
            stringc = sprintf('classify "%s\\%s" "%s\\%s" %s --px2mm 0.04 -n %1.0f ', path, file.name, path, file.name, face_hint, whiskers);
            dos(stringc);
        end
        fprintf('Classification complete\n')

        cd(path)
        files1 = dir('*.measurements');
        cd(working_directory); 

        S = size(files1);
        S = S(1);
        for n = 1:S
            file = files1(n);
            fprintf(1,'Re-Classifying %s\n',file.name);
            stringc = sprintf('reclassify -n %1.0f "%s\\%s" "%s\\%s" ', whiskers, path, file.name, path, file.name);
            dos(stringc);
        end
        fprintf('Reclassification complete\n')


        cd(path)
        measurements_files = dir('*.measurements');
        cd(working_directory); 

        d = size(measurements_files);
        d = d(1);
        for i = 1:d 
                file = measurements_files(i);
                B = [path '\' file.name];
                table = LoadMeasurements(B);
                cd(path)
                fprintf('Loading Measurements file for %s \n',file.name);
                name = file.name(1:end-12);
                name = [name 'mat'];
                save(name, 'table');
                fprintf('Saved data matrix for %s\n', file.name);
                cd(working_directory); 

        end

        cd(path)
        directory = dir('*.mat');
        F = size(directory);
        F = F(1);

        for i = 1:F
            X = directory(i).name;
            load(X);
            My_cell = struct2cell(table);
            My_cell = My_cell';
            My_cell = cellfun(@(x) single(x),My_cell);
            rows = size(My_cell);
            rows = rows(1);
            frames = max(My_cell(:,1));
            groups = [];
            data_array = zeros(frames,whiskers);
            figs = (whiskers - 1);
            while figs >= 0
                groups = [groups figs];
                figs = figs - 1;

            end

            for j = 1:rows
                if My_cell(j,3) < 0;
                else
                    L = find(My_cell(j,3) == groups);
                    frame = (My_cell(j,1) + 1);
                    data_array(frame, L) = My_cell(j,8);
                end
            end

            for t = 1:whiskers
                c = {'g' 'r' 'c' 'm' 'y' 'k'};
                subplot(1,2,1);
                plot(data_array(:,t), c{t});
                hold on
            end
            H = sprintf('%s\n Whisker angle', directory(i).name);
            title(H);
            xlabel('Frame');
            ylabel('angle');
            
            ER = sum(find(data_array == 0));
            average_angle = mean(data_array, 2);
            subplot(1,2,2);
            plot(average_angle, 'b');
            H = sprintf('%s\n  Average Whisker angle', directory(i).name);
            title(H);
            xlabel('Frame');
            ylabel('angle');
            header = directory(i).name;
            header = header(1:end-4);
            if ER > 0
                figname = sprintf('%s-ERRORS', header);
                fprintf('ERROR %s has a gap in data, please rectify \n', directory(i).name);
            else 
                figname = sprintf('%s-Average', header);
                fprintf('No errors in %s\n', directory(i).name);
            end
            saveas(gcf, figname, 'fig');
            close all

        end  
    end

    function [fold_detect,file_detect] = detector(path)
        cd(path)
        b = dir();
        files = dir('*.tif');
        isub = [b(:).isdir];
        nameFolds = {b(isub).name}';
        nameFolds(ismember(nameFolds,{'.','..'})) = [];
        fold_detect = size(nameFolds, 1);
        file_detect = size(files, 1);
    end

        
    
[fold,fil] = detector(start_directory);

if fil > 0
    clacker(face_hint, start_directory, whiskers);
elseif fil == 0
    fprintf('No tif files in the start directory\n');
end

if fold > 0
    target = [start_directory '\**\*.'];
    fprintf('Scanning all subdirectories from starting directory, please wait\n');
    D = rdir(target);             %// List of all sub-directories
    for k = 1:length(D)
        currpath = D(k).name;
        [~,fil] = detector(currpath);
        fprintf('Checking %s for tif files\n', currpath);
        if fil > 0
            clacker(face_hint, currpath, whiskers);
        end
    end
    finish = datestr(now);
    fprintf('Click completed at %s\n', finish);
    cd(working_directory);
elseif fold == 0
    finish = datestr(now);
    fprintf('Click completed at %s\n', finish);
end
end

