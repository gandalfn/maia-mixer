typedef void SoundtouchBPMDetect;

#ifdef __cplusplus
extern "C"
{
#endif

    SoundtouchBPMDetect* soundtouch_bpm_detect_new (int numChannels, int sampleRate);
    void soundtouch_bpm_detect_free (SoundtouchBPMDetect* self);
    void soundtouch_bpm_detect_input_samples (SoundtouchBPMDetect* self, const float* samples, int numSamples);
    float soundtouch_bpm_detect_get_bpm (SoundtouchBPMDetect* self);

#ifdef __cplusplus
}
#endif
