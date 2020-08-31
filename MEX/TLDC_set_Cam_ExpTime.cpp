#include "mex.h"
#include "uc480.h"

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray*prhs[] )
{     
   int error;
   HCAM cam = *(HCAM *)mxGetPr(prhs[0]);
   double exptime = *mxGetPr(prhs[1]);
   plhs[0]	= mxCreateDoubleMatrix(1,1,mxREAL);
   double *newEXP;
   newEXP	= mxGetPr(plhs[0]); 

   /* Check for proper number of arguments */
   if (!(nrhs == 2 )) {mexErrMsgTxt("you have to give me two inputs"); }

   error = is_SetExposureTime (cam, exptime, newEXP);
   if (!(error == IS_SUCCESS )) {mexErrMsgTxt("exposure time not successfully set"); }

}