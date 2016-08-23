/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * gain.vala
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

public class MaiaMixer.Core.Gain : Maia.Core.Object, Element
{
    // properties
    private int m_Volume = 100;
    private double m_Gain = 1.0;

    // accessors
    public int volume {
        get {
            return m_Volume;
        }
        set {
            if (m_Volume != value)
            {
                lock (m_Gain)
                {
                    m_Volume = value;
                    m_Gain = (GLib.Math.exp ((double)m_Volume / 100.0) - 1.0) / (GLib.Math.E - 1.0);
                }
            }
        }
    }

    // methods
    public Gain (string inName)
    {
        GLib.Object (id: GLib.Quark.from_string (inName));
    }

    public Audio.Sample?
    process (Audio.Sample inSample)
    {
        lock (m_Gain)
        {
            if (m_Gain != 1.0)
            {
                for (uint channel = 0; channel < inSample.channels; ++channel)
                {
                    for (uint cpt = 0; cpt < inSample.length; ++cpt)
                    {
                        inSample[channel, cpt] = inSample[channel, cpt] * (float)m_Gain;
                    }
                }
            }
        }
        return inSample;
    }
}
