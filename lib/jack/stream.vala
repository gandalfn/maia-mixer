/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * stream.vala
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

public class MaiaMixer.Jack.Stream : MaiaMixer.Core.Stream
{
    // properties
    private global::Jack.Ringbuffer m_Buffer;
    private uint32                  m_BufferSize;

    // accesors
    [CCode (notify = false)]
    public override uint32 buffer_size {
        get {
            return m_BufferSize;
        }
        construct set {
            if (m_BufferSize != value && value > 0)
            {
                m_BufferSize = value;
                m_Buffer = new global::Jack.Ringbuffer (sizeof (float) * m_BufferSize);
            }
        }
    }

    public override size_t read_available {
        get {
            size_t available = m_Buffer.read_space ();
            return available / sizeof (float);
        }
    }

    public override size_t write_available {
        get {
            size_t available = m_Buffer.write_space ();
            return available / sizeof (float);
        }
    }

    // methods
    public Stream (uint32 inBufferSize = 4096 * 32)
        requires (inBufferSize > 0)
    {
        GLib.Object (buffer_size: inBufferSize);
    }

    public override size_t
    pop (ref unowned float[] outData)
        requires (outData.length > 0)
    {
        unowned uint8[] data = (uint8[])(outData);
        data.length = (int)(sizeof (float) * int.min (outData.length, (int)m_BufferSize));
        return m_Buffer.read (data) / sizeof (float);
    }

    public override size_t
    peek (ref unowned float[] outData)
        requires (outData.length > 0)
    {
        unowned uint8[] data = (uint8[])(outData);
        data.length = (int)(sizeof (float) * int.min (outData.length, (int)m_BufferSize));
        return m_Buffer.peek (data) / sizeof (float);
    }

    public override size_t
    push (float[] inData)
        requires (inData.length > 0)
    {
        unowned uint8[] data = (uint8[])(inData);
        data.length = (int)(sizeof (float) * int.min (inData.length, (int)m_BufferSize));
        return m_Buffer.write (data) / sizeof (float);
    }

    public override void
    flush ()
    {
        m_Buffer.reset ();
    }
}
