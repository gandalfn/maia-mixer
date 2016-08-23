/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * channel.vala
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

public class MaiaMixer.Audio.Channel : Maia.Core.Object
{
    // types
    [Flags]
    public enum Flags
    {
        NONE,
        INPUT,
        OUTPUT,
        PHYSICAL,
        IS_MINE
    }

    // accessors
    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    [CCode (notify = false)]
    public virtual Flags flags {
        get {
            return Flags.NONE;
        }
        construct set {
        }
    }

    [CCode (notify = false)]
    public virtual uint32 buffer_size {
        get {
            return 0;
        }
        construct set {
        }
    }

    // methods
    public Channel (string inName, uint32 inBufferSize = 4096 * 16)
    {
        GLib.Object (id: GLib.Quark.from_string (inName), buffer_size: inBufferSize);
    }

    internal override bool
    can_append_child (Maia.Core.Object inObject)
    {
        return false;
    }
}
