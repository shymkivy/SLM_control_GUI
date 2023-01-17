# SLM_microscope_GUI

GUI to control holographic imaging/stimulation microscope. 
Especially useful if you want to control subregions of the SLM
	
Author: Yuriy Shymkiv, shymkivy@gmail.com

under construction, but sections below work, more or less

# Installation 
MATLAB 2019 (MATLAB 2020 has issues with updating graphics)
req: image processing toolbox

Download code and run "SLM_control_GUI" from its directory

# Calibrations to do:
1. Align the laser polarization to SLM
2. LUT calibration, global plus global/regional correction if using different wavelengths simultaneously
3. XYZ affine transform calibration for coordinate rotation, beam xyz offset for alignment of two beams, and axial x/z and y/z offsets
4. Adaptive Optics corrections (with large image of SLM at pupil plane can have significant z dependent aberrations)

# LUT calibration and correction
SLM will require a LUT calibration file, either global(.lut) or regional(.txt) that will be specific to a wavelength. Lut scripts in the SLM_calibration_scripts folder can be used to generate global/regional lut. Note, with regional (.txt) lut SLM upload speed will be slowed down by 1-2ms if not using triggering.
LUT calibration file should be placed in 'SLM_calibration/lut_calibration/' dir. In 'f_SLM_GIU_default_ops.m' it can be specified under 'SLM_params(1).lut_fname' parameter.
LUT correction files can be used to load corrections to hologram ahead of application of LUT calibration file. This allows the use of single global lut and multiple wavelengths in different regions of SLM by applying local correction for each wavelength. Also using lut correction with global lut can speed up upload time by avoiding regional(.txt) lut.
LUT correction files for each LUT calibration file should be placed in a subdirectory with the name of LUT calibration file 'SLM_calibration/lut_calibration/linear/'

# Parameters

Basic parameters may need to be changed inside "f_SLM_GUI_default_ops.m"
1. SLM needs to be installed (BNS 1152x1920). SDK path needs to be correct inside "f_SLM_initialize.m" file
2. Default lut file specified by "ops.lut_fname" needs to be present in '\SLM_microscope_GUI\SLM_calibration\lut_calibration\' directory
3. "ops.effective_NA" effects the defocus distance and needs to be adjusted for specific objective (calibrate with beads)
4. "ops.NI_DAQ_dvice" channel name and appropriate AO, AI, and counter channels need to be specified and connected to 2p microscope. "End of Frame" trigger from microscope goes into counter and used for fast updating of SLM patterns following the end of frames. AO from DAQ controlled by GUI goes into microscope trigger in (for scanning with triggering of every frame). AI channel will be used to read what stimulation pattern is supposed to be uploaded at the time of scan.
5. There is a "default roi list" wich refers to regions of the SLM that will be used independently. Each region will need a "lateral_affine_transform" file located in "\SLM_microscope_GUI\SLM_calibration\xyz_calibration\", otherwise erase the specified file names.

# XYZ patterns
There are 3 levels of organization
1. Each point in XYZ has its own index
2. Pattern is a collection of points that will be generated simultaneously
3. Pattern group is a collection of patterns that can be uploaded in some sequence during a scan and with stimulation.  

# Scan
Here one can select a saved pattern group for volumetric and/or multiplexed imaging

# Generate Hologram
This is designed to upload any of the provided holograms to any region of SLM. 
1. select the pattern and parameters
2. Press "Generate ____"
3. Press "Upload Hologram"

# Adaptive Optics:
AO auto optimization scan explained:

Process:
1. SLM GUI sends trigger to 2p software (e.g. PrairieView)
2. microscope scans single frame and saves as tiff slice
3. SLM GUI waits for tiff to appear and loads it
4. SLM GUI analyzes PSF, updates SLM, and sends next trigger.

Setting up:

On SLM_GUI side:
1. connect two computers through local network and provide folder path with saved tiff files to "Scan frames dir path"
2. Move to desired Z through XYZ patterns window
3. Fill zernike table with appropriate number of modes.
4. Select the number of iterations to scan 
5. Adjust "Post scan delay" to long enough period (+.5sec for 16 ave and +.8sec for 32 ave for PrairieView). SLM_GUI needs to wait this extra time because the microscope software cannot keep up with imaging with every frame being triggered

On microscope side (works with PrairieView):
1. Set scan with triggering every frame, preferably averaging 16 or 32.
2. Set number of frames to value specified in "Num scan frames" in SLM_GUI
3. Each frame is saved to a directory as separate slice
4. Connect SLM_GUI DAQ AO channel to microscope trigger in
5. Connect microscope "End of Frame" triggers to SLM_GUI DAQ counter channel.

To start:
1. Start microscope scan, which will be waiting for trigger
2. press "Start optimization scan" in SLM_GUI



