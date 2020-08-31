#include "mex.h"
#include "uc480.h"

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray*prhs[] )
{     
   
   int error;
   HCAM cam = *(HCAM *)mxGetPr(prhs[0]);
   double *FTR_min, *FTR_max, *FTR_interval;
   //= mxGetPr(plhs[0]);
   //double *FTR_max = mxGetPr(plhs[1]);
   //double *FTR_interval = mxGetPr(plhs[2]);
   
   plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
   plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
   plhs[2] = mxCreateDoubleMatrix(1,1,mxREAL);
   FTR_min		= mxGetPr(plhs[0]); 
   FTR_max		= mxGetPr(plhs[1]);
   FTR_interval = mxGetPr(plhs[2]);

   /* Check for proper number of arguments */
   if (!(nrhs == 1 )) {mexErrMsgTxt("you have to give me one input(s)"); }
   else if (!(nlhs == 3)) {mexErrMsgTxt("Error:Not enough input(s)");}
   /* get frame rate time range */
   error = is_GetFrameTimeRange (cam, FTR_min, FTR_max, FTR_interval);
   if (!(error == IS_SUCCESS )) {mexErrMsgTxt("frame rate range not found"); }

}