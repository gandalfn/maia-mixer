/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * file-src.vala
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

public class MaiaMixer.Core.FileSrc : Maia.Core.Object, Element
{
    // types
    public class PositionEventArgs : Maia.Core.EventArgs
    {
        // accessors
        public long position {
            get {
                return (long)(int64)this["position", 0];
            }
        }

        public long duration {
            get {
                return (long)(int64)this["duration", 0];
            }
        }

        // static methods
        static construct
        {
            Maia.Core.EventArgs.register_protocol (typeof (PositionEventArgs).name (),
                                                   "Position",
                                                   "message Position {"    +
                                                   "     int64 position;"  +
                                                   "     int64 duration;"  +
                                                   "}");
        }

        // methods
        public PositionEventArgs (long inPosition, long inDuration)
        {
            this["position", 0] = (int64)inPosition;
            this["duration", 0] = (int64)inDuration;
        }
    }

    private enum ThreadAction
    {
        START,
        WAIT,
        END,
        POSITION
    }

    private class DecodeThread : GLib.Object
    {
        const int BUFFER_SIZE = 1024 * 8;
        const long POSITION_SEND_DELAY = 400;

        public abstract class Action
        {
        }

        public class ActionEnd : Action
        {
            public ActionEnd ()
            {
            }
        }

        public class ActionSeek : Action
        {
            public long m_Position;

            public ActionSeek (long inPosition)
            {
                m_Position = inPosition;
            }
        }

        public class ActionSpeed : Action
        {
            public double m_Speed;

            public ActionSpeed (double inSpeed)
            {
                m_Speed = inSpeed;
            }
        }

        public class ActionStep : Action
        {
            public uint32 m_Step;

            public ActionStep (uint32 inStep)
            {
                m_Step = inStep;
            }
        }

        private unowned FileSrc               m_FileSrc;
        private unowned Audio.File            m_File;
        private uint                          m_FrameRate;
        private double                        m_Speed = 1.0;
        private Core.Buffer                   m_BufferLeft;
        private Core.Buffer                   m_BufferRight;
        private long                          m_Begin;
        private long                          m_End;
        private long                          m_LastPositionSend;
        private size_t                        m_NbSamples;
        private GLib.Thread<bool>             m_Thread;
        private Maia.Core.AsyncQueue<Action>  m_Actions;

        public long position {
            get {
                lock (m_Begin)
                {
                    return m_Begin;
                }
            }
        }

        public DecodeThread (FileSrc inFileSrc, uint inFrameRate)
        {
            // Get file src
            m_FileSrc = inFileSrc;

            // Set file
            m_File = inFileSrc.m_File;

            // Set decoding frame rate
            m_FrameRate = inFrameRate;

            // Create buffers
            m_BufferLeft = new Core.Buffer (BUFFER_SIZE);
            m_BufferRight = new Core.Buffer (BUFFER_SIZE);

            // Create actions queue
            m_Actions = new Maia.Core.AsyncQueue<Action> ();

            m_Thread = new GLib.Thread<bool> ("decode-thread", run);

            seek (0);
        }

        ~DecodeThread ()
        {
            stop ();
            m_Thread.join ();
        }

