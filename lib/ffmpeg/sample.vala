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
        base (inFrame.channels, inFrame.nb_samples, inFrame.sample_rate);

        unowned float[,] data = (float[,])inFrame.extended_data;
        data.length[0] = inFrame.channels;
        data.length[1] = inFrame.nb_samples;

        for (int channel = 0; channel < int.min (2, inFrame.channels); ++channel)
        {
            for (int cpt = 0; cpt < inFrame.nb_samples; ++cpt)
            {
                this[channel, cpt] = data[channel, cpt];
            }
        }
    }
}
