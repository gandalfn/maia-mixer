[CCode (lower_case_cprefix = "mad_", cheader_filename="mad.h")]
namespace Mad
{
    [SimpleType, IntegerType (rank = 6), CCode (cname = "mad_fixed_t")]
    public struct Fixed : int
    {
        [CCode (cname = "MAD_F_FRACBITS")]
        public const int FRACBITS;

        [CCode (cname = "MAD_F_MIN")]
        public const Fixed MIN;

        [CCode (cname = "MAD_F_MAX")]
        public const Fixed MAX;

        [CCode (cname = "MAD_F_ONE")]
        public const Fixed ONE;

        [CCode (cname = "mad_f_tofixed")]
        public Fixed (double val);

        [CCode (cname = "mad_f_fromint")]
        public Fixed.fromint (int val);

        [CCode (cname = "mad_f_todouble")]
        public double to_double ();

        [CCode (cname = "mad_f_intpart")]
        public int intpart ();

        [CCode (cname = "mad_f_fracpart")]
        public int fracpart ();

        [CCode (cname = "mad_f_add")]
        public Fixed add (Fixed other);

        [CCode (cname = "mad_f_sub")]
        public Fixed sub (Fixed other);

        [CCode (cname = "mad_f_mul")]
        public Fixed mul (Fixed other);

        [CCode (cname = "mad_f_div")]
        public Fixed div (Fixed other);

        [CCode (cname = "mad_f_abs")]
        public Fixed abs ();
    }

    [CCode (cname = "enum mad_units", cprefix = "MAD_UNITS_", has_type_id = false)]
    public enum Units
    {
        HOURS,
        MINUTES,
        SECONDS,

        /* metric units */
        DECISECONDS,
        CENTISECONDS,
        MILLISECONDS,

        /* audio sample units */
        8000_HZ,
        11025_HZ,
        12000_HZ,
        16000_HZ,
        22050_HZ,
        24000_HZ,
        32000_HZ,
        44100_HZ,
        48000_HZ,

        /* video frame/field units */
        24_FPS,
        25_FPS,
        30_FPS,
        48_FPS,
        50_FPS,
        60_FPS,

        /* CD audio frames */
        75_FPS,

        /* video drop-frame units */
        23_976_FPS,
        24_975_FPS,
        29_97_FPS,
        47_952_FPS,
        49_95_FPS,
        59_94_FPS
    }

    [SimpleType, CCode (cname = "mad_timer_t", has_type_id = false)]
    public struct Timer
    {
        /**
         * whole seconds
         */
        public long seconds;
        /**
         * 1/MAD_TIMER_RESOLUTION seconds
         */
        public ulong fractions;

        [CCode (cname = "MAD_TIMER_RESOLUTION")]
        public const ulong RESOLUTION;

        [CCode (cname = "mad_timer_zero")]
        public static Timer ZERO;

        public void reset ();
        public int compare (Timer other);

        public long count (Units units);

        public static void add (ref Timer a, Timer b);
    }

    [CCode (cname = "enum mad_error", cprefix = "MAD_ERROR_", has_type_id = false)]
    public enum Error
    {
        /**
         * no error
         */
        NONE,

        /**
         * input buffer too small (or EOF)
         */
        BUFLEN,
        /**
         * invalid (null) buffer pointer
         */
        BUFPTR,

        /**
         * not enough memory
         */
        NOMEM,

        /**
         * lost synchronization
         */
        LOSTSYNC,
        /**
         * reserved header layer value
         */
        BADLAYER,
        /**
         * forbidden bitrate value
         */
        BADBITRATE,
        /**
         * reserved sample frequency value
         */
        BADSAMPLERATE,
        /**
         * reserved emphasis value
         */
        BADEMPHASIS,

        /**
         * CRC check failed
         */
        BADCRC,
        /**
         * forbidden bit allocation value
         */
        BADBITALLOC,
        /**
         * bad scalefactor index
         */
        BADSCALEFACTOR,
        /**
         * bad bitrate/mode combination
         */
        BADMODE,
        /**
         * bad frame length
         */
        BADFRAMELEN,
        /**
         * bad big_values count
         */
        BADBIGVALUES,
        /**
         * reserved block_type
         */
        BADBLOCKTYPE,
        /**
         * bad scalefactor selection info
         */
        BADSCFSI,
        /**
         * bad main_data_begin pointer
         */
        BADDATAPTR,
        /**
         * bad audio data length
         */
        BADPART3LEN,
        /**
         * bad Huffman table select
         */
        BADHUFFTABLE,
        /**
         * Huffman data overrun
         */
        BADHUFFDATA,
        /**
         * incompatible block_type for JS
         */
        BADSTEREO;

