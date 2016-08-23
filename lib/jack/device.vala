/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * device.vala
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

public class MaiaMixer.Jack.NewFramesNotification : Maia.Core.Notification
{
    [CCode (notify = false)]
    public uint n_frames { get; set; default = 0; }

    public NewFramesNotification (string inName)
    {
        base (inName);
    }

    public new void
    post (uint inNFrames)
    {
        n_frames = inNFrames;
        base.post ();
    }
}

public class MaiaMixer.Jack.Device : MaiaMixer.Audio.Device
{
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
    private global::Jack.Client?           m_Client = null;
    private Maia.Core.Event                m_JackPortAdded;
    private Maia.Core.Event                m_JackPortRemoved;
    private unowned NewFramesNotification? m_NewFramesNotification;

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

    public override uint32 buffer_size {
        get {
            return m_Client != null ? m_Client.buffer_size : 1024;
        }
    }

    // notifications
    public NewFramesNotification new_frames {
        get {
            if (m_NewFramesNotification == null)
            {
                NewFramesNotification new_notification = new NewFramesNotification("new-frames");
                m_NewFramesNotification = notifications.add (new_notification) as NewFramesNotification;
            }
            return m_NewFramesNotification;
        }
    }

    // methods
    public Device (string inId)
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
        // Get input port
        unowned string[] port_names = m_Client.get_ports (null, global::Jack.DEFAULT_AUDIO_TYPE, global::Jack.Port.Flags.IsInput);
        foreach (unowned string port_name in port_names)
        {
            // Get port
            unowned global::Jack.Port jack_port = m_Client.port_by_name (port_name);
            // Create channel for jack port
            var channel = new Channel (jack_port);

            // Search if port exist
            unowned InputAudioPort? port = find (GLib.Quark.from_string (jack_port.owner)) as InputAudioPort;
            if (port == null)
            {
                var new_port = new InputAudioPort (jack_port.owner);
                add (new_port);
                port = new_port;
            }

            // Add channel to port
            port.add (channel);
        }

        port_names = m_Client.get_ports (null, global::Jack.DEFAULT_AUDIO_TYPE, global::Jack.Port.Flags.IsOutput);
        foreach (unowned string port_name in port_names)
        {
            // Get port
            unowned global::Jack.Port jack_port = m_Client.port_by_name (port_name);
            // Create channel for jack port
            var channel = new Channel (jack_port);

            // Search if port exist
            unowned OutputAudioPort? port = find (GLib.Quark.from_string (jack_port.owner)) as OutputAudioPort;
            if (port == null)
            {
                var new_port = new OutputAudioPort (jack_port.owner);
                add (new_port);
                port = new_port;
            }

            // Add channel to port
            port.add (channel);
        }
    }

    private int
    on_process (global::Jack.NFrames inNFrames)
    {
        m_NewFramesNotification.post (inNFrames);

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
                    // Create channel for jack port
                    var channel = new Channel (jack_port);

                    // Search if port exist
                    unowned InputAudioPort? port = find (GLib.Quark.from_string (jack_port.owner)) as InputAudioPort;
                    if (port == null)
                    {
                        var new_port = new InputAudioPort (jack_port.owner);
                        add (new_port);
                        port = new_port;
                    }

                    // Add channel to port
                    port.add (channel);
                }
                else if (global::Jack.Port.Flags.IsOutput in jack_port.flags)
                {
                    // Create channel for jack port
                    var channel = new Channel (jack_port);

                    // Search if port exist
                    unowned OutputAudioPort? port = find (GLib.Quark.from_string (jack_port.owner)) as OutputAudioPort;
                    if (port == null)
                    {
                        var new_port = new OutputAudioPort (jack_port.owner);
                        add (new_port);
                        port = new_port;
                    }

                    // Add channel to port
                    port.add (channel);
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
            // Search corresponding channels
            Maia.Core.Array<unowned Audio.Channel> channels = find_channels (args.owner, args.name);

            foreach (unowned Audio.Channel channel in channels)
            {
                unowned Audio.Port port = channel.parent as Audio.Port;

                if (port != null)
                {
                    // Remove channel from port
                    channel.parent = null;
                    // if port is empty remove it from device
                    if (port.first () == null)
                    {
                        port.parent = null;
                    }
                }
            }
        }
    }

    internal override bool
    can_append_child (Maia.Core.Object inChild)
    {
        return m_Client != null && base.can_append_child (inChild);
    }

    internal override void
    link (Audio.Channel inOutputChannel, Audio.Channel inInputChannel) throws Core.Error
        requires (Audio.Channel.Flags.OUTPUT in inOutputChannel.flags)
        requires (inOutputChannel.parent != null)
        requires (Audio.Channel.Flags.INPUT in inInputChannel.flags)
        requires (inInputChannel.parent != null)
    {
        unowned Audio.Port outputPort = inOutputChannel.parent as Audio.Port;
        string outputName = outputPort.name + ":" + inOutputChannel.name;
        if (Audio.Channel.Flags.IS_MINE in inOutputChannel.flags)
        {
            unowned Audio.Device? device = outputPort.parent as Audio.Device;
            if (device != null)
            {
                outputName = device.name + ":" + outputPort.name + "-" + inOutputChannel.name;
            }
        }

        unowned Audio.Port inputPort = inInputChannel.parent as Audio.Port;
        string inputName = inputPort.name + ":" + inInputChannel.name;
        if (Audio.Channel.Flags.IS_MINE in inInputChannel.flags)
        {
            unowned Audio.Device? device = inputPort.parent as Audio.Device;
            if (device != null)
            {
                inputName = device.name + ":" + inputPort.name + "-" + inInputChannel.name;
            }
        }

        m_Client.connect (outputName, inputName);
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
