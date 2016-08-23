/*
  Copyright 2007-2011 David Robillard <http://drobilla.net>
  Copyright 2011 Artem Popov <artfwo@gmail.com>

  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted, provided that the above
  copyright notice and this permission notice appear in all copies.

  THIS SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

// vala port of lv2jack.c

[CCode(cheader_filename="lilv/lilv.h", cprefix="Lilv", lower_case_cprefix="lilv_")]
namespace Lilv {

    [CCode (cname = "LilvUISupportedFunc", has_target = false)]
    public delegate uint UISupportedFunc (string container_type_uri, string ui_type_uri);

    [CCode (cprefix = "LILV")]
    namespace NS {
        public const string DOAP;
        public const string FOAF;
        public const string LILV;
        public const string LV2;
        public const string RDF;
        public const string RDFS;
        public const string XSD;
    }

    [CCode (cprefix = "LILV")]
    namespace URI {
        public const string AUDIO_PORT;
        public const string CONTROL_PORT;
        public const string EVENT_PORT;
        public const string INPUT_PORT;
        public const string MIDI_EVENT;
        public const string OUTPUT_PORT;
        public const string PORT;
    }

    [CCode (cprefix = "LILV")]
    namespace OPTION {
        public const string FILTER_LANG;
        public const string DYN_MANIFEST;
    }

    public static unowned string uri_to_path(string uri);

    [Compact]
    [Immutable]
    [CCode (free_function = "")]
    public class Plugin {
        public bool verify();
        public unowned Node get_uri();
        public unowned Node get_bundle_uri();
        public unowned Nodes get_data_uris();
        public unowned Node get_library_uri();
        public Node get_name();
        public unowned PluginClass get_class();
        public Nodes get_value(Node predicate);
        public bool has_feature(Node feature_uri);
        public Nodes get_supported_features();
        public Nodes get_required_features();
        public Nodes get_optional_features();
        public uint32 get_num_ports();
        public void get_port_ranges_float(ref float[] min_values, ref float[] max_values, ref float[] def_values);
        public uint32 get_num_ports_of_class(Node class_1, ...);
        public bool has_latency();
        public uint32 get_latency_port_index();
        public unowned Port get_port_by_index(uint32 index);
        public unowned Port get_port_by_symbol(Node symbol);
        public Node? get_author_name();
        public Node? get_author_email();
        public Node? get_author_homepage();
        public bool is_replaced();

        public Instance? instantiate(double sample_rate,
            [CCode (array_length = false, array_null_terminated = true)] LV2.Feature*[] features);
        public UIs get_uis();

        // port methods
        [CCode (cname = "lilv_port_get_value")]
        public Nodes port_get_value(Port port, Node predicate);
        [CCode (cname = "lilv_port_get_properties")]
        public Nodes port_get_properties(Port port);
        [CCode (cname = "lilv_port_has_property")]
        public bool port_has_property(Port port, Node property_uri);
        [CCode (cname = "lilv_port_supports_event")]
        public bool port_supports_event(Port port, Node event_uri);
        [CCode (cname = "lilv_port_get_symbol")]
        public unowned Node port_get_symbol(Port port);
        [CCode (cname = "lilv_port_get_name")]
        public Node port_get_name(Port port);
        [CCode (cname = "lilv_port_get_classes")]
        public unowned Nodes port_get_classes(Port port);
        [CCode (cname = "lilv_port_is_a")]
        public bool port_is_a(Port port, Node port_class);
        [CCode (cname = "lilv_port_get_range")]
        public void port_get_range(Port port, out Node deflt, out Node min, out Node max);
        [CCode (cname = "lilv_port_get_scale_points")]
        public ScalePoints port_get_scale_points(Port port);
    }

    [Compact]
    [CCode (free_function = "")]
    public class PluginClass {
        public unowned Node get_parent_uri();
        public unowned Node get_uri();
        public unowned Node get_label();
        public PluginClasses get_children();
    }

    [Compact]
    [Immutable]
    [CCode (free_function = "")]
    public class Port {
    }

    [Compact]
    [Immutable]
    [CCode (free_function = "")]
    public class ScalePoint {
        public unowned Node get_label();
        public unowned Node get_value();
    }

    [Compact]
    [Immutable]
    [CCode (free_function = "")]
    public class UI {
        public unowned Node get_uri();
        public unowned Nodes get_classes();
        public bool is_a(Node class_uri);
        public uint is_supported(UISupportedFunc supported_func, Node container_type, out Node ui_type);
        public unowned Node get_bundle_uri();
        public unowned Node get_binary_uri();
    }

    [Compact]
    [CCode (free_function = "lilv_node_free")]
    public class Node {
        [CCode(cname="lilv_new_uri")]
        public Node.uri(World world, string uri);
        [CCode(cname="lilv_new_string")]
        public Node.string(World world, string str);
        [CCode(cname="lilv_new_int")]
        public Node.int(World world, int val);
        [CCode(cname="lilv_new_float")]
        public Node.float(World world, float val);
        [CCode(cname="lilv_new_bool")]
        public Node.bool(World world, bool val);

        public Node duplicate();
        public bool equals(Node other);
        public string get_turtle_token();

        public bool is_uri();
        public unowned string as_uri();
        public bool is_blank();
        public unowned string as_blank();
        public bool is_literal();
        public bool is_string();
        public unowned string as_string();
        public bool is_float();
        public float as_float();
        public bool is_int();
        public int as_int();
        public bool is_bool();
        public bool as_bool();
    }

    [Compact]
    [CCode (free_function = "lilv_world_free")]
    public class World {
        public World();
        public void set_option(string uri, Node value);
        public void load_all();
        public void load_bundle(Node bundle_uri);
        public unowned PluginClass get_plugin_class();
        public unowned PluginClasses get_plugin_classes();
        public unowned Plugins get_all_plugins();
        public Nodes find_nodes(Node subject, Node predicate, Node object);
    }

    [Compact]
    [CCode (free_function = "lilv_instance_free")]
    public class Instance {
        public unowned string get_uri();
        public void connect_port(uint32 port_index, void* data_location);
        public void activate();
        public void run(uint32 sample_count);
        public void deactivate();
        public void* get_extension_data(string uri);
        public unowned LV2.Descriptor get_descriptor();
        public unowned LV2.Handle get_handle();
    }

    // Collections

    [Compact]
    [Immutable]
    [CCode (free_function = "")]
    public class Iter {
    }

    [Compact]
    [CCode (free_function = "lilv_plugin_classes_free")]
    public class PluginClasses {
        public uint size();
        public Iter begin();
        public unowned PluginClass? get(Iter i);
        public Iter next(Iter i);
        public bool is_end(Iter i);
        public unowned PluginClass? get_by_uri(Node uri);
    }

    [Compact]
    [Immutable]
    [CCode (free_function = "")]
    public class Plugins {
        public uint size();
        public Iter begin();
        public unowned Plugin? get(Iter i);
        public Iter next(Iter i);
        public bool is_end(Iter i);
        public unowned Plugin? get_by_uri(Node uri);
    }

    [Compact]
    [CCode (free_function = "lilv_scale_points_free")]
    public class ScalePoints {
        public uint size();
        public Iter begin();
        public unowned ScalePoint? get(Iter i);
        public Iter next(Iter i);
        public bool is_end(Iter i);
    }

    [Compact]
    [CCode (free_function = "lilv_uis_free")]
    public class UIs {
        public uint size();
        public Iter begin();
        public unowned UI? get(Iter i);
        public Iter next(Iter i);
        public bool is_end(Iter i);
        public unowned UI? get_by_uri(Node uri);
    }

    [Compact]
    [CCode (free_function = "lilv_nodes_free")]
    public class Nodes {
        public uint size();
        public Iter begin();
        public unowned Node? get(Iter i);
        public Iter next(Iter i);
        public bool is_end(Iter i);
        public Node? get_first(); // unowned?
        public bool contains(Node value);
    }
}
