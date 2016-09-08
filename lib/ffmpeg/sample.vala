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

public class MaiaMixer.FFMpeg.Sample : MaiaMixer.Audio.Sample
{
    // methods
    public Sample (Av.Util.Frame inFrame)
    {
        int size = inFrame.format.get_buffer_size (null, inFrame.channels, inFrame.nb_samples, false);
        unowned uint8[] leftData = (uint8[])inFrame.data[0];
        unowned uint8[] rightData = (uint8[])inFrame.data[inFrame.channels > 1 ? 1 : 0];

        int nbSamples = 0;
        switch (inFrame.format)
        {
            case Av.Util.Sample.Format.FLTP:
                nbSamples = (int)(size / (sizeof (float) * inFrame.channels));
                break;

            case Av.Util.Sample.Format.S16P:
                nbSamples = (int)(size / (sizeof (int16) * inFrame.channels));
                break;

            default:
                critical (@"unsupported frame sample format $((int)inFrame.format)\n");
                break;
        }

        base (inFrame.channels, nbSamples, inFrame.sample_rate);

        switch (inFrame.format)
        {
            case Av.Util.Sample.Format.FLTP:
                unowned float[] frameLeftData = (float[])leftData;
                unowned float[] frameRightData = (float[])rightData;
                for (int cpt = 0; cpt < length; ++cpt)
                {
                    this[0, cpt] = frameLeftData[cpt];
                    if (channels > 1)
                    {
                        this[1, cpt] = frameRightData[cpt];
                    }
                }
                break;

            case Av.Util.Sample.Format.S16P:
                unowned int16[] frameLeftData = (int16[])leftData;
                unowned int16[] frameRightData = (int16[])rightData;
                for (int cpt = 0; cpt < length; ++cpt)
                {
                    this[0, cpt] = (float)frameLeftData[cpt] / -(float)int16.MIN;
                    if (channels > 1)
                    {
                        this[1, cpt] = (float)frameRightData[cpt] / -(float)int16.MIN;
                    }
                }
                break;

            default:
                critical (@"unsupported frame sample format $((int)inFrame.format)\n");
                break;
        }
    }
}
