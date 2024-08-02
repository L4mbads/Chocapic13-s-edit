/*
const int colortex0Format = RGBA16F;				//low res clouds (deferred->composite2) + low res VL (composite5->composite15)
const int colortex1Format = RGBA16;					//terrain gbuffer (gbuffer->composite2)
const int colortex2Format = RGBA16F;				//forward + transparencies (gbuffer->composite4)
const int colortex3Format = R11F_G11F_B10F;			//frame buffer + bloom (deferred6->final)
const int colortex4Format = RGBA16F;				//light values and skyboxes (everything)
const int colortex5Format = R11F_G11F_B10F;			//TAA buffer (everything)
const int colortex6Format = R11F_G11F_B10F;			//additionnal buffer for bloom (composite3->final)
const int colortex7Format = RGBA8;					//Final output, transparencies id (gbuffer->composite4)
*/

//no need to clear the buffers, saves a few fps
/*
const bool colortex0Clear = false;
const bool colortex1Clear = false;
const bool colortex2Clear = true;
const bool colortex3Clear = false;
const bool colortex4Clear = false;
const bool colortex5Clear = false;
const bool colortex6Clear = false;
const bool colortex7Clear = false;
*/

const int noiseTextureResolution = 32;
const bool shadowHardwareFiltering = true;