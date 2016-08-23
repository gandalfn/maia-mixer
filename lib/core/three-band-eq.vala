/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * three-band-eq.vala
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

public class MaiaMixer.Core.ThreeBandEq : Maia.Core.Object, Element
{
    // properties
    private Filters.ThreeBandEq m_Eq;

    // accessors
    public double master {
        get {
            return m_Eq.master;
        }
        set {
           double gain = (GLib.Math.exp ((double)value / 24.0) - 1.0) / (GLib.Math.E - 1.0);
           m_Eq.master = gain * 24.0;
        }
    }

    public double low {
        get {
            return m_Eq.low;
        }
        set {
            double gain = (GLib.Math.exp ((double)value / 24.0) - 1.0) / (GLib.Math.E - 1.0);
            m_Eq.low = gain * 24.0;
        }
    }

    public double med {
        get {
            return m_Eq.med;
        }
        set {
            double gain = (GLib.Math.exp ((double)value / 24.0) - 1.0) / (GLib.Math.E - 1.0);
            m_Eq.med = gain * 24.0;
        }
    }

    public double high {
        get {
            return m_Eq.high;
        }
        set {
            double gain = (GLib.Math.exp ((double)value / 24.0) - 1.0) / (GLib.Math.E - 1.0);
            m_Eq.high = gain * 24.0;
        }
    }

    // methods
    public ThreeBandEq (string inName, uint inFrameRate, uint inNSamples)
    {
        GLib.Object (id: GLib.Quark.from_string (inName));

        m_Eq = new Filters.ThreeBandEq (inFrameRate, inNSamples);
    }

    public Audio.Sample?
    process (Audio.Sample inSample)
    {
        return m_Eq.process (inSample);
    }
}