        [CCode (cname = "MAD_RECOVERABLE")]
        public bool is_recoverable ();
    }

    [CCode (cname = "int", cprefix = "MAD_OPTION_", has_type_id = false)]
    public enum Option
    {
        IGNORECRC,      /* ignore CRC errors */
        HALFSAMPLERATE  /* generate PCM at 1/2 sample rate */
    }

    [CCode (cname = "struct mad_stream", destroy_function = "mad_stream_finish", has_type_id = false)]
    public struct Stream
    {
        public Error error;

        public uchar* this_frame;
        public uchar* next_frame;

        [CCode (cname = "mad_stream_init")]
        public Stream ();

        public void options (Option option);

        public void buffer (uchar* buffer, ulong length);

        public void skip (ulong length);

        public int sync ();

        public unowned string? errorstr ();

        public inline bool have_recoverable_error ()
        {
            return error.is_recoverable ();
        }

        public inline bool have_unrecoverable_error ()
        {
            return (Mad.Error.NONE != error) && !have_recoverable_error ();
        }

        public inline bool is_valid ()
        {
            return !have_unrecoverable_error ();
        }
    }

    [CCode (cname = "enum mad_layer", cprefix = "MAD_LAYER_", has_type_id = false)]
    public enum Layer
    {
        I   = 1, /* Layer I */
        II  = 2, /* Layer II */
        III = 3  /* Layer III */
    }

    [CCode (cname = "enum mad_mode", cprefix = "MAD_MODE_", has_type_id = false)]
    public enum Mode
    {
        SINGLE_CHANNEL, /* single channel */
        DUAL_CHANNEL,   /* dual channel */
        JOINT_STEREO,   /* joint (MS/intensity) stereo */
        STEREO          /* normal LR stereo */
    }

    [CCode (cname = "enum mad_emphasis", cprefix = "MAD_EMPHASIS_", has_type_id = false)]
    public enum Emphasis
    {
        NONE,       /* no emphasis */
        50_15_US,   /* 50/15 microseconds emphasis */
        CCITT_J_17, /* CCITT J.17 emphasis */
        RESERVED    /* unknown emphasis */
    }

    [Flags, CCode (cname = "int", cprefix = "MAD_FLAG_", has_type_id = false)]
    public enum Flag
    {
        NPRIVATE_III,   /* number of Layer III private bits */
        INCOMPLETE,     /* header but not data is decoded */

        PROTECTION,     /* frame has CRC protection */
        COPYRIGHT,      /* frame is copyright */
        ORIGINAL,       /* frame is original (else copy) */
        PADDING,        /* frame has additional slot */

        I_STEREO,       /* uses intensity joint stereo */
        MS_STEREO,      /* uses middle/side joint stereo */
        FREEFORMAT,     /* uses free format bitrate */

        LSF_EXT,        /* lower sampling freq. extension */
        MC_EXT,         /* multichannel audio extension */
        MPEG_2_5_EXT    /* MPEG 2.5 (unofficial) extension */
    }

    [Flags, CCode (cname = "int", cprefix = "MAD_PRIVATE_", has_type_id = false)]
    public enum Private
    {
        HEADER,     /* header private bit */
        III         /* Layer III private bits (up to 5) */
    }

    [CCode (cname = "struct mad_header", destroy_function = "mad_header_finish", has_type_id = false)]
    public struct Header
    {
        public Layer layer;          /* audio layer (1, 2, or 3) */
        public Mode mode;            /* channel mode (see above) */
        public int mode_extension;   /* additional mode info */
        public Emphasis emphasis;    /* de-emphasis to use (see above) */

        public ulong bitrate;        /* stream bitrate (bps) */
        public uint samplerate;      /* sampling frequency (Hz) */

        public ushort crc_check;     /* frame CRC accumulator */
        public ushort crc_target;    /* final target CRC checksum */

        public Flag flags;           /* flags (see below) */
        public Private private_bits; /* private bits (see below) */