        private void
        fill ()
        {
            // Get current frame
            unowned Audio.File.Frame? frame = m_File.current_frame;
            if (frame != null)
            {
                if (m_Speed > 0.0 && frame != m_File.last ())
                {
                    // Get size available to write in buffer
                    size_t leftSizeAvailable = m_BufferLeft.write_available;
                    size_t rightSizeAvailable = m_BufferRight.write_available;
                    size_t size = 0;

                    do
                    {
                        frame = m_File.current_frame;

                        // get sample from current frame
                        Audio.Sample? sample = frame.sample;
                        if (sample != null)
                        {
                            // Create resample filter to occurate the file-src samplerate
                            var resample = new Filters.Resample ((int)m_FrameRate);
                            sample = resample.process (sample);

                            // A custom speed has been resample to occurate samplerate
                            if (m_Speed != 1.0)
                            {
                                var speed = new Filters.Speed (m_FrameRate, m_Speed);
                                sample = speed.process (sample);
                            }

                            // Get sample size
                            size = sample.length;

                            // the necessary write size is available in buffers
                            if (size > 0 && size <= leftSizeAvailable && size <= rightSizeAvailable)
                            {
                                // Get left channel
                                unowned float[] left = sample.get_channel_data (0);
                                // Get right channel else left channel if sample is mono
                                unowned float[] right = sample.get_channel_data (sample.channels >= 2 ? 1 : 0);

                                // TODO: we can have some sync problems because we writing under buffer in 2 times
                                // Push left channel in buffer
                                m_BufferLeft.push (left);
                                // Push right channel in buffer
                                m_BufferRight.push (right);

                                // Get size available to write in buffer
                                leftSizeAvailable = m_BufferLeft.write_available;
                                rightSizeAvailable = m_BufferRight.write_available;

                                // Set end of buffer
                                m_End = frame.end;

                                // Calculate the number of samples
                                m_NbSamples += size;
                            }
                        }

                        // Cancel loading if another request is here
                        unowned Action? action = m_Actions.peek_timed (1);
                        if (action is ActionEnd || action is ActionSeek) break;

                    // Loop since last frame size is available for writing in buffers
                    } while (m_File.next_frame () && size <= leftSizeAvailable &&  size <= rightSizeAvailable);
                }
                else if (m_Speed < 0.0 && frame != m_File.first ())
                {
                    // Get size available to write in buffer
                    size_t leftSizeAvailable = m_BufferLeft.write_available;
                    size_t rightSizeAvailable = m_BufferRight.write_available;
                    size_t size = 0;

                    // Get sample size of current frame
                    Audio.Sample? sample = frame.sample;
                    if (sample != null)
                    {
                        // Create resample filter to occurate the file-src samplerate
                        var resample = new Filters.Resample ((int)m_FrameRate);
                        sample = resample.process (sample);

                        // A custom speed has been resample to occurate samplerate
                        if (m_Speed != 1.0)
                        {
                            var speed = new Filters.Speed (m_FrameRate, m_Speed);
                            sample = speed.process (sample);
                        }

                        // Get sample size
                        size = sample.length;

                        // calculate the number of frame to roll back for fill buffer
                        int nbSamples = (int)size_t.min (leftSizeAvailable, rightSizeAvailable) / (int)size;

                        // roll back to first frame to decode
                        int count = nbSamples;
                        unowned Audio.File.Frame? first = m_File.current_frame;
                        for (; first != null && first != m_File.first () && count > 0; --count)
                        {
                            first = first.prev () as Audio.File.Frame;
                        }

                        // found first frame to decode
                        if (first != null)
                        {
                            // seek to this frame
                            m_End = first.begin;
                            m_File.position = first.begin;

                            leftSizeAvailable = nbSamples * size;
                            rightSizeAvailable = nbSamples * size;

                            // Create buffers
                            unowned float[] left = (float[])GLib.Slice.alloc0 (leftSizeAvailable * sizeof (float));
                            left.length = (int)leftSizeAvailable;
                            unowned float[] right = (float[])GLib.Slice.alloc0 (rightSizeAvailable * sizeof (float));
                            right.length = (int)rightSizeAvailable;

                            float* leftPosition = (float*)left + leftSizeAvailable;
                            float* rightPosition = (float*)right + rightSizeAvailable;

                            // Decode frames
                            count = 0;
                            do
                            {
                                frame = m_File.current_frame;

                                // get sample from current frame
                                sample = frame.sample;
                                if (sample != null)
                                {
                                    // Create resample filter to occurate the file-src samplerate
                                    resample = new Filters.Resample ((int)m_FrameRate);
                                    sample = resample.process (sample);

                                    // A custom speed has been resample to occurate samplerate
                                    if (m_Speed != 1.0)
                                    {
                                        var speed = new Filters.Speed (m_FrameRate, m_Speed);
                                        sample = speed.process (sample);
                                    }

                                    // Get sample size
                                    size = sample.length;

                                    // the necessary write size is available in buffers
                                    if (size > 0 && size <= leftSizeAvailable && size <= rightSizeAvailable)
                                    {
                                        // Get left channel
                                        unowned float[] leftData = sample.get_channel_data (0);
                                        // Get right channel else left channel if sample is mono
                                        unowned float[] rightData = sample.get_channel_data (sample.channels >= 2 ? 1 : 0);

                                        // Calculate the position in buffers
                                        leftPosition = leftPosition - size;
                                        rightPosition = rightPosition - size;

                                        unowned float[] leftCurrent = (float[])leftPosition;
                                        leftCurrent.length = (int)size;
                                        unowned float[] rightCurrent = (float[])rightPosition;
                                        rightCurrent.length = (int)size;

                                        // Copy channels in buffers
                                        for (int cpt = 0; cpt < leftData.length; ++cpt)
                                        {
                                            leftCurrent[cpt] = leftData[cpt];
                                            rightCurrent[cpt] = rightData[cpt];
                                        }

                                        // Calculate the number of samples
                                        m_NbSamples += size;

                                        // Remove the writen data from buffer size
                                        leftSizeAvailable -= size;
                                        rightSizeAvailable -= size;

                                        // Increment the number of sample proceed
                                        count++;
                                    }
                                }

                                // Cancel loading if another request is here
                                unowned Action? action = m_Actions.peek_timed (1);
                                if (action is ActionEnd || action is ActionSeek) break;

                            // Loop since last frame size is available for writing in buffers
                            } while (m_File.next_frame () && size <= leftSizeAvailable &&  size <= rightSizeAvailable);

                            // push revert buffers in queue
                            unowned float[] buffer = (float[])leftPosition;
                            buffer.length = left.length - (int)(leftPosition - (float*)left);
                            if (buffer.length > 0)
                            {
                                m_BufferLeft.push (buffer);
                            }
                            buffer = (float[])rightPosition;
                            buffer.length = right.length - (int)(rightPosition - (float*)right);
                            if (buffer.length > 0)
                            {
                                m_BufferRight.push (buffer);
                            }

                            // free buffers
                            GLib.Slice.free (left.length * sizeof (float), left);
                            GLib.Slice.free (right.length * sizeof (float), right);

                            // Seek end position
                            m_File.position = first.begin;
                        }
                    }
                }
            }
        }

