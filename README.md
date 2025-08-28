## Description

**switchDataDictConfig** is a utility for Simulink&reg; projects that automates two common tasks:
- Cleans specified code generation and cache folders.
- Switches which configuration a reference entry in a Simulink data dictionary (.sldd) points to.

This helps streamline workflows in projects with multiple build or simulation configurations, especially in automated build, test, or deployment environments.

---

## Use Case

If your Simulink&reg; project uses a data dictionary with several configurations (e.g., `Simulation_Config`, `CodeGen_Config`, `Test_Config`) and a reference entry such as `Active_Config_Reference` to select the active configuration, this function lets you programmatically switch the reference and clean relevant folders in a single command.

---

## Getting Started

### Requirements

- MATLAB&reg; with Simulink&reg;
- Simulink Data Dictionary functionality

### Installation

1. Simply run the function with proper input selection, see example below.

---

## Usage

Call the function with the required parameters:

```matlab
switchDataDictConfig( ...
    'CodeFolder',    fullfile(pwd, 'Code'), ...
    'CacheFolder',   fullfile(pwd, 'Cache'), ...
    'DictionaryPath', fullfile(pwd, 'MonophonicSimulink', 'data.sldd'), ...
    'ConfigSection', 'Configurations', ...
    'ConfigEntry',   'Main_Reference_Config', ...
    'NewConfig',     'NXP_CodeGen_Config');
