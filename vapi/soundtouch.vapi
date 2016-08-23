[CCode (cheader_filename = "soundtouch.h")]
namespace soundtouch {
    [CCode (cname = "SoundTouchSetting", cprefix = "SOUNDTOUCH_SETTING_", cheader_filename = "soundtouch.h")]
    public enum Setting
    {
        USE_AA_FILTER,
        AA_FILTER_LENGTH,
        USE_QUICKSEEK,
        SEQUENCE_MS,
        SEEKWINDOW_MS,
        OVERLAP_MS,
        NOMINAL_INPUT_SEQUENCE,
        NOMINAL_OUTPUT_SEQUENCE
    }

    [Compact, CCode (cname = "SoundTouch", free_function = "soundtouch_free", cheader_filename = "soundtouch.h")]
    public class SoundTouch {

        public static unowned string version {
            [CCode (cname = "soundtouch_get_version")]
            get;
        }

        public static uint version_id {
            [CCode (cname = "soundtouch_get_version_id")]
            get;
        }

        public double rate {
            [CCode (cname = "soundtouch_set_rate")]
            set;
        }

        public double tempo {
            [CCode (cname = "soundtouch_set_tempo")]
            set;
        }

        public double rate_change {
            [CCode (cname = "soundtouch_set_rate_change")]
            set;
        }

        public double tempo_change {
            [CCode (cname = "soundtouch_set_tempo_change")]
            set;
        }

        public double pitch {
            [CCode (cname = "soundtouch_set_pitch")]
            set;
        }

        public double pitch_octaves {
            [CCode (cname = "soundtouch_set_pitch_octaves")]
            set;
        }

        public double pitch_semi_tones {
            [CCode (cname = "soundtouch_set_pitch_semi_tones")]
            set;
        }

        public uint channels {
            [CCode (cname = "soundtouch_set_channels")]
            set;
        }

        public uint sample_rate {
            [CCode (cname = "soundtouch_set_sample_rate")]
            set;
        }

        public uint num_unprocessed_samples {
            [CCode (cname = "soundtouch_num_unprocessed_samples")]
            get;
        }

        public uint num_samples {
            [CCode (cname = "soundtouch_num_samples")]
            get;
        }

        public bool is_empty {
            [CCode (cname = "soundtouch_is_empty")]
            get;
        }

        [CCode (cname = "soundtouch_new")]
        public SoundTouch ();

        [CCode (cname = "soundtouch_put_samples")]
        public void put_samples (float[] samples);

        [CCode (cname = "soundtouch_receive_samples")]
        public uint receive_samples (float[] output);

        [CCode (cname = "soundtouch_advance")]
        public uint advance (uint maxSamples);

        [CCode (cname = "soundtouch_clear")]
        public void clear ();

        [CCode (cname = "soundtouch_get_setting")]
        public int @get (Setting settingId);

        [CCode (cname = "soundtouch_set_setting")]
        public void @set (Setting settingId, int value);
    }
}
