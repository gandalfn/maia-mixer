/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * sample-cache.vala
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

public class MaiaMixer.Core.SampleCache : Maia.Core.Object
{
    // properties
    private Maia.Core.Array<Audio.Sample> m_Samples;
    private int                           m_Begin;
    private int                           m_End;
    private int                           m_Index;

    // accessors
    public int size { get; construct; }

    public int available {
        get {
            int ret = 0;
            if (m_Begin <= m_End)
            {
                ret = m_End - m_Begin;
            }
            else
            {
                ret = (m_End + size) - m_Begin;
            }

            return ret;
        }
    }

    public int prev_available {
        get {
            int ret = 0;
            print(@"prev available begin: $m_Begin end: $m_End index: $m_Index\n");
            if (m_Begin <= m_Index)
            {
                ret = m_Index - m_Begin;
            }
            else
            {
                ret = (m_Index + size) - m_Begin;
            }

            return ret;
        }
    }

    public int next_available {
        get {
            int ret = 0;
            print(@"next available begin: $m_Begin end: $m_End index: $m_Index\n");
            if (m_Index <= m_End)
            {
                ret = m_End - m_Index;
            }
            else
            {
                ret = (m_End + size) - m_Index;
            }

            return ret;
        }
    }

    // methods
    public SampleCache (int inSize)
        requires (inSize > 0)
    {
        GLib.Object (size: inSize);

        m_Samples = new Maia.Core.Array<Audio.Sample> ();
        m_Samples.reserve (inSize);
        m_Begin = 0;
        m_End = -1;
        m_Index = 0;
    }

    public bool
    push_back (Audio.Sample inSample)
    {
        bool ret = false;
        int pos = (m_End + 1) % size;

        if (pos != m_Begin || m_End == -1)
        {
            if (m_End == -1)
                m_End = 0;
            else
                m_End = pos;
            m_Samples[m_End] = inSample;
            ret = true;
        }
        print(@"push back begin: $m_Begin end: $m_End index: $m_Index\n");

        return ret;
    }

    public bool
    push_front (Audio.Sample inSample)
    {
        bool ret = false;
        int pos = m_Begin - 1 < 0 ? size - 1 : m_Begin - 1;

        if (pos != m_End)
        {
            m_Begin = pos;
            m_Samples[m_Begin] = inSample;
            ret = true;
        }
        print(@"push front begin: $m_Begin end: $m_End index: $m_Index\n");

        return ret;
    }

    public bool
    seek (int inOffset)
        requires (inOffset < size && inOffset > -size)
    {
        bool ret = false;
        int pos = m_Index + inOffset;

        if (pos > 0)
        {
            pos = pos % size;
        }
        else if (pos < 0)
        {
            pos = pos + size;
        }

        print(@"begin: $m_Begin end: $m_End index: $m_Index\n");
        if (pos >= m_Begin && pos <= m_End)
        {
            m_Index = pos;
            ret = true;
        }

        return ret;
    }

    public unowned Audio.Sample?
    pop_next ()
    {
        unowned Audio.Sample? ret = null;
        print(@"pop next begin: $m_Begin end: $m_End index: $m_Index\n");
        if (m_Index >= m_Begin && m_Index < m_End)
        {
            m_Index = (m_Index + 1) % size;
            m_Begin = (m_Begin + 1) % size;
            ret = m_Samples[m_Index];
        }
        return ret;
    }

    public unowned Audio.Sample?
    pop_prev ()
    {
        unowned Audio.Sample? ret = null;
        print(@"pop prev begin: $m_Begin end: $m_End index: $m_Index\n");
        if (m_Index > m_Begin && m_Index <= m_End)
        {
            m_Index = m_Index - 1 < 0 ? size - 1 : m_Index - 1;
            m_End = m_End - 1 < 0 ? size - 1 : m_End - 1;
            ret = m_Samples[m_Index];
        }
        return ret;
    }
}
