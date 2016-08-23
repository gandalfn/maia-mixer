/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * stream.vala
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

public class MaiaMixer.Core.Stream : Maia.Core.Object
{
    // accesors
    [CCode (notify = false)]
    public virtual uint32 buffer_size {
        get {
            return 0;
        }
        construct set {
        }
    }

    public virtual size_t read_available {
        get {
            return 0;
        }
    }

    public virtual size_t write_available {
        get {
            return 0;
        }
    }

    // methods
    public Stream (uint32 inBufferSize = (4096 * 16))
        requires (inBufferSize > 0)
    {
        GLib.Object (buffer_size: inBufferSize);
    }

    public virtual size_t pop (ref unowned float[] outData)
    {
        return 0;
    }

    public virtual size_t peek (ref unowned float[] outData)
    {
        return 0;
    }

    public virtual size_t push (float[] inData)
    {
        return 0;
    }

    public virtual void flush ()
    {

    }
}
