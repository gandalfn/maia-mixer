/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * channel.vala
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

public class MaiaMixer.Jack.Channel : Audio.Channel
{
    // properties
    private unowned global::Jack.Port? m_Port = null;
    private Audio.Channel.Flags        m_Flags;
    private Core.Buffer                m_Buffer;

    // accessors
    [CCode (notify = false)]
    public override uint32 buffer_size {
        get {
            return m_Buffer.size;
        }
        construct set {
            uint32 size = (uint32)int.max(1024, (int)value);

            if (m_Buffer == null)
            {
                m_Buffer = new Core.Buffer (size);
            }
            else
            {
                m_Buffer.size = size;
            }
        }
    }

    [CCode (notify = false)]
    public override Audio.Channel.Flags flags {
        get {
            return m_Flags;
        }
        construct set {
            m_Flags = value;
        }
    }

    [CCode (notify = false)]
    public unowned global::Jack.Port? port {
        get {
            return m_Port;
        }
        set {
            if (m_Port != value)
            {
                m_Port = value;

                m_Flags = flags_from_jack_flags (m_Port != null ? m_Port.flags : (global::Jack.Port.Flags)0);
            }
        }
    }

    public size_t buffered_data_available {
        get {
            return m_Buffer.read_available;
        }
    }

    // static methods
    public static Audio.Channel.Flags
    flags_from_jack_flags (global::Jack.Port.Flags inFlags)
    {
        Audio.Channel.Flags ret = Audio.Channel.Flags.NONE;
        if (global::Jack.Port.Flags.IsInput in inFlags)
        {
            ret |= Audio.Channel.Flags.INPUT;
        }
        if (global::Jack.Port.Flags.IsOutput in inFlags)
        {
            ret |= Audio.Channel.Flags.OUTPUT;
        }
        if (global::Jack.Port.Flags.IsPhysical in inFlags)
        {
            ret |= Audio.Channel.Flags.PHYSICAL;
        }
        return ret;
    }

    // methods
    public Channel (global::Jack.Port inPort)
    {
        GLib.Object (id: GLib.Quark.from_string (inPort.short_name), port: inPort);
    }

    public void
    push (float[] inData)
    {
        m_Buffer.push (inData);
    }

    public unowned float[]
    read (uint inNFrames)
    {
        void* buffer = port.get_buffer (inNFrames);
        unowned float[] data = (float[])buffer;
        data.length = (int)inNFrames;

        return data;
    }

    public void
    write (uint inNFrames)
    {
        if ((int)m_Buffer.read_available >= inNFrames)
        {
            void* buffer = port.get_buffer (inNFrames);
            unowned float[] data = (float[])buffer;
            data.length = (int)inNFrames;

            m_Buffer.pop (ref data);
        }
    }
}