        public Timer duration;       /* audio playing time of frame */

        [CCode (cname = "mad_header_init")]
        public Header ();

        public int decode (ref Stream stream);

        [CCode (cname = "MAD_NCHANNELS")]
        public int nchannels ();

        [CCode (cname = "MAD_NSBSAMPLES")]
        public int nsbsamples ();
    }

    [CCode (cname = "struct mad_frame", destroy_function = "mad_frame_finish", has_type_id = false)]
    public struct Frame
    {
        public Header header;        /* MPEG audio header */

        public int options;          /* decoding options (from stream) */

        [CCode (cname = "mad_frame_init")]
        public Frame ();

        public void mute ();

        public int decode (ref Stream stream);
    }

    [CCode (cname = "int", cprefix = "MAD_CHANNEL_", has_type_id = false)]
    public enum Channel
    {
        SINGLE,
        DUAL_1,
        DUAL_2,
        STEREO_LEFT,
        STEREO_RIGHT
    }

    [SimpleType, CCode (cname = "struct mad_pcm", has_type_id = false)]
    public struct PCM
    {
        public uint samplerate;        /* sampling frequency (Hz) */
        public ushort channels;        /* number of channels */
        public ushort length;          /* number of samples per channel */
        public Fixed* samples;         /* PCM output samples [ch][sample] */

        public inline Fixed get (uint channel, uint index)
        {
            unowned Fixed[,] data = (Fixed[,])samples;
            data.length[0] = 2;
            data.length[1] = length;
            return data[channel, index];
        }

        public inline void set (uint channel, uint index, Fixed value)
        {
            unowned Fixed[,] data = (Fixed[,])samples;
            data.length[0] = 2;
            data.length[1] = length;
            data[channel, index] = value;
        }
    }

    [CCode (cname = "struct mad_synth", destroy_function = "mad_synth_finish", has_type_id = false)]
    public struct Synth
    {
        public Fixed[,,,,] filter;             /* polyphase filterbank outputs */
                                               /* [ch][eo][peo][s][v] */
        public uint phase;                     /* current processing phase */

        public PCM pcm;                        /* PCM output */

        [CCode (cname = "mad_synth_init")]
        public Synth ();

        public void mute ();

        public void frame (Frame frame);
    }

    [CCode (cname = "enum mad_flow", cprefix = "MAD_FLOW_", has_type_id = false)]
    public enum Flow
    {
        CONTINUE,   /* continue normally */
        STOP,       /* stop decoding normally */
        BREAK,      /* stop decoding and signal an error */
        IGNORE      /* ignore the current frame */
    }

    [CCode (cname = "input_func", simple_generics = true, has_target = false)]
    public delegate Flow InputFunc<T> (T data, Stream stream);
    [CCode (cname = "header_func", simple_generics = true, has_target = false)]
    public delegate Flow HeaderFunc<T> (T data, Header header);
    [CCode (cname = "filter_func", simple_generics = true, has_target = false)]
    public delegate Flow FilterFunc<T> (T data, Stream stream, Frame frame);
    [CCode (cname = "output_func", simple_generics = true, has_target = false)]
    public delegate Flow OutputFunc<T> (T data, Header header, PCM pcm);
    [CCode (cname = "error_func", simple_generics = true, has_target = false)]
    public delegate Flow ErrorFunc<T> (T data, Stream stream, Frame frame);
    [CCode (cname = "message_func", simple_generics = true, has_target = false)]
    public delegate Flow MessageFunc<T> (T data, void* message, uint size);

    [CCode (cname = "enum mad_decoder_mode", cprefix = "MAD_DECODER_MODE_", has_type_id = false)]
    public enum DecoderMode
    {
        SYNC,
        ASYNC
    }

    [CCode (cname = "struct mad_decoder", destroy_function = "mad_decoder_finish", has_type_id = false)]
    public struct Decoder<T>
    {
        [CCode (cname = "mad_decoder_init", simple_generics = true)]
        public Decoder (T data, InputFunc<T>? input, HeaderFunc<T>? header, FilterFunc<T>? filter, OutputFunc<T>? output, ErrorFunc<T>? error, MessageFunc<T>? message);

        public void options (int options);
        public void run (DecoderMode mode);
        public void message (void* message, uint size);
    }
}
