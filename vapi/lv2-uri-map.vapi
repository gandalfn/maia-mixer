[CCode (cheader_filename = "lv2/lv2plug.in/ns/ext/uri-map/uri-map.h")]
namespace LV2.URIMap {
    [CCode (cname = "LV2_URI_MAP_URI")]
    public const string URI;

    [CCode (has_target = false)]
    public delegate uint32 Callback(Handle callback_data, string map, string uri);

    [CCode (cname="LV2_URI_Map_Feature", cheader_filename="lv2/lv2plug.in/ns/ext/uri-map/uri-map.h", has_destroy_function=false, has_copy_function=false)]
    public struct Feature {
        unowned Handle callback_data;
        Callback uri_to_id;
    }
}
