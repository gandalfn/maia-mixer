#ifdef __cplusplus
extern "C"
{
#endif
    typedef void SoundTouch;

    typedef enum
    {
        SOUNDTOUCH_SETTING_USE_AA_FILTER = 0,
        SOUNDTOUCH_SETTING_AA_FILTER_LENGTH = 1,
        SOUNDTOUCH_SETTING_USE_QUICKSEEK = 2,
        SOUNDTOUCH_SETTING_SEQUENCE_MS = 3,
        SOUNDTOUCH_SETTING_SEEKWINDOW_MS = 4,
        SOUNDTOUCH_SETTING_OVERLAP_MS = 5,
        SOUNDTOUCH_SETTING_NOMINAL_INPUT_SEQUENCE = 6,
        SOUNDTOUCH_SETTING_NOMINAL_OUTPUT_SEQUENCE = 7
    } SoundTouchSetting;

    const char *get_version ();
    unsigned int get_version_id();

    SoundTouch* soundtouch_new ();
    void soundtouch_free (SoundTouch* self);

    void soundtouch_set_rate (SoundTouch* self, double newRate);
    void soundtouch_set_tempo (SoundTouch* self, double newTempo);
    void soundtouch_set_rate_change (SoundTouch* self, double newRate);
    void soundtouch_set_tempo_change (SoundTouch* self, double newTempo);
    void soundtouch_set_pitch (SoundTouch* self, double newPitch);
    void soundtouch_set_pitch_octaves(SoundTouch* self, double newPitch);
    void soundtouch_set_pitch_semi_tones (SoundTouch* self, double newPitch);
    void soundtouch_set_channels (SoundTouch* self, unsigned int numChannels);
    void soundtouch_set_sample_rate (SoundTouch* self, unsigned int srate);

    void soundtouch_put_samples (SoundTouch* self, float* samples, unsigned int numSamples);
    unsigned int soundtouch_receive_samples (SoundTouch* self, float *output, unsigned int maxSamples);
    unsigned int soundtouch_advance (SoundTouch* self, unsigned int maxSamples);
    void soundtouch_clear (SoundTouch* self);

    int soundtouch_set_setting (SoundTouch* self, int settingId, int value);
    int soundtouch_get_setting(SoundTouch* self, int settingId);

    unsigned int soundtouch_num_unprocessed_samples (SoundTouch* self);

    unsigned int soundtouch_num_samples(SoundTouch* self);
    int soundtouch_is_empty (SoundTouch* self);

#ifdef __cplusplus
}
#endif
