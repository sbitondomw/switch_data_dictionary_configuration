function switchDataDictConfig(varargin)
% switchDataDictConfig  Clean folders and switch a configuration reference in a Simulink data dictionary.
%
%   switchDataDictConfig('NewConfig', configName, ...
%                       'DictionaryPath', dictPath, ...)
%
% Automates the process of:
%   1) Cleaning specified folders (e.g., code output and cache).
%   2) Changing which configuration a named reference points to in a Simulink data dictionary (.sldd).
%
% USE CASE:
%   Suppose you manage several build configurations in your data dictionary,
%   like 'Simulation_Config', 'CodeGen_Config', and 'Test_Config', and use a
%   reference entry (e.g., 'Active_Config_Reference') to select which one is active.
%   This function lets you quickly switch the reference, e.g. for automated builds.
%
% USAGE EXAMPLES:
%   % Basic: Switch the reference entry to point to 'CodeGen_Config'
%   switchDataDictConfig('NewConfig', 'CodeGen_Config', ...
%                       'DictionaryPath', 'myModel/data.sldd')
%
%   % Specify custom folders and entry names:
%   switchDataDictConfig('CodeFolder', 'src', ...
%                       'CacheFolder', 'build_cache', ...
%                       'DictionaryPath', 'myModel/data.sldd', ...
%                       'ConfigSection', 'Configurations', ...
%                       'ConfigEntry', 'Active_Config_Reference', ...
%                       'NewConfig', 'Simulation_Config')
%
% Name-Value Pair Arguments:
%   'NewConfig'      - (Required) The configuration name to set as active.
%   'DictionaryPath' - (Required) Path to your .sldd file.
%   'CodeFolder'     - (Optional) Folder to clean (default: ./Code)
%   'CacheFolder'    - (Optional) Folder to clean (default: ./Cache)
%   'ConfigSection'  - (Optional) Section name in dictionary (default: 'Configurations')
%   'ConfigEntry'    - (Optional) Reference entry name (default: 'Active_Config_Reference')
%
% This script requires Simulink and Simulink Data Dictionary functionality.
%
% Author: Stefano Bitondo (2025)
% License: See LICENSE.txt for the BSD 3-Clause license terms.


% Parse inputs
p = inputParser;
addParameter(p, 'CodeFolder', fullfile(pwd, 'Code'), @ischar);
addParameter(p, 'CacheFolder', fullfile(pwd, 'Cache'), @ischar);
addParameter(p, 'DictionaryPath', '', @ischar);
addParameter(p, 'ConfigSection', 'Configurations', @ischar);
addParameter(p, 'ConfigEntry', 'Active_Config_Reference', @ischar);
addParameter(p, 'NewConfig', '', @ischar);
parse(p, varargin{:});
args = p.Results;

if isempty(args.NewConfig)
    error('switchDataDictConfig:MissingConfig', ...
        'You must specify the new configuration name using ''NewConfig''.');
end

if isempty(args.DictionaryPath)
    error('switchDataDictConfig:MissingDictionary', ...
        'You must specify the data dictionary path using ''DictionaryPath''.');
end

if ~isfile(args.DictionaryPath)
    error('switchDataDictConfig:DictionaryNotFound', ...
        'Data dictionary not found: %s', args.DictionaryPath);
end

% 1) Clean specified folders
cleanFolder(args.CodeFolder);
cleanFolder(args.CacheFolder);

% 2) Open data dictionary and switch config
dd   = Simulink.data.dictionary.open(args.DictionaryPath);
sect = getSection(dd, args.ConfigSection);
refEntry = getEntry(sect, args.ConfigEntry);
refVal   = getValue(refEntry);

if ~strcmp(refVal.SourceName, args.NewConfig)
    fprintf('Switching %s from "%s" to "%s"…\n', ...
        args.ConfigEntry, refVal.SourceName, args.NewConfig);
    refVal.SourceName = args.NewConfig;
    setValue(refEntry, refVal);
    saveChanges(dd);
else
    fprintf('%s already set to "%s", no change.\n', ...
        args.ConfigEntry, args.NewConfig);
end

close(dd);
fprintf('Done.\n');

end

function cleanFolder(folderPath)
% cleanFolder  Remove all files and subfolders from the specified folder.
if isfolder(folderPath)
    fprintf('Cleaning folder %s…\n', folderPath);
    files = dir(fullfile(folderPath, '*'));
    for k = files'
        if ~ismember(k.name, {'.', '..'})
            target = fullfile(folderPath, k.name);
            if k.isdir
                rmdir(target, 's');
            else
                delete(target);
            end
        end
    end
else
    mkdir(folderPath);
    fprintf('Created folder %s\n', folderPath);
end
end
