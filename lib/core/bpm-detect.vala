/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * bpm-detect.vala
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

public class MaiaMixer.Core.BPMDetect : Maia.Core.Object, Element
{
    // types
    public class EventArgs : Maia.Core.EventArgs
    {
        // accessors
        public double bpm {
            get {
                return (double)this["bpm", 0];
            }
        }

        // static methods
        static construct
        {
            Maia.Core.EventArgs.register_protocol (typeof (EventArgs).name (),
                                                   "BPM",
                                                   "message BPM {"    +
                                                   "     double bpm;"  +
                                                   "}");
        }

        // methods
        public EventArgs (float inBPM)
        {
            this["bpm", 0] = (double)inBPM;
        }
    }

    // properties
    private Filters.BPMDetect m_Detect;
    private float             m_BPM;
    private Maia.Core.Event   m_Event;
    private GLib.Mutex        m_Mutex = GLib.Mutex ();

    // accessoirs
    public Maia.Core.Event bpm_changed {
        get {
            return m_Event;
        }
    }

    // methods
    public BPMDetect (string inName, uint inFrameRate)
    {
        GLib.Object (id: GLib.Quark.from_string (inName));

        // Create event
        m_Event = new Maia.Core.Event ("bpm-changed");

        // Create detector
        m_Detect = new Filters.BPMDetect (inFrameRate);
        m_BPM = (float)0.0;
    }

    public void
    reset ()
    {
        m_Mutex.lock ();
        {
            uint sample_rate = m_Detect.sample_rate;
            m_Detect = new Filters.BPMDetect (sample_rate);
        }
        m_Mutex.unlock ();
    }

    public Audio.Sample?
    process (Audio.Sample inSample)
    {
        m_Detect.process (inSample);

        if (m_Mutex.trylock ())
        {
            float bpm = m_Detect.bpm;
            if (bpm > 0.0 && GLib.Math.fabs (m_BPM - bpm) > 1.0)
            {
                m_BPM = bpm;
                m_Event.publish (new EventArgs (bpm));
            }
            m_Mutex.unlock ();
        }

        return inSample;
    }
}
