#include "mex.h"
#include "uc480.h"

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray*prhs[] )
{     
   int error;
   HCAM cam = *(HCAM *)mxGetPr(prhs[0]);
   
   /* Check for proper number of arguments */
   if (!(nrhs == 1 )) {mexErrMsgTxt("you have to give me one input"); }
   
   error = is_ExitCamera(cam);
   if (!(error == IS_SUCCESS )) {mexErrMsgTxt("camera did not close"); }

}