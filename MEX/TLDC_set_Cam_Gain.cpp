#include "mex.h"
#include "uc480.h"

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray*prhs[] )
{     
   int error;
   HCAM cam = *(HCAM *)mxGetPr(prhs[0]);
   double gain = *mxGetPr(prhs[1]);

   /* Check for proper number of arguments */
   if (!(nrhs == 2 )) {mexErrMsgTxt("TLDC_set_Cam_Gain:Need two input(s)"); }

   error = is_SetHWGainFactor (cam, IS_SET_MASTER_GAIN_FACTOR, gain);
   if (!(error == IS_SUCCESS )) {mexErrMsgTxt("TLDC_set_Cam_Gain:Gain not successfully set"); }
}