        private bool
        run ()
        {
            bool end = false;
            while (!end)
            {
                Action action = m_Actions.pop ();

                // end request
                if (action is ActionEnd)
                {
                    end = true;
                }
                // seek request
                else if (action is ActionSeek)
                {
                    unowned ActionSeek? seek = action as ActionSeek;
                    long position;

                    // Clear buffer
                    m_BufferLeft.clear ();
                    m_BufferRight.clear ();
                    m_NbSamples = 0;

                    // Seek file to position
                    m_File.position = seek.m_Position;

                    // Set begin of buffer
                    lock (m_Begin)
                    {
                        m_Begin = m_File.current_frame.begin;
                        m_End = m_File.current_frame.end;
                        position = m_Begin;
                    }

                    // fill buffers
                    fill ();

                    // Send position event
                    m_FileSrc.position_event.publish (new PositionEventArgs (position, m_File.duration));
                    m_LastPositionSend = position;
                }
                // speed request
                else if (action is ActionSpeed)
                {
                    unowned ActionSpeed? speed = action as ActionSpeed;
                    bool resetBuffer = (m_Speed < 0.0) == (speed.m_Speed > 0.0) ||
                                       (m_Speed > 0.0) == (speed.m_Speed < 0.0);
                    long position = 0;

                    if (resetBuffer)
                    {
                        // Clear buffer
                        m_BufferLeft.clear ();
                        m_BufferRight.clear ();
                        m_NbSamples = 0;
                    }

                    // Set speed
                    m_Speed = speed.m_Speed;

                    if (resetBuffer)
                    {
                        // Set begin of buffer
                        lock (m_Begin)
                        {
                            m_Begin = m_File.current_frame.begin;
                            m_End = m_File.current_frame.end;
                            position = m_Begin;
                        }
                    }

                    // fill buffers
                    fill ();

                    if (resetBuffer)
                    {
                        // Send position event
                        m_FileSrc.position_event.publish (new PositionEventArgs (position, m_File.duration));
                        m_LastPositionSend = position;
                    }
                }
                // step request
                else if (action is ActionStep)
                {
                    unowned ActionStep? step = action as ActionStep;
                    long position;

                    // Calc the current position
                    lock (m_Begin)
                    {
                        if (m_NbSamples > 0)
                        {
                            m_Begin += (long)(((double)(m_End - m_Begin) / (double)m_NbSamples) * (double)step.m_Step);
                        }
                        else
                        {
                            m_Begin = m_End;
                        }
                        position = m_Begin;
                    }

                    // Consume the step in nb samples
                    if (step.m_Step < m_NbSamples)
                    {
                        m_NbSamples -= step.m_Step;
                    }
                    else
                    {
                        m_NbSamples = 0;
                    }

                    // the write available is to half of buffer refill buffer
                    if (m_BufferLeft.write_available >= m_BufferLeft.size / 2 &&
                        m_BufferRight.write_available >= m_BufferRight.size / 2)
                    {
                        // fill buffers
                        fill ();
                    }

                    if ((long)GLib.Math.fabs (position - m_LastPositionSend) >= POSITION_SEND_DELAY)
                    {
                        m_FileSrc.position_event.publish (new PositionEventArgs (position, m_File.duration));
                        m_LastPositionSend = position;
                    }
                }
            }

            return false;
        }

