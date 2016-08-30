namespace Av.Util
{
    [CCode (cheader_filename = "libavutil/mathematics.h")]
    namespace Mathematics
    {
        [CCode (cname = "M_E")]
        public const double E;
        [CCode (cname = "M_LN2")]
        public const double LN2;
        [CCode (cname = "M_LN10")]
        public const double LN10;
        [CCode (cname = "M_LOG2_10")]
        public const double LOG2_10;
        [CCode (cname = "M_PHI")]
        public const double PHI;
        [CCode (cname = "M_PI")]
        public const double PI;
        [CCode (cname = "M_PI_2")]
        public const double PI_2;
        [CCode (cname = "M_SQRT1_2")]
        public const double SQRT1_2;
        [CCode (cname = "M_SQRT2")]
        public const double SQRT2;
        [CCode (cname = "NAN")]
        public const double NAN;
        [CCode (cname = "INFINITY")]
        public const double INFINITY;

        [CCode (cname = "enum AVRounding", cprefix = "AV_ROUND_")]
        public enum Rounding
        {
            ZERO,
            INF,
            DOWN,
            UP,
            NEAR_INF,
            PASS_MINMAX
        }

        [CCode (cname = "av_gcd")]
        public static int64 gcd(int64 a, int64 b);
        [CCode (cname = "av_rescale")]
        public static int64 rescale(int64 a, int64 b, int64 c);
        [CCode (cname = "av_rescale_rnd")]
        public static int64 rescale_rnd(int64 a, int64 b, int64 c, Rounding r);
        [CCode (cname = "av_rescale_q")]
        public static int64 rescale_q(int64 a, Rational bq, Rational cq);
        [CCode (cname = "av_rescale_q_rnd")]
        public static int64 rescale_q_rnd(int64 a, Rational bq, Rational cq, Rounding r);
        [CCode (cname = "av_compare_ts")]
        public static int compare_ts(int64 ts_a, Rational tb_a, int64 ts_b, Rational tb_b);
        [CCode (cname = "av_compare_mod")]
        public static int64 compare_mod(uint64 a, uint64 b, uint64 mod);
        [CCode (cname = "av_rescale_delta")]
        public int64 rescale_delta(Rational in_tb, int64 in_ts,  Rational fs_tb, int duration, out int64 last, Rational out_tb);
        [CCode (cname = "av_add_stable")]
        public int64 add_stable(Rational ts_tb, int64 ts, Rational inc_tb, int64 inc);
    }

    [SimpleType, CCode (cname = "AVRational", cheader_filename = "libavutil/rational.h")]
    public struct Rational
    {
        public int num;
        public int den;

        [CCode (cname = "av_make_q")]
        public Rational (int num, int den);
        [CCode (cname = "av_cmp_q")]
        public int cmp_q (Rational other);
        [CCode (cname = "av_q2d")]
        public double q2d ();
        [CCode (cname = "av_reduce")]
        public static int reduce(out int dst_num, out int dst_den, int64 num, int64 den, int64 max);
        [CCode (cname = "av_mul_q")]
        public Rational mul_q(Rational c);
        [CCode (cname = "av_div_q")]
        public Rational div_q(Rational c);
        [CCode (cname = "av_add_q")]
        public Rational add_q(Rational c);
        [CCode (cname = "av_sub_q")]
        public Rational sub_q(Rational c);
        [CCode (cname = "av_inv_q")]
        public Rational inv_q();
        [CCode (cname = "av_d2q")]
        public static Rational d2q(double d, int max);
        [CCode (cname = "av_nearer_q")]
        public int nearer_q(Rational q1, Rational q2);
        [CCode (cname = "av_find_nearest_q_idx")]
        public int find_nearest_q_idx([CCode (array_length = false)]Rational[] q_list);
        [CCode (cname = "av_q2intfloat")]
        public uint32 q2intfloat();
    }

    [Flags, CCode (cname = "int", cprefix = "AV_DICT_", cheader_filename = "libavutil/dict.h")]
    public enum DictionaryFlags
    {
        MATCH_CASE,
        IGNORE_SUFFIX,
        DONT_STRDUP_KEY,
        DONT_STRDUP_VAL,
        DONT_OVERWRITE,
        APPEND,
        MULTIKEY
    }

    [Compact, CCode (cname = "AVDictionaryEntry", free_function = "av_free", cheader_filename = "libavutil/dict.h")]
    public class DictionaryEntry
    {
        public string key;
        public string @value;
    }

    [Compact, CCode (cname = "AVDictionary", free_function = "av_dict_free", free_function_address_of = true, cheader_filename = "libavutil/dict.h")]
    public class Dictionary
    {
        public int count {
            [CCode (cname = "av_dict_count")]
            get;
        }

        [CCode (cname = "av_dict_get")]
        public unowned DictionaryEntry? @get (string key, DictionaryEntry? prev, DictionaryFlags flags = (DictionaryFlags)0);
        [CCode (cname = "av_dict_set")]
        public static int @set(out Dictionary pm, string key, string @value, DictionaryFlags flags = (DictionaryFlags)0);
        [CCode (cname = "av_dict_set_int")]
        public static int set_int(out Dictionary pm, string key, int64 @value, DictionaryFlags flags = (DictionaryFlags)0);
        [CCode (cname = "av_dict_parse_string")]
        public static int parse_string(out Dictionary pm, string str, string key_val_sep, string pairs_sep, DictionaryFlags flags = (DictionaryFlags)0);
        [CCode (cname = "av_dict_copy")]
        public static int copy(out Dictionary dst, Dictionary src, DictionaryFlags flags = (DictionaryFlags)0);
        [CCode (cname = "av_dict_get_string")]
        public int get_string(out string buffer, char key_val_sep, char pairs_sep);
    }

    [CCode (cname = "enum AVMediaType", cprefix = "AVMEDIA_TYPE_", cheader_filename = "libavutil/avutil.h")]
    public enum MediaType
    {
        UNKNOWN,
        VIDEO,
        AUDIO,
        DATA,
        SUBTITLE,
        ATTACHMENT;

        [CCode (cname = "av_get_media_type_string")]
        public unowned string to_string ();
    }

    [CCode (cname = "enum AVColorRange", cprefix = "AVCOL_RANGE_", cheader_filename = "libavutil/pixfmt.h")]
    public enum ColorRange
    {
        UNSPECIFIED,
        MPEG,
        JPEG
    }

    [CCode (cname = "enum AVColorPrimaries", cprefix = "AVCOL_PRI_", cheader_filename = "libavutil/pixfmt.h")]
    public enum ColorPrimaries
    {
        RESERVED0,
        BT709,
        UNSPECIFIED,
        RESERVED,
        BT470M,
        BT470BG,
        SMPTE170M,
        SMPTE240M,
        FILM,
        BT2020,
        SMPTEST428_1
    }

    [CCode (cname = "enum AVColorTransferCharacteristic", cprefix = "AVCOL_TRC_", cheader_filename = "libavutil/pixfmt.h")]
    public enum ColorTransferCharacteristic
    {
        RESERVED0,
        BT709,
        UNSPECIFIED,
        RESERVED,
        GAMMA22,
        GAMMA28,
        SMPTE170M,
        SMPTE240M,
        LINEAR,
        LOG,
        LOG_SQRT,
        IEC61966_2_4,
        BT1361_ECG,
        IEC61966_2_1,
        BT2020_10,
        BT2020_12,
        SMPTEST2084,
        SMPTEST428_1,
        ARIB_STD_B67
    }

    [CCode (cname = "enum AVColorSpace", cprefix = "AVCOL_SPC_", cheader_filename = "libavutil/pixfmt.h")]
    public enum ColorSpace
    {
        RGB,
        BT709,
        UNSPECIFIED,
        RESERVED,
        FCC,
        BT470BG,
        SMPTE170M,
        SMPTE240M,
        YCOCG,
        BT2020_NCL,
        BT2020_CL
    }

    [CCode (cname = "enum AVChromaLocation", cprefix = "AVCHROMA_LOC_", cheader_filename = "libavutil/pixfmt.h")]
    public enum ChromaLocation
    {
        UNSPECIFIED,
        LEFT,
        CENTER,
        TOPLEFT,
        TOP,
        BOTTOMLEFT,
        BOTTOM
    }

    [CCode (cname = "enum AVSampleFormat", cprefix = "AV_SAMPLE_FMT_", cheader_filename = "libavutil/samplefmt.h")]
    public enum SampleFormat
    {
        NONE,
        U8,
        S16,
        S32,
        FLT,
        DBL,
        U8P,
        S16P,
        S32P,
        FLTP,
        DBLP
    }

    [CCode (cname = "enum AVPixelFormat", cprefix = "AV_PIX_FMT_", cheader_filename = "libavutil/pixfmt.h")]
    public enum PixelFormat
    {
        NONE,
        YUV420P,
        YUYV422,
        RGB24,
        BGR24,
        YUV422P,
        YUV444P,
        YUV410P,
        YUV411P,
        GRAY8,
        MONOWHITE,
        MONOBLACK,
        PAL8,
        YUVJ420P,
        YUVJ422P,
        YUVJ444P,
        XVMC_MPEG2_MC,
        XVMC_MPEG2_IDCT,
        UYVY422,
        UYYVYY411,
        BGR8,
        BGR4,
        BGR4_BYTE,
        RGB8,
        RGB4,
        RGB4_BYTE,
        NV12,
        NV21,
        ARGB,
        RGBA,
        ABGR,
        BGRA,
        GRAY16BE,
        GRAY16LE,
        YUV440P,
        YUVJ440P,
        YUVA420P,
        VDPAU_H264,
        VDPAU_MPEG1,
        VDPAU_MPEG2,
        VDPAU_WMV3,
        VDPAU_VC1,
        RGB48BE,
        RGB48LE,
        RGB565BE,
        RGB565LE,
        RGB555BE,
        RGB555LE,
        BGR565BE,
        BGR565LE,
        BGR555BE,
        BGR555LE,
        VAAPI_MOCO,
        VAAPI_IDCT,
        VAAPI_VLD,
        VAAPI,
        YUV420P16LE,
        YUV420P16BE,
        YUV422P16LE,
        YUV422P16BE,
        YUV444P16LE,
        YUV444P16BE,
        VDPAU_MPEG4,
        DXVA2_VLD,
        RGB444LE,
        RGB444BE,
        BGR444LE,
        BGR444BE,
        YA8,
        Y400A,
        GRAY8A,
        BGR48BE,
        BGR48LE,
        YUV420P9BE,
        YUV420P9LE,
        YUV420P10BE,
        YUV420P10LE,
        YUV422P10BE,
        YUV422P10LE,
        YUV444P9BE,
        YUV444P9LE,
        YUV444P10BE,
        YUV444P10LE,
        YUV422P9BE,
        YUV422P9LE,
        VDA_VLD,
        GBRP,
        GBRP9BE,
        GBRP9LE,
        GBRP10BE,
        GBRP10LE,
        GBRP16BE,
        GBRP16LE,
        YUVA422P,
        YUVA444P,
        YUVA420P9BE,
        YUVA420P9LE,
        YUVA422P9BE,
        YUVA422P9LE,
        YUVA444P9BE,
        YUVA444P9LE,
        YUVA420P10BE,
        YUVA420P10LE,
        YUVA422P10BE,
        YUVA422P10LE,
        YUVA444P10BE,
        YUVA444P10LE,
        YUVA420P16BE,
        YUVA420P16LE,
        YUVA422P16BE,
        YUVA422P16LE,
        YUVA444P16BE,
        YUVA444P16LE,
        VDPAU,
        XYZ12LE,
        XYZ12BE,
        NV16,
        NV20LE,
        NV20BE,
        RGBA64BE,
        RGBA64LE,
        BGRA64BE,
        BGRA64LE,
        YVYU422,
        VDA,
        YA16BE,
        YA16LE,
        GBRAP,
        GBRAP16BE,
        GBRAP16LE,
        QSV,
        MMAL,
        D3D11VA_VLD,
        CUDA,
        0RGB,
        RGB0,
        0BGR,
        BGR0,
        YUV420P12BE,
        YUV420P12LE,
        YUV420P14BE,
        YUV420P14LE,
        YUV422P12BE,
        YUV422P12LE,
        YUV422P14BE,
        YUV422P14LE,
        YUV444P12BE,
        YUV444P12LE,
        YUV444P14BE,
        YUV444P14LE,
        GBRP12BE,
        GBRP12LE,
        GBRP14BE,
        GBRP14LE,
        YUVJ411P,
        BAYER_BGGR8,
        BAYER_RGGB8,
        BAYER_GBRG8,
        BAYER_GRBG8,
        BAYER_BGGR16LE,
        BAYER_BGGR16BE,
        BAYER_RGGB16LE,
        BAYER_RGGB16BE,
        BAYER_GBRG16LE,
        BAYER_GBRG16BE,
        BAYER_GRBG16LE,
        BAYER_GRBG16BE,
        XVMC,
        YUV440P10LE,
        YUV440P10BE,
        YUV440P12LE,
        YUV440P12BE,
        AYUV64LE,
        AYUV64BE,
        VIDEOTOOLBOX,
        P010LE,
        P010BE,
        GBRAP12BE,
        GBRAP12LE,
        GBRAP10BE,
        GBRAP10LE
    }
}
