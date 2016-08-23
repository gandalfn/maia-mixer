[CCode (cheader_filename = "lv2/lv2plug.in/ns/ext/buf-size/buf-size.h")]
namespace LV2.BufSize {
    [CCode (cname = "LV2_BUF_SIZE_URI")]
    public const string URI;

    [CCode (cname = "LV2_BUF_SIZE__boundedBlockLength")]
    public const string boundedBlockLength;
    [CCode (cname = "LV2_BUF_SIZE__fixedBlockLength")]
    public const string fixedBlockLength;
    [CCode (cname = "LV2_BUF_SIZE__maxBlockLength")]
    public const string maxBlockLength;
    [CCode (cname = "LV2_BUF_SIZE__minBlockLength")]
    public const string minBlockLength;
    [CCode (cname = "LV2_BUF_SIZE__nominalBlockLength")]
    public const string nominalBlockLength;
    [CCode (cname = "LV2_BUF_SIZE__powerOf2BlockLength")]
    public const string powerOf2BlockLength;
    [CCode (cname = "LV2_BUF_SIZE__sequenceSize")]
    public const string sequenceSize;
}
