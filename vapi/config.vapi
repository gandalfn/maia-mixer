[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "config.h")]
namespace MaiaMixer.Config
{
    public const string GETTEXT_PACKAGE;
    public const string PACKAGE_CONFIG_FILE;
    public const string PACKAGE_LOCALE_DIR;
    public const string PACKAGE_SRC_DIR;
    public const string PACKAGE_DATA_DIR;
    public const string PACKAGE_NAME;
    public const string PACKAGE_VERSION;
    public const string VERSION;
    [CCode (cprefix = "MAIA_MIXER_")]
    public const string UI_PATH;
    [CCode (cprefix = "MAIA_MIXER_")]
    public const string BACKEND_PATH;
}
