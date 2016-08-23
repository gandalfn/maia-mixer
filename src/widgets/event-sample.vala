/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * event-sample.vala
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

public class MaiaMixer.Widget.EventSample : Maia.Core.Object, MaiaMixer.Core.Element
{
    // types
    public class EventArgs : Maia.Core.EventArgs
    {
        // properties
        private int     m_Channel;
        private int     m_Length;
        private uchar[] m_Data;

        // accessors
        [CCode (notify = false)]
        internal override GLib.Variant serialize {
            owned get {
                unowned GLib.Variant data = GLib.VariantFixed.new<uchar> (new GLib.VariantType("y"), m_Data, sizeof (uchar));
                return new GLib.Variant ("(iiv)", m_Channel, m_Length, data);
            }
            set {
                GLib.VariantFixed data;
                value.get ("(iiv)", out m_Channel, out m_Length, out data);
                m_Data = data.get<uchar> (sizeof (uchar));
            }
        }

        public int channel {
            get {
                return m_Channel;
            }
        }

        public int length {
            get {
                return m_Length;
            }
        }

        public float[] data {
            get {
                unowned float[] ret = (float[])m_Data;
                ret.length = m_Length;
                return ret;
            }
        }

        // methods
        public EventArgs (int inChannel, Audio.Sample inSample)
        {
            m_Channel = inChannel;
            m_Length = (int)inSample.length;
            m_Data = (uint8[])inSample.get_channel_data (m_Channel);
        }
    }

    // properties
    private Maia.Core.Event m_Event;
    private uint m_Channel;

    // accessors
    public Maia.Core.Event sample_event {
        get {
            return m_Event;
        }
    }

    // methods
    construct
    {
        m_Event = new Maia.Core.Event ("sample-event", this);
    }

    public EventSample (string inName, uint inChannel)
    {
        GLib.Object (id: GLib.Quark.from_string (inName));
        m_Channel = inChannel;
    }

    public Audio.Sample?
    process (Audio.Sample inSample)
    {
        if (inSample != null && inSample.channels > m_Channel)
        {
            m_Event.publish (new EventArgs ((int)m_Channel, inSample));
        }

        return inSample;
    }
}
