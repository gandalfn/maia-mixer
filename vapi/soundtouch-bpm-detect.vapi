[CCode (cheader_filename = "soundtouch-bpm-detect.h")]
namespace Soundtouch {
    [Compact, CCode (cname = "SoundtouchBPMDetect", free_function = "soundtouch_bpm_detect_free")]
    public class BPMDetect {
        [CCode (cname = "soundtouch_bpm_detect_new")]
        public BPMDetect (int numChannels, int sampleRate);

        [CCode (cname = "soundtouch_bpm_detect_input_samples")]
        public void input_samples (float[] samples);

        [CCode (cname = "soundtouch_bpm_detect_get_bpm")]
        public float get_bpm ();
    }
}
