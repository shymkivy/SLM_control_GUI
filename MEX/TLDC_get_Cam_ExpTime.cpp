#include "mex.h"
#include "uc480.h"

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray*prhs[] )
{     
   int error;
   HCAM cam = *(HCAM *)mxGetPr(prhs[0]);
   double *EXP_min, *EXP_max, *EXP_interval;
   
   plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
   plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
   plhs[2] = mxCreateDoubleMatrix(1,1,mxREAL);
   EXP_min		= mxGetPr(plhs[0]); 
   EXP_max		= mxGetPr(plhs[1]);
   EXP_interval = mxGetPr(plhs[2]);

   /* Check for proper number of arguments */
   if (!(nrhs == 1 )) {mexErrMsgTxt("you have to give me one input(s)"); }
   else if (!(nlhs == 3)) {mexErrMsgTxt("Error:Not enough input(s)");}
   /* get exposure range */
   error = is_GetExposureRange (cam, EXP_min, EXP_max, EXP_interval);
   if (!(error == IS_SUCCESS )) {mexErrMsgTxt("exposure range not found"); }
}