        public void
        stop ()
        {
            m_Actions.push (new ActionEnd ());
        }

        public void
        step (uint32 inStep)
        {
            m_Actions.push (new ActionStep (inStep));
        }

        public void
        seek (long inPosition)
        {
            m_Actions.push (new ActionSeek (inPosition));
        }

        public void
        speed (double inSpeed)
        {
            m_Actions.push (new ActionSpeed (inSpeed));
        }

        public void
        fill_sample (Audio.Sample inSample)
        {
            uint length = inSample.length;
            uint channels = inSample.channels;

            if (m_BufferLeft.read_available >= length && m_BufferRight.read_available >= length && channels > 0)
            {
                unowned float* data = (float*)inSample.data;
                unowned float[] left = (float[])data;
                left.length =(int)length;
                m_BufferLeft.pop (ref left);

                if (channels > 1)
                {
                    unowned float[] right = (float[])(data + length);
                    right.length =(int)length;

                    m_BufferRight.pop (ref right);
                }
            }
        }
    }

    // properties
    private Audio.File      m_File;
    private DecodeThread    m_Thread;
    private double          m_Speed = 1.0;
    private long            m_Position = 0;
    private Maia.Core.Event m_PositionEvent;

    // accessors
    public string filename {
        get {
            return m_File != null ? m_File.filename : null;
        }
        set {
            // stop decoding thread
            m_Thread = null;

            // create new file
            if (value != null)
            {
                m_File = Audio.File.load (value);
            }
            else
            {
                m_File = null;
            }

            // create new decoding thread
            if (m_File != null)
            {
                m_Thread = new DecodeThread (this, sample_rate);
            }
        }
    }

    public long duration {
        get {
            return m_File != null ? m_File.duration : 0;
        }
    }

    public long position {
        get {
            if (m_Thread != null)
            {
                m_Position = m_Thread.position;
            }
            return m_Position;
        }
        set {
            if (position != value)
            {
                if (m_Thread != null)
                {
                    m_Thread.seek (value);
                }
                m_Position = value;
            }
        }
    }

    public uint sample_rate { get; construct; default = 44100; }

    public double speed {
        get {
            return m_Speed;
        }
        set {
            if (m_Speed != value)
            {
                m_Speed = value;
                if (m_Thread != null)
                {
                    m_Thread.speed (m_Speed);
                }
            }
        }
    }

    // events
    public Maia.Core.Event position_event {
        get {
            if (m_PositionEvent == null)
            {
                m_PositionEvent = new Maia.Core.Event ("position-event", this);
            }

            return m_PositionEvent;
        }
    }

    // methods
    public FileSrc (string inName, uint inSampleRate)
    {
        GLib.Object (id: GLib.Quark.from_string (inName), sample_rate: inSampleRate);
    }

    public Audio.Sample?
    process (Audio.Sample inSample)
    {
        if (m_Thread != null)
        {
            m_Thread.fill_sample (inSample);
            m_Thread.step (inSample.length);
        }
        return inSample;
    }
}
