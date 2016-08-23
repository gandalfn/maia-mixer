#include <soundtouch/BPMDetect.h>
#include <soundtouch-bpm-detect.h>

SoundtouchBPMDetect*
soundtouch_bpm_detect_new (int numChannels, int sampleRate)
{
    return (SoundtouchBPMDetect*)new soundtouch::BPMDetect (numChannels, sampleRate);
}

void
soundtouch_bpm_detect_free (SoundtouchBPMDetect* self)
{
    soundtouch::BPMDetect* pThis = (soundtouch::BPMDetect*)self;
    delete pThis;
}

void
soundtouch_bpm_detect_input_samples (SoundtouchBPMDetect* self, const float* samples, int numSamples)
{
    soundtouch::BPMDetect* pThis = (soundtouch::BPMDetect*)self;
    pThis->inputSamples (samples, numSamples);
}

float
soundtouch_bpm_detect_get_bpm (SoundtouchBPMDetect* self)
{
    soundtouch::BPMDetect* pThis = (soundtouch::BPMDetect*)self;
    return pThis->getBpm ();
}
