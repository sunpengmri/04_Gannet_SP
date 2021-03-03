function run_count = SavePDF(h, MRS_struct, ii, jj, kk, vox, module, run_count)

% Gannet logo
Gannet_logo = fullfile(fileparts(which('GannetLoad')), 'Gannet3_logo.png');
I = imread(Gannet_logo, 'png', 'BackgroundColor', [1 1 1]);
axes('Position', [0.825, 0.05, 0.125, 0.125]);
imshow(I);
text(0.9, 0, MRS_struct.version.Gannet, 'Units', 'normalized', 'FontName', 'Arial', 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'left');
axis off square;

% Gannet documentation
axes('Position', [(1-0.9)/2, 0.025, 0.9, 0.15]);
str = 'For complete documentation, please visit: https://markmikkelsen.github.io/Gannet-docs';
text(0.5, 0, str, 'FontName', 'Arial', 'FontSize', 11, 'HorizontalAlignment', 'center');
axis off square;

% Output time
axes('Position', [0.5, 0.98, 0.9, 0.15]);
text(0.9, 0, datestr(clock, 'dd-mmm-yyyy HH:MM:SS'), 'FontName', 'Arial', 'FontSize', 11, 'HorizontalAlignment', 'right');
axis off square;

if any(strcmp(listfonts, 'Arial'))
    set(findall(h, '-property', 'FontName'), 'FontName', 'Arial');
end
set(findall(h, '-property', 'XColor'), 'XColor', [0 0 0]);
set(findall(h, '-property', 'YColor'), 'YColor', [0 0 0]);

% If export_fig is installed, export PDF using it
if MRS_struct.p.append && ~isempty(fileparts(which('export_fig')))
    
    scr_sz = get(0,'ScreenSize');
    fig_w  = 11*72;
    fig_h  = 8.5*72;
    set(gcf, 'Units', 'Pixels', 'Position', [(scr_sz(3)-fig_w)/2, (scr_sz(4)-fig_h)/2, fig_w, fig_h]);
    
    % Create output dir
    if ~exist(fullfile(pwd, 'Gannet_output'), 'dir')
        mkdir(fullfile(pwd, 'Gannet_output'));
    end
    
    pdf_name = fullfile(pwd, 'Gannet_output', [module '.pdf']);
    if exist(pdf_name, 'file') && (ii + jj) == 2
        run_count = 1;
        pdf_name  = fullfile(pwd, 'Gannet_output', [module '-' num2str(run_count) '.pdf']);
        while 1
            if exist(pdf_name, 'file')
                run_count = run_count + 1;
                pdf_name  = fullfile(pwd, 'Gannet_output', [module '-' num2str(run_count) '.pdf']);
            else
                break
            end
        end
    elseif (ii + jj) > 2 && run_count > 0
        pdf_name = fullfile(pwd, 'Gannet_output', [module '-' num2str(run_count) '.pdf']);
    end
    
    export_fig(pdf_name, '-pdf', '-painters', '-append', '-nocrop', '-nofontswap', '-silent', h);
    
else
    
    set(h, 'PaperUnits', 'inches', 'PaperSize', [11 8.5], 'PaperPosition', [0 0 11 8.5]);
    
    % Create output folder
    if ~exist(fullfile(pwd, [module '_output']),'dir')
        mkdir(fullfile(pwd, [module '_output']));
    end
    
    % For Philips .data
    if strcmp(MRS_struct.p.vendor, 'Philips_data')
        fullpath = MRS_struct.metabfile{ii};
        fullpath = regexprep(fullpath, '.data', '_data');
        fullpath = regexprep(fullpath, '\', '_');
        fullpath = regexprep(fullpath, '/', '_');
    end
    
    if strcmp(MRS_struct.p.vendor, 'Siemens_rda')
        [~,metabfile_nopath] = fileparts(MRS_struct.metabfile{ii*2-1});
    else
        [~,metabfile_nopath] = fileparts(MRS_struct.metabfile{ii});
    end
    
    if strcmp(MRS_struct.p.vendor, 'Philips_data')
        if isfield(MRS_struct.p, 'trimmed_avgs')
            pdf_name = fullfile(pwd, 'GannetLoad_output', [fullpath '_' vox{kk} '_load_' num2str(MRS_struct.p.Navg(ii)) '_avgs.pdf']);
        else
            pdf_name = fullfile(pwd, 'GannetLoad_output', [fullpath '_' vox{kk} '_load.pdf']);
        end
    else
        if isfield(MRS_struct.p, 'trimmed_avgs')
            pdf_name = fullfile(pwd, 'GannetLoad_output', [metabfile_nopath '_' vox{kk} '_load_' num2str(MRS_struct.p.Navg(ii)) '_avgs.pdf']);
        else
            pdf_name = fullfile(pwd, 'GannetLoad_output', [metabfile_nopath '_' vox{kk} '_load.pdf']);
        end
    end
    
    saveas(h, pdf_name);
    
end


