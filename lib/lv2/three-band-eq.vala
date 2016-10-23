/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * three-band-eq.vala
 * Copyright (C) Nicolas Bruguier 2016 <gandalfn@club-internet.fr>
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

public class MaiaMixer.LV2.ThreeBandEq : MaiaMixer.Filters.ThreeBandEq
{
    // properties
    private unowned global::Lilv.Plugin? m_Plugin;
    private global::Lilv.Instance        m_Instance;
    private double                       m_FrameRate;
    private int                          m_NSamples;
    private float                        m_Master;
    private float                        m_Low;
    private float                        m_Med;
    private float                        m_High;
    private int                          m_Input[2];
    private int                          m_Output[2];
    private bool                         m_Bypass;

    // accessors
    [CCode (notify = false)]
    internal override double master {
        get {
            return m_Master;
        }
        set {
            m_Master = (float)value;
        }
    }

    [CCode (notify = false)]
    internal override double low {
        get {
            return m_Low;
        }
        set {
            m_Low = (float)value;
        }
    }

    [CCode (notify = false)]
    internal override double med {
        get {
            return m_Med;
        }
        set {
            m_Med = (float)value;
        }
    }

    [CCode (notify = false)]
    internal override double high {
        get {
            return m_High;
        }
        set {
            m_High = (float)value;
        }
    }

    // methods
    public ThreeBandEq (uint inSampleRate, uint inNSamples)
    {
        base (inSampleRate, inNSamples);
    }

    ~ThreeBandEq ()
    {
        m_Instance.deactivate ();
    }

    internal override void
    delegate_construct ()
    {
        m_Bypass = false;

        // Get frame rate to share with lv2 plugin
        m_FrameRate = (double)sample_rate;

        // Get n samples to share with lv2 plugin
        m_NSamples = (int)n_samples;

        // Get lv2 plugin
        m_Plugin = LV2.engine().load_plugin ("http://distrho.sf.net/plugins/3BandEQ");
        if (m_Plugin != null)
        {
            // Create instance of plugin
            global::LV2.URIMap.Feature uriMap = { null, LV2.uri_to_id };
            global::LV2.URID.Map       map    = { null, LV2.urid_to_id };
            global::LV2.URID.Unmap     unmap  = { null, LV2.id_to_urid };
            global::LV2.Options.Option options[2];
            options[0] = {
                            global::LV2.Options.Context.INSTANCE,
                            0,
                            GLib.Quark.from_string (global::LV2.BufSize.nominalBlockLength),
                            (uint32)sizeof (int),
                            GLib.Quark.from_string (global::LV2.Atom.INT),
                            &m_NSamples
                         };
            options[1] = {
                            (global::LV2.Options.Context)0,
                            0,
                            0,
                            0,
                            0,
                            null
                         };

            global::LV2.Feature uriMapFeature    = { global::LV2.URIMap.URI,      &uriMap };
            global::LV2.Feature uridMapFeature   = { global::LV2.URID.MAP,        &map };
            global::LV2.Feature uridUnmapFeature = { global::LV2.URID.UNMAP,      &unmap};
            global::LV2.Feature optionsFeature   = { global::LV2.Options.OPTIONS, options};

            m_Instance = m_Plugin.instantiate(sample_rate, { &uriMapFeature, &uridMapFeature, &uridUnmapFeature, &optionsFeature, null });

            // Parse ports
            for (int index = 0; index < m_Plugin.get_num_ports (); ++index)
            {
                unowned global::Lilv.Port port = m_Plugin.get_port_by_index (index);
                unowned global::Lilv.Node symbol = m_Plugin.port_get_symbol (port);
                string symbolName = symbol.as_string();

                // Get input and output audio ports
                if (m_Plugin.port_is_a (port, engine ().input_class) && m_Plugin.port_is_a (port, engine ().audio_class))
                {
                    if (symbolName == "lv2_audio_in_1")
                    {
                        m_Input[0] = index;
                    }
                    else if (symbolName == "lv2_audio_in_2")
                    {
                        m_Input[1] = index;
                    }
                }
                else if (m_Plugin.port_is_a (port, engine ().output_class) && m_Plugin.port_is_a (port, engine ().audio_class))
                {
                    if (symbolName == "lv2_audio_out_1")
                    {
                        m_Output[0] = index;
                    }
                    else if (symbolName == "lv2_audio_out_2")
                    {
                        m_Output[1] = index;
                    }
                }

                // Get control ports
                if (m_Plugin.port_is_a (port, engine ().control_class))
                {
                    global::Lilv.Node def;
                    m_Plugin.port_get_range (port, out def, null, null);

                    if (symbolName == "low")
                    {
                        m_Low = def.as_float();
                        m_Instance.connect_port (index, &(m_Low));
                    }
                    else if (symbolName == "med")
                    {
                        m_Med = def.as_float();
                        m_Instance.connect_port (index, &(m_Med));
                    }
                    else if (symbolName == "high")
                    {
                        m_High = def.as_float();
                        m_Instance.connect_port (index, &(m_High));
                    }
                    else if (symbolName == "master")
                    {
                        m_Master = def.as_float();
                        m_Instance.connect_port (index, &(m_Master));
                    }
                }
            }

            // Activate instance
            m_Instance.activate ();
        }
    }

    internal override Audio.Sample?
    process (Audio.Sample inSample)
    {
        Audio.Sample? sample = inSample;

        if (inSample.channels == 2)
        {
            sample = new Audio.Sample (inSample.channels, inSample.length, sample_rate);

            // Connect input port
            m_Instance.connect_port (m_Input[0], inSample.get_channel_data (0));
            m_Instance.connect_port (m_Input[1], inSample.get_channel_data (1));

            // Connect output port
            m_Instance.connect_port (m_Output[0], sample.get_channel_data (0));
            m_Instance.connect_port (m_Output[1], sample.get_channel_data (1));

            // run plugin
            m_Instance.run (inSample.length);
        }

        return sample;
    }
}
