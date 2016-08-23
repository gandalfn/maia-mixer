[CCode (lower_case_cprefix = "resample_", cheader_filename="libresample.h")]
namespace Resample
{
    [Compact, CCode (cname = "void", free_function = "resample_close")]
    public class Handle
    {
        public int filter_width {
            [CCode (cname = "resample_get_filter_width")]
            get;
        }
        [CCode (cname = "resample_open")]
        public Handle (bool highQuality, double minFactor, double maxFactor);

        [CCode (cname = "resample_dup")]
        public Handle dup ();

        [CCode (cname = "resample_process")]
        public int process (double  factor, float[] inBuffer, bool lastFlag, out int inBufferUsed, float[] outBuffer);
    }
}
