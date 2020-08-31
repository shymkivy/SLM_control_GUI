#include "mex.h"
#include "uc480.h"

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray*prhs[] )
{     
	/* Check for proper number of arguments */
    if (nrhs != 4) { mexErrMsgTxt("TLDC_set_Cam_Open:Four input(s) reqired");} 
	else if (nlhs != 2) { mexErrMsgTxt("TLDC_set_Cam_Open:Two output(s) required");} 
   
    /* Initialize Camera and get handle */
    int error;
    HCAM *pcam;
    plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS,mxREAL); //camera handle 1st output
    pcam = (HCAM *)mxGetPr(plhs[0]);       
    error = is_InitCamera(pcam,NULL);
    if (error != IS_SUCCESS) {mexErrMsgTxt("Error initializing camera");}
    HCAM cam = *pcam;
	      
    /* Get sensor info, principally for the CDD size */ 
    SENSORINFO sInfo;
    //int nX,nY;
	//error = is_GetSensorInfo( cam, &sInfo);     
	//nX = sInfo.nMaxWidth;
    //nY = sInfo.nMaxHeight;
    //if (error != IS_SUCCESS) { mexErrMsgTxt("Error getting sensor info"); }

	IS_RECT rectAOI;
	rectAOI.s32X		= *mxGetPr(prhs[0]);
    rectAOI.s32Y		= *mxGetPr(prhs[1]);
    rectAOI.s32Width	= *mxGetPr(prhs[2]);
    rectAOI.s32Height	= *mxGetPr(prhs[3]);
    error = is_AOI(cam, IS_AOI_IMAGE_SET_AOI, (void*)&rectAOI, sizeof(rectAOI));
    if (!(error == IS_SUCCESS )) {mexErrMsgTxt("ROI not successfully set"); }
    
	/*	Set the color depth to 8-bit greyscale */
    int BitsPerPixel = 8, ColorMode = IS_CM_MONO8;
    error = is_SetColorMode(cam, ColorMode);
    if (error != IS_SUCCESS) { mexErrMsgTxt("Error setting color mode"); }
 
	/* create matlab image structure with "image" field of uint8 data type, */
    /* "pointer" field with int-valued pointer to the image buffer, */
    /* and "ID" field with int-valued ID for this buffer. */
    char *pimage; 
    const char *field_names[] = {"image", "pointer", "ID"};
    mwSize dims[2] = {1, 1};
    plhs[1]				= mxCreateStructArray(2, dims, 3, field_names);//Create image structure
    int image_field		= mxGetFieldNumber(plhs[1],"image");
    int pointer_field	= mxGetFieldNumber(plhs[1],"pointer");
    int ID_field		= mxGetFieldNumber(plhs[1],"ID");
    mxArray *pimage_field;
    pimage_field = mxCreateNumericMatrix(rectAOI.s32Width,rectAOI.s32Height, mxUINT8_CLASS,mxREAL);
    mxSetFieldByNumber(plhs[1],0,image_field,pimage_field); 
    /*image array 2nd output, 1st field*/
    pimage = (char *)mxGetPr(pimage_field);
        
    //set the camera memory to the matlab image array
    int *ID,*ppointer;
    mxArray *ppointer_field;
    ppointer_field = mxCreateNumericMatrix(1, 1, mxINT32_CLASS,mxREAL);
    mxSetFieldByNumber(plhs[1],0,pointer_field,ppointer_field); 
    /*image memory pointer 2nd output, 2nd field*/
    ppointer = (int *)mxGetPr(ppointer_field);
    *ppointer = (int)pimage;
    
    mxArray *pID_field;
    pID_field = mxCreateNumericMatrix(1, 1, mxINT32_CLASS,mxREAL);
    mxSetFieldByNumber(plhs[1],0,ID_field,pID_field); 
    /*image memory pointer 2nd output, 3rd field*/
    ID = (int *)mxGetPr(pID_field);
   
    /* Set I.image to be memory buffer for camera, using its pointer, and 
    creating the "ID" for this memory buffer */
    error = is_SetAllocatedImageMem(cam,rectAOI.s32Width,rectAOI.s32Height,BitsPerPixel,pimage,ID);
    if (error != IS_SUCCESS) { mexErrMsgTxt("Error allocating image memory"); }
    //Activate I.image memory
    error = is_SetImageMem(cam,pimage,*ID);
    if (error !=IS_SUCCESS){ mexErrMsgTxt("Error activating image memory"); }
    //I'm also supposed to set the camera image
    //error = is_SetImageSize(cam, nX, nY );   
    //if (error !=IS_SUCCESS){ mexErrMsgTxt("Error setting image size"); }
 		

    return;   
}