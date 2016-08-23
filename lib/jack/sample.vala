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

public class MaiaMixer.Jack.Sample : MaiaMixer.Audio.Sample
{
    // types
    private class ChannelData
    {
        public float[] data;

        public ChannelData (float[] inData)
        {
            data = inData;
        }
    }

    // properties
    private uint          m_Length;
    private uint          m_Channels;
    private uint          m_SampleRate;
    private ChannelData[] m_Data;

    // accessors
    internal override uint length {
        get {
            return m_Length;
        }
    }

    internal override uint channels {
        get {
            return m_Channels;
        }
    }

    internal override uint sample_rate {
        get {
            return m_SampleRate;
        }
    }

    // methods
    public Sample (uint inLength, uint inSampleRate)
    {
        m_Length = inLength;
        m_Channels = 0;
        m_SampleRate = inSampleRate;
    }

    internal override float
    @get (uint inChannel, uint inPos)
        requires (inChannel < m_Channels)
        requires (inPos < m_Length)
    {
        return m_Data[inChannel].data[inPos];
    }

    internal override void
    @set (uint inChannel, uint inPos, float inValue)
        requires (inChannel < m_Channels)
        requires (inPos < m_Length)
    {
        m_Data[inChannel].data[inPos] = inValue;
    }

    internal override float[]
    get_buffer (uint inChannel)
        requires (inChannel < m_Channels)
    {
        return m_Data[inChannel].data;
    }

    public void
    add_channel (float[] inData)
        requires (inData.length == m_Length)
    {
        int channel = (int)m_Channels;
        m_Channels++;
        m_Data.resize ((int)m_Channels);
        m_Data[channel] = new ChannelData (inData);
    }
}
