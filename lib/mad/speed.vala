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

public class MaiaMixer.Mad.Speed : MaiaMixer.Filters.Speed
{
    // properties
    private global::Mad.Fixed m_Ratio;
    private global::Mad.Fixed m_Step[2];
    private global::Mad.Fixed m_Last[2];

    // methods
    public Speed (double inRatio)
    {
        GLib.Object (ratio: inRatio);
    }

    private int
    convert (MaiaMixer.Audio.Sample inSample, global::Mad.Fixed* outOutput)
    {
        if (ratio == 0 || inSample.sample_rate == 0)
        {
            return 0;
        }

        // Calculate ratio
        m_Ratio = global::Mad.Fixed (GLib.Math.fabs (ratio));
        if (m_Ratio == 0)
        {
            return 0;
        }

        // Create sample output
        global::Mad.Fixed* output = outOutput;
        int length = 0;

        for (int channel = 0; channel < int.min (2, (int)inSample.channels); ++channel)
        {
            global::Mad.Fixed[] input = Sample.get_channel_data_fixed (inSample, channel);
            global::Mad.Fixed* old = (global::Mad.Fixed*)input;
            global::Mad.Fixed* news = output + (channel * inSample.length * 6);
            global::Mad.Fixed* begin = news;
            global::Mad.Fixed* end = old + input.length;

            if (m_Step[channel] < 0)
            {
                m_Step[channel] = -m_Step[channel].fracpart ();

                while (m_Step[channel] < global::Mad.Fixed.ONE)
                {
                    *news++ = m_Step[channel] != 0 ? m_Last[channel] + (*old - m_Last[channel]).mul (m_Step[channel]) : m_Last[channel];

                    m_Step[channel] += m_Ratio;
                    if (((m_Step[channel] + 0x00000080L) & 0x0fffff00L) == 0)
                    {
                        m_Step[channel] = (global::Mad.Fixed)((m_Step[channel] + 0x00000080L) & ~0x0fffffffL);
                    }
                }

                m_Step[channel] -= global::Mad.Fixed.ONE;
            }

            while (end - old > 1 + m_Step[channel].intpart ())
            {
                old            += m_Step[channel].intpart ();
                m_Step[channel] = m_Step[channel].fracpart();

                *news++ = m_Step[channel] != 0 ? *old + (old[1] - old[0]).mul(m_Step[channel]) : *old;

                m_Step[channel] += m_Ratio;
                if (((m_Step[channel] + 0x00000080L) & 0x0fffff00L) == 0)
                {
                    m_Step[channel] = (global::Mad.Fixed)((m_Step[channel] + 0x00000080L) & ~0x0fffffffL);
                }
            }

            if (end - old == 1 + m_Step[channel].intpart())
            {
                m_Last[channel] = end[-1];
                m_Step[channel] = -m_Step[channel];
            }
            else
            {
                m_Step[channel] -= global::Mad.Fixed((double)(end - old));
            }

            length = int.max ((int)(news - begin), length);
        }

        return length;
    }

    internal override Audio.Sample?
    process (Audio.Sample inSample)
    {
        Audio.Sample? ret = inSample;

        if (ratio != 1.0 && ratio != 0.0)
        {
            // Create sample output
            global::Mad.Fixed* output = GLib.Slice.alloc0 (sizeof (global::Mad.Fixed) * 2 * inSample.length * 6);
            int length = convert (inSample, output);

            if (length > 0)
            {
                ret = new Audio.Sample (inSample.channels, length, inSample.sample_rate);

                for (int channel = 0; channel < int.min (2, (int)inSample.channels); ++channel)
                {
                    unowned global::Mad.Fixed[] data = (global::Mad.Fixed[])(output + (channel * inSample.length * 6));
                    data.length = length;

                    if (ratio > 0.0)
                    {
                        Sample.set_channel_data_fixed (ret, channel, data);
                    }
                    else
                    {
                        Sample.set_channel_data_fixed_invert (ret, channel, data);
                    }
                }
            }
            GLib.Slice.free (sizeof (global::Mad.Fixed) * 2 * inSample.length * 6, output);
        }

        return ret;
    }
}
