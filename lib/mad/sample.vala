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

public class MaiaMixer.Mad.Sample : MaiaMixer.Audio.Sample
{
    // methods
    public Sample (global::Mad.Synth inSynth)
    {
        base (inSynth.pcm.channels, inSynth.pcm.length, inSynth.pcm.samplerate);

        for (int channel = 0; channel < int.min (2, inSynth.pcm.channels); ++channel)
        {
            for (int cpt = 0; cpt < inSynth.pcm.length; ++cpt)
            {
                this[channel, cpt] = (float)inSynth.pcm[channel, cpt].to_double ();
            }
        }
    }

    public static global::Mad.Fixed[]
    get_channel_data_fixed (Audio.Sample inSample, uint inChannel)
        requires (inChannel < inSample.channels)
    {
        global::Mad.Fixed[] samples = (global::Mad.Fixed[])new int[(int)inSample.length];

        for (int cpt = 0; cpt < inSample.length; ++cpt)
        {
            samples[cpt] = global::Mad.Fixed ((double)inSample[inChannel, cpt]);
        }

        return samples;
    }

    public static void
    set_channel_data_fixed (Audio.Sample inSample, uint inChannel, global::Mad.Fixed[] inData)
        requires (inChannel < inSample.channels)
        requires (inData.length <= inSample.length)
    {
        for (int cpt = 0; cpt < inData.length; ++cpt)
        {
            inSample[inChannel, cpt] = (float)inData[cpt].to_double ();
        }
    }

    public static void
    set_channel_data_fixed_invert (Audio.Sample inSample, uint inChannel, global::Mad.Fixed[] inData)
        requires (inChannel < inSample.channels)
        requires (inData.length <= inSample.length)
    {
        for (int cpt = 0; cpt < inData.length; ++cpt)
        {
            int index = inData.length - 1 - cpt;
            inSample[inChannel, cpt] = (float)inData[index].to_double ();
        }
    }
}
