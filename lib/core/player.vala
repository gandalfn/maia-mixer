/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * player.vala
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

public class MaiaMixer.Core.Player : Maia.Core.Object
{
    // types
    public enum State
    {
        NO_MEDIA,
        READY,
        PLAYING,
        PAUSED,
        EOS
    }

    public class StateEventArgs : Maia.Core.EventArgs
    {
        // accessors
        public State state {
            get {
                return (State)(int32)this["state", 0];
            }
        }

        // static methods
        static construct
        {
            Maia.Core.EventArgs.register_protocol (typeof (StateEventArgs).name (),
                                                   "State",
                                                   "message State {"     +
                                                   "     int32 state;"  +
                                                   "}");
        }

        // methods
        public StateEventArgs (State inState)
        {
            this["state", 0] = (int32)inState;
        }
    }

    public class TagsEventArgs : Maia.Core.EventArgs
    {
        // accessors
        public string title {
            owned get {
                return (string)this["title", 0];
            }
        }

        public string artist {
            owned get {
                return (string)this["artist", 0];
            }
        }

        public string album {
            owned get {
                return (string)this["album", 0];
            }
        }

        // static methods
        static construct
        {
            Maia.Core.EventArgs.register_protocol (typeof (TagsEventArgs).name (),
                                                   "Tags",
                                                   "message Tags {"     +
                                                   "     string title [default = \"\"];"  +
                                                   "     string artist [default = \"\"];"  +
                                                   "     string album [default = \"\"];"  +
                                                   "}");
        }

        // methods
        public TagsEventArgs (string? inTitle, string? inArtist, string? inAlbum)
        {
            if (inTitle != null)
            {
                this["title", 0] = inTitle;
            }
            if (inArtist != null)
            {
                this["artist", 0] = inArtist;
            }
            if (inAlbum != null)
            {
                this["album", 0] = inAlbum;
            }
        }
    }

    public class PositionEventArgs : Maia.Core.EventArgs
    {
        // accessors
        public int64 position {
            get {
                return (int64)this["position", 0];
            }
        }

        public int64 duration {
            get {
                return (int64)this["duration", 0];
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
        public PositionEventArgs (int64 inPosition, int64 inDuration)
        {
            this["position", 0] = inPosition;
            this["duration", 0] = inDuration;
        }
    }

    // properties
    private Maia.Core.Event m_StateEvent;
    private Maia.Core.Event m_PositionEvent;
    private Maia.Core.Event m_TagsEvent;

    // accessors
    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    [CCode (notify = false)]
    public virtual Engine engine { get; construct; default = null; }

    public virtual string uri { owned get; set; }

    public virtual State state {
        get {
            return State.NO_MEDIA;
        }
    }

    public virtual int64 position {
        get {
            return 0;
        }
        set {
        }
    }

    public virtual int64 duration {
        get {
            return 0;
        }
    }

    public virtual double rate {
        get {
            return 1.0;
        }
        set {

        }
    }

    public virtual int volume {
        get {
            return 100;
        }
        set {

        }
    }

    public virtual unowned Core.OutputPort? left_port {
        get {
            return null;
        }
    }

    public virtual unowned Core.OutputPort? right_port {
        get {
            return null;
        }
    }

    // events
    public Maia.Core.Event state_event {
        get {
            if (m_StateEvent == null)
            {
                m_StateEvent = new Maia.Core.Event ("state-event", this);
            }

            return m_StateEvent;
        }
    }

    public Maia.Core.Event position_event {
        get {
            if (m_PositionEvent == null)
            {
                m_PositionEvent = new Maia.Core.Event ("position-event", this);
            }

            return m_PositionEvent;
        }
    }

    public Maia.Core.Event tags_event {
        get {
            if (m_TagsEvent == null)
            {
                m_TagsEvent = new Maia.Core.Event ("tags-event", this);
            }

            return m_TagsEvent;
        }
    }

    // methods
    public Player (string inId, Engine inEngine)
    {
        GLib.Object (id: GLib.Quark.from_string (inId), engine: inEngine);
    }

    public virtual void
    play () throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("port link not implemented");
    }

    public virtual void
    pause () throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("port link not implemented");

    }

    public virtual void
    stop () throws Error
    {
        throw new Error.NOT_IMPLEMENTED ("port link not implemented");
    }
}
