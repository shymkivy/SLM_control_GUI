# SLM_microscope_GUI

GUI to control holographic imaging/stimulation microscope
	req: matlab image processing toolbox

Author: Yuriy Shymkiv, shymkivy@gmail.com

under construction, but sections below work, more or less





# Generate Hologram
This is designed to upload any of the provided holograms to any region of SLM. 
1. select the pattern and parameters
2. Press "Generate ____"
3. Press "Upload Hologram"

# XYZ patterns
There are 3 levels of organization
1. Each point in XYZ has its own index
2. Pattern is a collection of points that will be generated simultaneously
3. Pattern group is a collection of patterns that can be uploaded in some sequence during a scan and with stimulation.  

# Scan
Here one can select a saved pattern group for volumetric and/or multiplexed imaging

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
5. Adjust "Post scan delay" to long enough period (+.5sec for 16 ave and +.8sec for 32 ave for PrairieView). SLM_GUI needs to wait this extra time because the microscope software annot keep up with imaging with every frame being triggered

On microscope side (works with PrairieView):
1. Set scan with triggering every frame, preferably averaging 16 or 32.
2. Set number of frames to value specified in "Num scan frames" in SLM_GUI
3. Each frame is saved to a directory as separate slice
4. Connect SLM_GUI DAQ AO channel to microscope trigger in
5. Connect microscope "End of Frame" triggers to SLM_GUI DAQ counter channel.

To start:
1. Start microscope scan, which will be waiting for trigger
2. press "Start optimization scan" in SLM_GUI



