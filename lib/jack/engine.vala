/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * engine.vala
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
public class MaiaMixer.Jack.Engine : MaiaMixer.Core.Engine
{
    // types
    public class PortEventArgs : Maia.Core.EventArgs
    {
        // accessors
        public string name {
            owned get {
                return (string)this["name", 0];
            }
        }

        public string owner {
            owned get {
                return (string)this["owner", 0];
            }
        }

        // static methods
        static construct
        {
            Maia.Core.EventArgs.register_protocol (typeof (PortEventArgs).name (),
                                                   "Port",
                                                   "message Port {"     +
                                                   "     string name;"  +
                                                   "     string owner;" +
                                                   "}");
        }

        // methods
        public PortEventArgs (string inName, string inOwner)
        {
            this["name", 0] = inName;
            this["owner", 0] = inOwner;
        }
    }

    // properties
    private global::Jack.Client? m_Client = null;
    private Maia.Core.Event m_JackPortAdded;
    private Maia.Core.Event m_JackPortRemoved;

    // accessors
    internal override int sample_rate {
        get {
            return m_Client == null ? 44000 : (int)m_Client.sample_rate;
        }
    }

    public unowned global::Jack.Client? jack {
        get {
            return m_Client;
        }
    }

    public uint32 buffer_size {
        get {
            return m_Client != null ? m_Client.buffer_size : 0;
        }
    }

    // methods
    public Engine (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    internal override void
    delegate_construct ()
    {
        global::Jack.Status status;
        m_Client = new global::Jack.Client (name, global::Jack.Options.NoStartServer, out status);
        if (m_Client != null)
        {
            get_audio_ports ();

            m_JackPortAdded = new Maia.Core.Event ("jack-port-added", this);
            m_JackPortRemoved = new Maia.Core.Event ("jack-port-removed", this);

            m_JackPortAdded.object_subscribe (on_port_added_event);
            m_JackPortRemoved.object_subscribe (on_port_removed_event);

            m_Client.set_process_callback (on_process);

            m_Client.set_port_registration_callback (on_port_registered);
        }
    }

    private void
    get_audio_ports ()
    {
        unowned string[] port_names = m_Client.get_ports (null, global::Jack.DEFAULT_AUDIO_TYPE, global::Jack.Port.Flags.IsInput);
        foreach (unowned string port_name in port_names)
        {
            unowned global::Jack.Port jack_port = m_Client.port_by_name (port_name);
            InputAudioPort port  = new InputAudioPort.external (jack_port);
            add (port);
        }

        port_names = m_Client.get_ports (null, global::Jack.DEFAULT_AUDIO_TYPE, global::Jack.Port.Flags.IsOutput);
        foreach (unowned string port_name in port_names)
        {
            unowned global::Jack.Port jack_port = m_Client.port_by_name (port_name);
            OutputAudioPort port  = new OutputAudioPort.external (jack_port);
            add (port);
        }
    }

    private int
    on_process (global::Jack.NFrames inNFrames)
    {
        new_frames.post (inNFrames);

        return 0;
    }

    private void
    on_port_registered (global::Jack.PortId inPortId, bool inRegistered)
    {
        unowned global::Jack.Port jack_port = m_Client.port_by_id (inPortId);

        if (!m_Client.port_is_mine (jack_port))
        {
            PortEventArgs args = new PortEventArgs (jack_port.short_name, jack_port.owner);

            if (inRegistered)
            {
                m_JackPortAdded.publish (args);
            }
            else
            {
                m_JackPortRemoved.publish (args);
            }
        }
    }

    private void
    on_port_added_event (Maia.Core.EventArgs? inArgs)
    {
        unowned PortEventArgs? args = (PortEventArgs)inArgs;

        if (args != null)
        {
            unowned global::Jack.Port? jack_port = m_Client.port_by_name (args.owner + ":" + args.name);
            if (jack_port != null && !m_Client.port_is_mine (jack_port))
            {
                if (global::Jack.Port.Flags.IsInput in jack_port.flags)
                {
                    InputAudioPort port  = new InputAudioPort.external (jack_port);
                    add (port);
                }
                else if (global::Jack.Port.Flags.IsOutput in jack_port.flags)
                {
                    OutputAudioPort port  = new OutputAudioPort.external (jack_port);
                    add (port);
                }
            }
        }
    }

    private void
    on_port_removed_event (Maia.Core.EventArgs? inArgs)
    {
        unowned PortEventArgs args = (PortEventArgs)inArgs;

        if (args != null)
        {
            Maia.Core.Array<unowned Port> ports = find_ports<Port> (args.owner, args.name);

            foreach (unowned Port port in ports)
            {
                port.parent = null;
            }
        }
    }

    internal override bool
    can_append_child (Maia.Core.Object inChild)
    {
        return m_Client != null && base.can_append_child (inChild);
    }

    internal override void
    insert_child (Maia.Core.Object inChild)
    {
        if (can_append_child (inChild))
        {
            base.insert_child (inChild);

            if (inChild is Port)
            {
                unowned Port? port = inChild as Port;

                port.registering (this);

                port_added.post (port);
            }
        }
    }

    internal override void
    remove_child (Maia.Core.Object inChild)
    {
        if (inChild in this)
        {
            base.remove_child (inChild);

            if (inChild is Port)
            {
                unowned Port? port = inChild as Port;

                if (port.port != null && m_Client.port_is_mine (port.port))
                {
                    port.unregistering (this);
                }

                port_removed.post (port);
            }
        }
    }

    internal override void
    link (Core.OutputPort inOutputPort, Core.InputPort inInputPort)
        requires (inOutputPort is Port)
        requires (inInputPort is Port)
    {
        m_Client.connect (inOutputPort.owner + ":" + inOutputPort.name, inInputPort.owner + ":" + inInputPort.name);
    }

    internal override void
    start ()
    {
        m_Client.activate ();
    }

    internal override void
    stop ()
    {
        m_Client.deactivate ();
    }
}
