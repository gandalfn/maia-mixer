/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * file.vala
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

public abstract class MaiaMixer.Audio.File : Maia.Core.Object
{
    // types
    public class Frame : Maia.Core.Object
    {
        // accessors
        public long begin { get; construct; default = 0; }
        public long end { get; construct; default = 0; }
        public virtual Sample? sample {
            owned get {
                return null;
            }
        }

        // methods
        internal override int
        compare (Maia.Core.Object inObject)
            requires (inObject is Frame)
        {
            unowned Frame frame = inObject as Frame;

            if (end < frame.begin)
                return -1;
            else if (begin > frame.end)
                return 1;

            return 0;
        }

        public new bool
        contains (long inPosition)
        {
            return inPosition >= begin && inPosition < end;
        }
    }

    // properties
    private unowned Frame? m_Current = null;

    // accessors
    [CCode (notify = false)]
    public string filename { get; construct; }

    public virtual unowned Frame? current_frame {
        get {
            return m_Current ?? first () as Frame;
        }
    }

    public virtual long position {
        get {
            return m_Current != null ? m_Current.begin : 0;
        }
        set {
            foreach (unowned Maia.Core.Object child in this)
            {
                unowned Frame? frame = child as Frame;
                if (frame != null && value in frame)
                {
                    m_Current = frame;
                    break;
                }
            }
        }
    }

    public virtual long duration {
        get {
            return 0;
        }
    }

    // static methods
    public static File?
    load (string inFilename)
    {
        File? ret = null;

        if (GLib.FileUtils.test (inFilename, GLib.FileTest.EXISTS) && !GLib.FileUtils.test (inFilename, GLib.FileTest.IS_DIR))
        {
            var file = GLib.File.new_for_path (inFilename);

            try
            {
                var info = file.query_info (GLib.FileAttribute.STANDARD_CONTENT_TYPE, 0);
                string content = info.get_content_type ();

                switch (content)
                {
                    case "audio/mpeg":
                        ret = new FileMpeg (inFilename);
                        break;

                    case "audio/mp4":
                        ret = new FileMp4 (inFilename);
                        break;

                    case "audio/x-vorbis+ogg":
                        //ret = new FileOgg (inFilename);
                        break;

                    default:
                        critical ("%s unknown audio file type %s", inFilename, content);
                        break;
                }
            }
            catch (GLib.Error err)
            {
                critical ("Error on load filename %s: %s", inFilename, err.message);
            }
        }
        else
        {
            critical ("Invalid filename %s", inFilename);
        }

        return ret;
    }

    // methods
    public virtual bool
    next_frame ()
    {
        unowned Frame? next = current_frame.next () as Frame;
        if (next != null)
        {
            m_Current = next;
        }
        return next != null;
    }

    internal override bool
    can_append_child (Maia.Core.Object inObject)
    {
        return inObject is Frame;
    }
}
