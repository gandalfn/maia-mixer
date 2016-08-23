/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * sample.vala
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

public class MaiaMixer.Audio.Sample : GLib.Object
{
    // properties
    private void* m_Data = null;
    private uint m_Channels = 0;

    // accessors
    [CCode (notify = false)]
    public uint length { get; construct; default = 0; }

    [CCode (notify = false)]
    public uint channels {
        get {
            return m_Channels;
        }
        construct {
            m_Channels = value;
        }
        default = 0;
    }

    [CCode (notify = false)]
    public uint sample_rate { get; construct; default = 44100; }

    public unowned float[,] data {
        get {
            unowned float[,]data = (float[,])m_Data;
            data.length[0] = (int)channels;
            data.length[1] = (int)length;
            return data;
        }
    }

    // methods
    public Sample (uint inChannels, uint inLength, uint inSampleRate)
    {
        GLib.Object (channels: inChannels, length: inLength, sample_rate: inSampleRate);

        m_Data = GLib.Slice.alloc0 (inChannels * inLength * sizeof (float));
    }

    ~Sample ()
    {
        GLib.Slice.free (sizeof (float) * channels * length, m_Data);
    }

    public new virtual float
    @get (uint inChannel, uint inPos)
        requires (inChannel < channels)
        requires (inPos < length)
    {
        return data [inChannel, inPos];
    }

    public new virtual void
    @set (uint inChannel, uint inPos, float inValue)
        requires (inChannel < channels)
        requires (inPos < length)
    {
        data[inChannel, inPos] = inValue;
    }

    public virtual unowned float[]
    get_channel_data (uint inChannel)
        requires (inChannel < channels)
    {
        unowned float[] buffer = (float[])((float*)data + (inChannel * length));
        buffer.length = (int)length;
        return buffer;
    }

    public virtual void
    add_channel (float[] inData)
        requires (inData.length == length)
    {
        // Keep old data
        void* old = m_Data;
        uint oldChannels = m_Channels;

        // New channel
        m_Channels++;

        // Allocate data
        m_Data = GLib.Slice.alloc0 (m_Channels * length * sizeof (float));

        // Copy old data under the new one
        if (oldChannels > 0)
        {
            GLib.Memory.copy (m_Data, old, oldChannels * length * sizeof (float));
            GLib.Slice.free (sizeof (float) * oldChannels * length, m_Data);
        }

        // Copy new channel data
        GLib.Memory.copy ((float*)m_Data + (oldChannels * length), (float*)inData,  length * sizeof (float));
    }
}
