/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * bpm-detect.vala
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

public class MaiaMixer.Soundtouch.BPMDetect : MaiaMixer.Filters.BPMDetect
{
    // properties
    private global::soundtouch.BPMDetect m_Detect;

    // accessors
    internal override float bpm {
        get {
            return m_Detect.bpm;
        }
    }

    // methods
    public BPMDetect (uint inSampleRate)
    {
        base (inSampleRate);
    }

    internal override void
    delegate_construct ()
    {
        m_Detect = new global::soundtouch.BPMDetect (1, (int)sample_rate);
    }

    internal override Audio.Sample?
    process (Audio.Sample inSample)
    {
        if (inSample.length > 0 && inSample.channels > 0)
        {
            m_Detect.input_samples (inSample.get_channel_data (0));
        }

        return inSample;
    }
}
