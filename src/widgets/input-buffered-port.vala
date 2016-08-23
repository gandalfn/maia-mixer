/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * input-buffered-port.vala
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

public class MaiaMixer.Widget.InputBufferedPort : Maia.Core.Object
{
    // types
    public class EventArgs : Maia.Core.EventArgs
    {
        // properties
        private int m_NFrames;
        private uchar[] m_Data;

        // accessors
        [CCode (notify = false)]
        internal override GLib.Variant serialize {
            owned get {
                unowned GLib.Variant data = GLib.VariantFixed.new<uchar> (new GLib.VariantType("y"), m_Data, sizeof (uchar));
                return new GLib.Variant ("(iv)", m_NFrames, data);
            }
            set {
                GLib.VariantFixed data;
                value.get ("(iv)", out m_NFrames, out data);
                m_Data = data.get<uchar> (sizeof (uchar));
            }
        }

        public int nframes {
            get {
                return m_NFrames;
            }
        }

        public float[] data {
            get {
                unowned float[] ret = (float[])m_Data;
                ret.length = m_NFrames;
                return ret;
            }
        }

        // methods
        public EventArgs (int inNFrames, Core.InputPort inPort)
        {
            m_NFrames = inNFrames;
            m_Data = (uint8[])inPort.stream.read (inNFrames);
        }
    }

    // properties
    private Maia.Core.Event m_Event;
    private Core.InputPort  m_Port;

    // accessors
    public Maia.Core.Event data_event {
        get {
            return m_Event;
        }
    }

    // methods
    construct
    {
        m_Event = new Maia.Core.Event ("data-event", this);
    }

    public InputBufferedPort (Core.InputPort inPort)
    {
        m_Port = inPort;

        m_Port.new_frames.add_object_observer (on_new_frames);
    }

    private void
    on_new_frames (Maia.Core.Notification inNotification)
    {
        unowned Core.NewFramesNotification? notification = (Core.NewFramesNotification)inNotification;
        if (notification != null)
        {
            m_Event.publish (new EventArgs ((int)notification.n_frames, m_Port));
        }
    }
}
