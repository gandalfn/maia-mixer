/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * buffer.vala
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

public class MaiaMixer.Jack.Buffer : MaiaMixer.Core.Buffer
{
    // properties
    private global::Jack.Ringbuffer m_Buffer;
    private uint32                  m_BufferSize;

    // accesors
    [CCode (notify = false)]
    public override uint32 size {
        get {
            return m_BufferSize;
        }
        construct set {
            if (m_BufferSize != value && value > 0)
            {
                m_BufferSize = value;
                m_Buffer = new global::Jack.Ringbuffer (m_BufferSize * sizeof (float));
            }
        }
    }

    public override size_t read_available {
        get {
            size_t available = m_Buffer.read_space () / sizeof (float);
            return available;
        }
    }

    public override size_t write_available {
        get {
            size_t available = m_Buffer.write_space () / sizeof (float);
            return available;
        }
    }

    // methods
    public Buffer (uint32 inBufferSize)
        requires (inBufferSize > 0)
    {
        GLib.Object (size: inBufferSize);
    }

    public override size_t
    pop (ref unowned float[] outData)
        requires (outData.length > 0)
    {
        unowned uint8[] data = (uint8[])outData;
        data.length = (int)(outData.length * sizeof (float));
        return m_Buffer.read (data) / sizeof (float);
    }

    public override size_t
    peek (ref unowned float[] outData)
        requires (outData.length > 0)
    {
        unowned uint8[] data = (uint8[])outData;
        data.length = (int)(outData.length * sizeof (float));
        return m_Buffer.peek (data) / sizeof (float);
    }

    public override size_t
    push (float[] inData)
        requires (inData.length > 0)
    {
        unowned uint8[] data = (uint8[])inData;
        data.length = (int)(inData.length * sizeof (float));
        return m_Buffer.write (data);
    }

    public override void
    skip (size_t inSize)
    {
        m_Buffer.read_advance (inSize * sizeof (float));
    }

    public override void
    clear ()
    {
        m_Buffer.reset ();
    }
}
