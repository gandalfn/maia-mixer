/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * output-stream.vala
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

public class MaiaMixer.Core.OutputStream : Maia.Core.Object
{
    // properties
    private Stream m_Stream;

    // accessors
    public size_t available {
        get {
            return (size_t)((int)m_Stream.buffer_size - (int)m_Stream.write_available) + 1;
        }
    }

    // methods
    public OutputStream (Stream inStream)
    {
        m_Stream = inStream;
    }

    public bool
    write (float[] inData)
    {
        bool ret = false;

        if (m_Stream.write_available >= inData.length)
        {
            ret = m_Stream.push (inData) == inData.length;
        }

        return ret;
    }
}
