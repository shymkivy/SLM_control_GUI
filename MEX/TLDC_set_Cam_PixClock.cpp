#include "mex.h"
#include "uc480.h"

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray*prhs[] )
{     
   int error;
   HCAM cam = *(HCAM *)mxGetPr(prhs[0]);
   int pixClock = *mxGetPr(prhs[1]);

   /* Check for proper number of arguments */
   if (!(nrhs == 2 )) {mexErrMsgTxt("you have to give me two inputs"); }

   error = is_SetPixelClock (cam, pixClock);
   if (!(error == IS_SUCCESS )) {mexErrMsgTxt("Pixel clock not successfully set"); }

}