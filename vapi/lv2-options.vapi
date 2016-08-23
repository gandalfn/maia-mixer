[CCode (cheader_filename = "lv2/lv2plug.in/ns/ext/options/options.h")]
namespace LV2.Options {
    [CCode (cname = "LV2_OPTIONS_URI")]
    public const string URI;

    [CCode (cname = "LV2_OPTIONS__Option")]
    public const string OPTION;
    [CCode (cname = "LV2_OPTIONS__interface")]
    public const string INTERFACE;
    [CCode (cname = "LV2_OPTIONS__options")]
    public const string OPTIONS;
    [CCode (cname = "LV2_OPTIONS__requiredOption")]
    public const string REQUIRED_OPTION;
    [CCode (cname = "LV2_OPTIONS__supportedOption")]
    public const string SUPPORTED_OPTION;

    [CCode (cname = "LV2_Options_Context", cprefix = "LV2_OPTIONS_")]
    public enum Context {
        INSTANCE,
        RESOURCE,
        BLANK,
        PORT
    }

    [CCode (cname = "LV2_Options_Option", has_destroy_function=false, has_copy_function=false)]
    public struct Option {
        Context context;
        uint32 subject;
        uint32 key;
        uint32 size;
        uint32 type;
        void*  @value;
    }

    [Flags, CCode (cname = "LV2_Options_Status", cprefix = "LV2_OPTIONS_")]
    public enum Status {
        SUCCESS,
        ERR_UNKNOWN,
        ERR_BAD_SUBJECT,
        ERR_BAD_KEY,
        ERR_BAD_VALUE
    }

    [CCode (has_target = false)]
    public delegate uint32 GetFunc (Handle instance, Option options);
    [CCode (has_target = false)]
    public delegate uint32 SetFunc (Handle instance, Option options);

    [CCode (cname = "LV2_Options_Interface", has_destroy_function=false, has_copy_function=false)]
    public struct Interface {
        GetFunc @get;
        SetFunc @set;
    }
}
