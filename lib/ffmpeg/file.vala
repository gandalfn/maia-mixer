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

internal class MaiaMixer.FFMpeg.File : MaiaMixer.Audio.File
{
    // types
    private class Frame : Audio.File.Frame
    {
        // properties
        public int64 m_Offset;

        // accessors
        internal override Audio.Sample? sample {
            owned get {
                Sample ret = null;
                unowned File file = parent as File;

                // check if file point under this frame
                if (file != null)
                {
                    ret = new Sample (file.m_Frame);
                }

                return ret;
            }
        }

        // methods
        public Frame (Av.Codec.Packet inPacket, double inTimeBase)
        {
            long offset = (long)((double)inPacket.pts * inTimeBase * 1000.0);
            long duration = (long)((double)inPacket.duration * inTimeBase * 1000.0);

            GLib.Object (begin: offset, end: (offset + duration));

            m_Offset = inPacket.pts;
        }
    }

    // properties
    private unowned Av.Format.Context m_Context;
    private int                       m_NumStream;
    private unowned Av.Codec.Codec    m_Codec;
    private Av.Codec.Context          m_CodecContext;
    private Av.Codec.Packet           m_Packet;
    private Av.Util.Frame             m_Frame;

    // accessors
    internal override long position {
        get {
            return base.position;
        }
        set {
            base.position = value;

            if (m_Context != null)
            {
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

                m_Context.seek_frame (m_NumStream, prefetchSeek.m_Offset, Av.Format.SeekFlag.ANY);

                for (int cpt = 0; m_Frame.pkt_pts != (current_frame as Frame).m_Offset && decode_frame (); ++cpt);
            }
        }
    }

    internal override long duration {
        get {
            long ret = 0;

            if (m_Context != null)
            {
                ret = (long)((double)(m_Context.duration * 1000.0) / (double)Av.Util.TIME_BASE);
            }
            return ret;
        }
    }

    // methods
    public File (string inFilename)
    {
        GLib.Object (filename: inFilename);

        if (init_context ())
        {
            load_frames ();

            m_CodecContext = null;
            Av.Format.Context.close_input (ref m_Context);
            m_Context = null;

            if (init_context ())
            {
                m_Packet = new Av.Codec.Packet ();
                m_Packet.init ();

                m_Frame = new Av.Util.Frame ();
                next_frame ();
            }
        }
    }

    ~File ()
    {
        m_Frame = null;
        m_Packet = null;
        m_CodecContext = null;
        Av.Format.Context.close_input (ref m_Context);
        m_Context = null;
    }

    private bool
    init_context ()
    {
        int ret = Av.Format.Context.open_input (out m_Context, filename, null, null);
        if (ret < 0)
        {
            critical (@"Error on open input $(filename) $ret");
            return false;
        }

        ret = m_Context.find_stream_info (null);
        if (ret < 0)
        {
            critical (@"Error on get stream info $(filename)");
            Av.Format.Context.close_input (ref m_Context);
            m_Context = null;
            return false;
        }

        m_NumStream = m_Context.find_best_stream (Av.Util.MediaType.AUDIO, -1, -1, out m_Codec, 0);
        if (m_NumStream < 0)
        {
            critical (@"Error on get audio stream $(filename)");
            Av.Format.Context.close_input (ref m_Context);
            m_Context = null;
            return false;
        }

        m_CodecContext = new Av.Codec.Context (m_Codec);
        ret = m_CodecContext.set_parameters (m_Context.streams[m_NumStream].codecpar);
        if (ret < 0)
        {
            critical (@"Error on set codec parameter $(filename)");
            m_CodecContext = null;
            Av.Format.Context.close_input (ref m_Context);
            m_Context = null;
            return false;
        }

        ret = m_CodecContext.open (m_Codec, null);
        if (ret < 0)
        {
            critical (@"Error on open codec $(filename)");
            m_CodecContext = null;
            Av.Format.Context.close_input (ref m_Context);
            m_Context = null;
            return false;
        }

        return true;
    }

    private void
    load_frames ()
    {
        Av.Codec.Packet packet = new Av.Codec.Packet ();
        packet.init ();

        double timeBase = m_Context.streams[m_NumStream].time_base.q2d ();

        while (m_Context.read_frame (packet) == 0)
        {
            if (packet.stream_index == m_NumStream)
            {
                add (new Frame (packet, timeBase));
            }
        }
    }

    private bool
    decode_frame ()
    {
        bool ret = false;

        while (m_Context.read_frame (m_Packet) == 0)
        {
            int status = m_CodecContext.send_packet (m_Packet);
            if (status < 0)
            {
                break;
            }

            status = m_CodecContext.receive_frame (m_Frame);
            if (status == Av.Util.Error.from_posix (Posix.EAGAIN))
            {
                continue;
            }
            else if (status == Av.Util.Error.EOF)
            {
                break;
            }
            else if (status < 0)
            {
                break;
            }

            ret = true;
            break;
        }

        return ret;
    }

    internal override bool
    next_frame ()
    {
        bool ret = false;

        if (decode_frame ())
        {
            if (m_Frame.pkt_pts != (current_frame as Frame).m_Offset)
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
