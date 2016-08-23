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

public class MaiaMixer.Mad.FileMpeg : MaiaMixer.Audio.FileMpeg
{
    // types
    private class Frame : Audio.File.Frame
    {
        // properties
        public uchar* m_Offset;

        // accessors
        internal override Audio.Sample? sample {
            owned get {
                Sample ret = null;
                unowned FileMpeg file = parent as FileMpeg;

                // check if file point under this frame
                if (file != null && file.m_Stream.this_frame == m_Offset && file.m_Synth.pcm.channels > 0 && file.m_Synth.pcm.length > 0)
                {
                    ret = new Sample (file.m_Synth);
                }

                return ret;
            }
        }

        // methods
        public Frame (uchar* inOffset, global::Mad.Timer inStart, global::Mad.Timer inEnd)
        {
            GLib.Object (begin: inStart.count (global::Mad.Units.MILLISECONDS), end: inEnd.count (global::Mad.Units.MILLISECONDS));

            m_Offset = inOffset;
        }
    }

    // properties
    private GLib.MappedFile     m_File;
    private global::Mad.Timer   m_Duration;
    private global::Mad.Stream  m_Stream;
    private global::Mad.Synth   m_Synth;
    private global::Mad.Frame   m_Frame;

    // accessors
    internal override long position {
        get {
            return base.position;
        }
        set {
            base.position = value;

            // In the worst case up to 29 MP3 frames need to be prefetched
            // for accurate seeking:
            // http://www.mars.org/mailman/public/mad-dev/2002-May/000634.html
            unowned Frame? prefetchSeek = current_frame as Frame;
            int count = 0;
            for (int cpt = 0; cpt < 29; ++cpt)
            {
                ++count;
                if (prefetchSeek.prev () != null)
                {
                    prefetchSeek = prefetchSeek.prev () as Frame;
                }
                else
                {
                    break;
                }
            }

            // recreate stream at position offset
            m_Stream = global::Mad.Stream ();
            m_Stream.options (global::Mad.Option.IGNORECRC);
            m_Stream.buffer (prefetchSeek.m_Offset, (uchar*)(m_File.get_contents () + m_File.get_length ()) - prefetchSeek.m_Offset);

            // create synth
            m_Synth = global::Mad.Synth ();
            // create frame
            m_Frame = global::Mad.Frame ();

            for (int cpt = 0; m_Stream.this_frame != (current_frame as Frame).m_Offset && decode_frame (false); ++cpt)
            {
                m_Synth.frame (m_Frame);
            }
        }
    }

    internal override long duration {
        get {
            return m_Duration.count (global::Mad.Units.MILLISECONDS);
        }
    }

    // methods
    public FileMpeg (string inFilename)
    {
        GLib.Object (filename: inFilename);
    }

    private bool
    decode_frame_header (ref global::Mad.Header inHeader)
    {
        int res = inHeader.decode (ref m_Stream);
        if ( res == -1)
        {
            // Something went wrong when decoding the frame header...
            if (m_Stream.error == global::Mad.Error.BUFLEN)
            {
                // EOF
                return false;
            }

            if (m_Stream.have_unrecoverable_error ())
            {
                warning (@"Unrecoverable MP3 header decoding error: $(m_Stream.errorstr ())");
                return false;
            }

            if (m_Stream.have_recoverable_error ())
            {
                if (m_Stream.error == global::Mad.Error.LOSTSYNC)
                {
                    return false;
                }
                warning (@"Recoverable MP3 header decoding error: $(m_Stream.errorstr ())");
                return false;
            }
        }
        return true;
    }

    private bool
    decode_frame (bool inSkipFrame = true)
    {
        while (true)
        {
            int res = m_Frame.decode (ref m_Stream);
            if ( res == -1)
            {
                // Something went wrong when decoding the frame header...
                if (m_Stream.error == global::Mad.Error.BUFLEN)
                {
                    warning (@"Unrecoverable MP3 header decoding error: $(m_Stream.errorstr ())");
                    // EOF
                    return false;
                }

                if (m_Stream.have_unrecoverable_error ())
                {
                    warning (@"Unrecoverable MP3 header decoding error: $(m_Stream.errorstr ())");
                    return false;
                }

                if (m_Stream.have_recoverable_error ())
                {
                    if (inSkipFrame)
                    {
                        base.next_frame ();
                    }
                    //warning (@"Recoverable MP3 header decoding error: $(m_Stream.errorstr ())");
                    continue;
                }
            }
            break;
        }

        return true;
    }

    private void
    load_frames ()
    {
        global::Mad.Header header = global::Mad.Header ();
        m_Duration = global::Mad.Timer.ZERO;

        do
        {
            unowned uchar* offset = m_Stream.this_frame;
            if (!decode_frame_header (ref header))
            {
                if (m_Stream.is_valid ())
                {
                    // Skip frame
                    continue;
                }
                else
                {
                    // Abort decoding
                    break;
                }
            }

            // Insert new rame in collection
            long frameLength = header.duration.count ((global::Mad.Units)header.samplerate);
            if (frameLength <= 0)
            {
                continue;
            }
            global::Mad.Timer begin = m_Duration;
            global::Mad.Timer.add (ref m_Duration, header.duration);
            global::Mad.Timer end = m_Duration;

            add (new Frame (offset, begin, end));
        } while ((size_t)(m_Stream.this_frame - (uchar*)m_File.get_contents ()) < m_File.get_length ());
    }

    internal override void
    delegate_construct ()
    {
        if (GLib.FileUtils.test (filename, GLib.FileTest.EXISTS) && !GLib.FileUtils.test (filename, GLib.FileTest.IS_DIR))
        {
            try
            {
                // map file
                m_File = new GLib.MappedFile (filename, false);

                // create stream
                m_Stream = global::Mad.Stream ();
                m_Stream.options (global::Mad.Option.IGNORECRC);
                m_Stream.buffer (m_File.get_contents (), m_File.get_length ());

                // Load frame collection
                load_frames ();

                // recreate stream to roll over
                m_Stream = global::Mad.Stream ();
                m_Stream.options (global::Mad.Option.IGNORECRC);
                m_Stream.buffer (m_File.get_contents (), m_File.get_length ());

                // create synth
                m_Synth = global::Mad.Synth ();
                // create frame
                m_Frame = global::Mad.Frame ();

                // read first frame
                if (decode_frame ())
                {
                    m_Synth.frame (m_Frame);
                }
            }
            catch (GLib.Error err)
            {
                critical (@"Error on open $filename: $(err.message)");
            }
        }
    }

    internal override bool
    next_frame ()
    {
        bool ret = false;

        if (decode_frame ())
        {
            m_Synth.frame (m_Frame);

            if (m_Stream.this_frame != (current_frame as Frame).m_Offset)
            {
                ret = base.next_frame ();
            }
            else
            {
                ret = true;
            }
        }

        return ret;
    }
}
