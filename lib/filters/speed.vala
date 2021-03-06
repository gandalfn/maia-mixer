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
 */

public class MaiaMixer.Filters.Speed : MaiaMixer.Filters.Filter
{
    // accessors
    public virtual uint sample_rate { get; construct; }
    public virtual double ratio { get; construct set; }

    // methods
    public Speed (uint inSampleRate, double inRatio)
    {
        GLib.Object (sample_rate: inSampleRate, ratio: inRatio);
    }

    internal override Audio.Sample?
    process (Audio.Sample inSample)
    {
        return inSample;
    }
}
