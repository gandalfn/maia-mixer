/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * file-mpeg.vala
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

public class MaiaMixer.FFMpeg.FileMpeg : MaiaMixer.Audio.FileMpeg
{
    // properties
    private File m_File;

    // accessors
    internal override unowned Audio.File.Frame? current_frame {
        get {
            return m_File != null ? m_File.current_frame : null;
        }
    }

    internal override long position {
        get {
            return m_File != null ? m_File.position : 0;
        }
        set {
            if (m_File != null)
            {
                m_File.position = value;
            }
        }
    }

    internal override long duration {
        get {
            return m_File != null ? m_File.duration : 0;
        }
    }

    // methods
    public FileMpeg (string inFilename)
    {
        GLib.Object (filename: inFilename);
    }

    internal override void
    delegate_construct ()
    {
        if (GLib.FileUtils.test (filename, GLib.FileTest.EXISTS) && !GLib.FileUtils.test (filename, GLib.FileTest.IS_DIR))
        {
            // create file
            m_File = new File (filename);
        }
    }

    internal override unowned Maia.Core.Object?
    first ()
    {
        return m_File.first ();
    }

    internal override unowned Maia.Core.Object?
    last ()
    {
        return m_File.last ();
    }

    internal override bool
    next_frame ()
    {
        return m_File != null ? m_File.next_frame () : false;
    }
}
