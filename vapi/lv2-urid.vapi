[CCode (cheader_filename = "lv2/lv2plug.in/ns/ext/urid/urid.h")]
namespace LV2.URID {
    [CCode (cname = "LV2_URID_URI")]
    public const string URI;

    [CCode (has_target = false)]
    public delegate uint32 MapCallback(Handle handle, string uri);

    [CCode (cname = "LV2_URID__map")]
    public const string MAP;

    [CCode (cname="LV2_URID_Map", has_destroy_function=false, has_copy_function=false)]
    public struct Map {
        unowned Handle handle;
        MapCallback map;
    }

    [CCode (has_target = false)]
    public delegate unowned string UnmapCallback(Handle handle, uint32 id);

    [CCode (cname = "LV2_URID__unmap")]
    public const string UNMAP;

    [CCode (cname="LV2_URID_Unmap", has_destroy_function=false, has_copy_function=false)]
    public struct Unmap {
        unowned Handle handle;
        UnmapCallback unmap;
    }
}
