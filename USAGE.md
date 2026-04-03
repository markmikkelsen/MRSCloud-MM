# Usage

- Use `run_all.m` as a wrapper for the main MRSCloud function `run_simulations_cloud.m` to batch-run multiple basis set simulations.
- Example `*.json` files can be found in `json_files/`.
- In the input `*.json` file, optional values for each key are:
  - `"metablisst"`: The spin systems you want to simulate.
  - `"mega_or_hadam"`: `"UnEdited"`, `"MEGA"`, `"HERMES"`, `"HERCULES"`, "`MQC`".
  - `"localization"`: `"PRESS"`, `"sLASER"`.
  - `"vendor"`: `"GE"`, `"Philips"`, `"Siemens"`, `"Universal_GE"`, `"Universal_Philips"`, `"Universal_Siemens"` (this is needed if the user does not specify the RF pulse parameters in `"pulses"` and the code must instead use defaults; the value is also used for naming output files).
  - `"taus"`: The interpulse timings for your sequence. They MUST sum to TE. Delays (the timings between pulses) are then calculated using `"taus"` and the durations of the RF pulses.
  - `"pulses"`: This object contains the parameters of the RF pulses to be used in the simulations. All RF pulses must be saved in `pulses/`. Enter the RF pulse filename (incl. the extension) in the `"name"` key.
- NOTE: An excitation pulse (`"exc"`) is normally not used in density matrix simulations for basis sets; the code has not been tested for such simulations.
- IMPORTANT: If the user does not provide RF pulse parameters, MRSCloud will use the defaults hard-coded in the software.
- IMPORTANT: The order of RF pulses for each localization sequence is hard-coded. To customize the order, the user will have to edit the source code.
