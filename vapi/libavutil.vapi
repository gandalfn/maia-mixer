namespace Av.Util
{
    [CCode (cheader_filename = "mathematics.h")]
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

        [CCode (cname = "AVRounding", cprefix = "AV_ROUND_")]
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

    [SimpleType, CCode (cname = "AVRational", cheader_filename = "rational.h")]
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

    [Flags, CCode (cname = "int", cprefix = "AV_DICT_", cheader_filename = "dict.h")]
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

    [Compact, CCode (cname = "AVDictionaryEntry", free_function = "av_free", cheader_filename = "dict.h")]
    public class DictionaryEntry
    {
        public string key;
        public string @value;
    }

    [Compact, CCode (cname = "AVDictionary", free_function = "av_dict_free", free_function_address_of = true, cheader_filename = "dict.h")]
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
}
