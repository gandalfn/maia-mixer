/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * init.vala
 * Copyright (C) Nicolas Bruguier 2010-2013 <gandalfn@club-internet.fr>
 *
 * maia is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * maia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace MaiaMixer.LV2
{
    // types
    public class Engine : GLib.Object
    {
        // properties
        private global::Lilv.World           m_World;
        private unowned global::Lilv.Plugins m_Plugins;
        private global::Lilv.Node            m_InputClass;
        private global::Lilv.Node            m_OutputClass;
        private global::Lilv.Node            m_ControlClass;
        private global::Lilv.Node            m_AudioClass;
        private global::Lilv.Node            m_EventClass;
        private global::Lilv.Node            m_MidiClass;
        private global::Lilv.Node            m_Optional;

        // accessors
        public global::Lilv.Node input_class {
            get {
                return m_InputClass;
            }
        }

        public global::Lilv.Node output_class {
            get {
                return m_OutputClass;
            }
        }

        public global::Lilv.Node control_class {
            get {
                return m_ControlClass;
            }
        }

        public global::Lilv.Node audio_class {
            get {
                return m_AudioClass;
            }
        }

        public global::Lilv.Node event_class {
            get {
                return m_EventClass;
            }
        }

        public global::Lilv.Node midi_class {
            get {
                return m_MidiClass;
            }
        }

        public global::Lilv.Node optional {
            get {
                return m_Optional;
            }
        }

        // methods
        public Engine ()
        {
            // Get all LV2 plugins available
            m_World = new Lilv.World();
            m_World.load_all();
            m_Plugins = m_World.get_all_plugins();

            // Create class nodes
            m_InputClass   = new global::Lilv.Node.uri(m_World, global::Lilv.URI.INPUT_PORT);
            m_OutputClass  = new global::Lilv.Node.uri(m_World, global::Lilv.URI.OUTPUT_PORT);
            m_ControlClass = new global::Lilv.Node.uri(m_World, global::Lilv.URI.CONTROL_PORT);
            m_AudioClass   = new global::Lilv.Node.uri(m_World, global::Lilv.URI.AUDIO_PORT);
            m_EventClass   = new global::Lilv.Node.uri(m_World, global::Lilv.URI.EVENT_PORT);
            m_MidiClass    = new global::Lilv.Node.uri(m_World, global::Lilv.URI.MIDI_EVENT);
            m_Optional     = new global::Lilv.Node.uri(m_World, global::Lilv.NS.LV2 + "connectionOptional");
        }

        public unowned global::Lilv.Plugin?
        load_plugin (string inUri)
        {
            global::Lilv.Node plugin_uri = new global::Lilv.Node.uri(m_World, inUri);
            return m_Plugins.get_by_uri(plugin_uri);
        }
    }

    // static properties
    private static Engine s_Engine;

    // static methods
    internal static unowned Engine?
    engine ()
    {
        return s_Engine;
    }

    internal static uint32
    uri_to_id (global::LV2.Handle? inData, string? inMap, string inUri)
    {
        return GLib.Quark.from_string (inUri);
    }

    internal static uint32
    urid_to_id (global::LV2.Handle? inData, string inUri)
    {
        return GLib.Quark.from_string (inUri);
    }

    internal static unowned string
    id_to_urid (global::LV2.Handle? inData, uint32 inId)
    {
        unowned string ret = ((GLib.Quark)inId).to_string ();

        return ret;
    }

    [CCode (cname = "backend_load")]
    public void backend_load ()
    {
        s_Engine = new Engine ();

        Maia.Core.Any.delegate (typeof (MaiaMixer.Filters.ThreeBandEq), typeof (MaiaMixer.LV2.ThreeBandEq));
    }

    [CCode (cname = "backend_unload")]
    public void backend_unload ()
    {
        Maia.Core.Any.undelegate (typeof (MaiaMixer.Filters.ThreeBandEq));

        s_Engine = null;
    }
}
