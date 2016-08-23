/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * speed.vala
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
 *
 * This linear resampling algorithm has been borrowed from:
 *
 * madplay - MPEG audio decoder and player
 * Copyright (C) 2000-2004 Robert Leslie
 */

public class MaiaMixer.Soundtouch.Speed : MaiaMixer.Filters.Speed
{
    // properties
    private global::soundtouch.SoundTouch m_Left;
    private global::soundtouch.SoundTouch m_Right;
    private double m_Ratio = 1.0;

    // accessors
    [CCode (notify = false)]
    public override double ratio {
        get {
            return m_Ratio;
        }
        construct set {
            if (m_Ratio != value)
            {
                m_Ratio = value;

                if (m_Left != null)
                {
                    m_Left.rate = m_Ratio;
                }
                if (m_Right != null)
                {
                    m_Right.rate = m_Ratio;
                }
            }
        }
    }

    // methods
    public Speed (uint inSampleRate, double inRatio)
    {
        base (inSampleRate, inRatio);
    }

    internal override void
    delegate_construct ()
    {
        m_Left = new global::soundtouch.SoundTouch ();
        m_Left.sample_rate = sample_rate;
        m_Left.channels = 1;

        m_Right = new global::soundtouch.SoundTouch ();
        m_Right.sample_rate = sample_rate;
        m_Right.channels = 1;
    }

    internal override Audio.Sample?
    process (Audio.Sample inSample)
    {
        Audio.Sample? sample = inSample;
        uint channels = inSample.channels;
        uint length = inSample.length;

        if (m_Ratio != 1.0 && channels > 0 && length > 0)
        {
            m_Left.put_samples (sample.get_channel_data (0));
            if (channels > 1)
            {
                m_Right.put_samples (sample.get_channel_data (1));
            }

            if (m_Left.num_samples > 0)
            {
                sample = new Audio.Sample (channels, m_Left.num_samples, sample_rate);

                m_Left.receive_samples (sample.get_channel_data (0));

                if (channels > 1 && m_Right.num_samples > 0)
                {
                    m_Right.receive_samples (sample.get_channel_data (1));
                }
            }
        }

        return sample;
    }
}
