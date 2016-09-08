/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * resample.vala
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

public class MaiaMixer.FFMpeg.Resample : MaiaMixer.Filters.Resample
{
    // methods
    public Resample (int inSampleRate)
    {
        GLib.Object (sample_rate: inSampleRate);
    }

    internal override Audio.Sample?
    process (Audio.Sample inSample)
    {
        Audio.Sample? ret = inSample;

        if (inSample.sample_rate != sample_rate)
        {
            var resample = new Sw.Resample.Context ();
            Av.Util.Options.set_channel_layout (resample, "in_channel_layout", inSample.channels == 1 ? Av.Util.ChannelLayout.Mask.MONO : Av.Util.ChannelLayout.Mask.STEREO);
            Av.Util.Options.set_channel_layout (resample, "out_channel_layout", inSample.channels == 1 ? Av.Util.ChannelLayout.Mask.MONO : Av.Util.ChannelLayout.Mask.STEREO);
            Av.Util.Options.set_int (resample, "in_sample_rate", inSample.sample_rate);
            Av.Util.Options.set_int (resample, "out_sample_rate", sample_rate);
            Av.Util.Options.set_sample_fmt (resample, "in_sample_fmt", Av.Util.Sample.Format.FLTP);
            Av.Util.Options.set_sample_fmt (resample, "out_sample_fmt", Av.Util.Sample.Format.FLTP);
            resample.init ();

            ret = new Audio.Sample (inSample.channels, (uint)resample.get_out_samples ((int)inSample.length), sample_rate);
            unowned uint8[] outData = (uint8[])ret.data;
            unowned uint8[] inData = (uint8[])inSample.data;
            if (resample.convert (outData, (int)ret.length, inData, (int)inSample.length) < 0)
            {
                ret = inSample;
            }

            resample.close ();
        }

        return ret;
    }
}
