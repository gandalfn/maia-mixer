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

public class MaiaMixer.Filters.ThreeBandEq : MaiaMixer.Filters.Filter
{
    // accessors
    public uint sample_rate      { get; construct; }
    public uint n_samples        { get; construct; }
    public virtual double master { get; set; default = 0.0; }
    public virtual double low    { get; set; default = 0.0; }
    public virtual double med    { get; set; default = 0.0; }
    public virtual double high   { get; set; default = 0.0; }

    // methods
    public ThreeBandEq (uint inSampleRate, uint inNSamples)
    {
        GLib.Object (sample_rate: inSampleRate, n_samples: inNSamples);
    }

    internal override Audio.Sample?
    process (Audio.Sample inSample)
    {
        return inSample;
    }
}
