[CCode (cheader_filename = "libswresample/swresample.h")]
namespace Sw.Resample
{
    [CCode (cname = "enum SwrDitherType", cprefix = "SWR_DITHER_")]
    public enum DitherType
    {
        NONE,
        RECTANGULAR,
        TRIANGULAR,
        TRIANGULAR_HIGHPASS,
        NS_LIPSHITZ,
        NS_F_WEIGHTED,
        NS_MODIFIED_E_WEIGHTED,
        NS_IMPROVED_E_WEIGHTED,
        NS_SHIBATA,
        NS_LOW_SHIBATA,
        NS_HIGH_SHIBATA
    }

    [CCode (cname = "enum SwrEngine", cprefix = "SWR_ENGINE_")]
    public enum Engine
    {
        SWR,
        SOXR
    }

    [CCode (cname = "enum SwrFilterType", cprefix = "SWR_FILTER_TYPE_")]
    public enum FilterType
    {
        CUBIC,
        BLACKMAN_NUTTALL,
        KAISER
    }

    [Compact, CCode (cname = "SwrContext", free_function = "swr_free", free_function_address_of = true)]
    public class Context
    {
        public bool is_initialized {
            [CCode (cname = "swr_is_initialized")]
            get;
        }

        [CCode (cname = "swr_alloc")]
        public Context ();

        [CCode (cname = "swr_init")]
        public int init ();

        [CCode (cname = "swr_close")]
        public void close ();

        [CCode (cname = "swr_convert")]
        public int convert([CCode (array_length = false)]uint8[] out, int out_count, [CCode (array_length = false)]uint8[] in , int in_count);

        [CCode (cname = "swr_next_pts")]
        public int64 next_pts(int64 pts);

        [CCode (cname = "swr_set_compensation")]
        public int set_compensation(int sample_delta, int compensation_distance);

        [CCode (cname = "swr_set_channel_mapping")]
        public int set_channel_mapping([CCode (array_length = false)]int[] channel_map);

        [CCode (cname = "swr_set_matrix")]
        public int set_matrix([CCode (array_length = false)]double[] matrix, int stride);

        [CCode (cname = "swr_drop_output")]
        public int drop_output(int count);

        [CCode (cname = "swr_inject_silence")]
        public int inject_silence(int count);

        [CCode (cname = "swr_get_delay")]
        public int64 get_delay(int64 base);

        [CCode (cname = "swr_get_out_samples")]
        public int get_out_samples(int in_samples);

        [CCode (cname = "swr_convert_frame")]
        public int convert_frame(Av.Util.Frame output, Av.Util.Frame input);

        [CCode (cname = "swr_config_frame")]
        public int config_frame(Av.Util.Frame out, Av.Util.Frame in);
    }
}
