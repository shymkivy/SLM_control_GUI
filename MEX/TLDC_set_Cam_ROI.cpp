#include "mex.h"
#include "uc480.h"

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray*prhs[] )
{     
   int error;
   HCAM cam		= *(HCAM *)mxGetPr(prhs[0]);
   int pXPos	= *mxGetPr(prhs[1]);
   int pYPos	= *mxGetPr(prhs[2]);
   int pWidth	= *mxGetPr(prhs[3]);
   int pHeight	= *mxGetPr(prhs[4]);

   /* Check for proper number of arguments */
   if (!(nrhs == 5 )) {mexErrMsgTxt("you have to give me five inputs"); }

   error = is_AOI(cam, IS_SET_IMAGE_AOI, &pXPos, &pYPos, &pWidth, &pHeight);
   if (!(error == IS_SUCCESS )) {mexErrMsgTxt("ROI not successfully set"); }

}