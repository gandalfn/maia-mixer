#include <soundtouch/SoundTouch.h>
#include <soundtouch.h>

const char *get_version ()
{
    return soundtouch::SoundTouch::getVersionString ();
}

unsigned int get_version_id()
{
    return soundtouch::SoundTouch::getVersionId ();
}

SoundTouch* soundtouch_new ()
{
    return (SoundTouch*)new soundtouch::SoundTouch ();
}

void soundtouch_free (SoundTouch* self)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    delete pThis;
}

void soundtouch_set_rate (SoundTouch* self, double newRate)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    pThis->setRate (newRate);
}

void soundtouch_set_tempo (SoundTouch* self, double newTempo)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    pThis->setTempo (newTempo);
}

void soundtouch_set_rate_change (SoundTouch* self, double newRate)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    pThis->setRateChange (newRate);
}

void soundtouch_set_tempo_change (SoundTouch* self, double newTempo)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    pThis->setTempoChange (newTempo);
}

void soundtouch_set_pitch (SoundTouch* self, double newPitch)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    pThis->setPitch (newPitch);
}

void soundtouch_set_pitch_octaves(SoundTouch* self, double newPitch)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    pThis->setPitchOctaves (newPitch);
}

void soundtouch_set_pitch_semi_tones (SoundTouch* self, double newPitch)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    pThis->setPitchSemiTones (newPitch);
}

void soundtouch_set_channels (SoundTouch* self, unsigned int numChannels)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    pThis->setChannels (numChannels);
}

void soundtouch_set_sample_rate (SoundTouch* self, unsigned int srate)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    pThis->setSampleRate (srate);
}

void soundtouch_put_samples (SoundTouch* self, float* samples, unsigned int numSamples)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    pThis->putSamples (samples, numSamples);
}

unsigned int soundtouch_receive_samples (SoundTouch* self, float *output, unsigned int maxSamples)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    return pThis->receiveSamples (output, maxSamples);
}

unsigned int soundtouch_advance (SoundTouch* self, unsigned int maxSamples)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    return pThis->receiveSamples (maxSamples);
}

void soundtouch_clear (SoundTouch* self)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    pThis->clear ();
}

int soundtouch_set_setting (SoundTouch* self, int settingId, int value)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    return pThis->setSetting (settingId, value);
}

int soundtouch_get_setting (SoundTouch* self, int settingId)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    return pThis->getSetting (settingId);
}

unsigned int soundtouch_num_unprocessed_samples (SoundTouch* self)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    return pThis->numUnprocessedSamples ();
}

unsigned int soundtouch_num_samples(SoundTouch* self)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    return pThis->numSamples ();
}

int soundtouch_is_empty (SoundTouch* self)
{
    soundtouch::SoundTouch* pThis = (soundtouch::SoundTouch*)self;
    return pThis->isEmpty ();
}
