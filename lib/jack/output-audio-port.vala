/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * output-audio-port.vala
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

public class MaiaMixer.Jack.OutputAudioPort : MaiaMixer.Audio.OutputPort
{
    // properties
    private unowned Device? m_Device = null;

    // accessors
    public override unowned Maia.Core.Object? parent {
        get {
            return base.parent;
        }
        construct set {
            lock (m_Device)
            {
                if (m_Device != null)
                {
                    // Remove all registerd channel from current device
                    foreach (unowned Maia.Core.Object child in this)
                    {
                        unowned Channel? channel = child as Channel;
                        // Only unregister owned channel
                        if (channel != null && channel.port != null && Audio.Channel.Flags.IS_MINE in channel.flags)
                        {
                            m_Device.jack.port_unregister (channel.port);
                            channel.port = null;
                        }
                    }

                    // disconnect from new frames
                    m_Device.new_frames.remove_observer (on_new_frames);
                    m_Device = null;
                }

                base.parent = value;

                if (parent != null && parent is Device)
                {
                    // Set the new device
                    m_Device = parent as Device;

                    // Register all channel in device
                    foreach (unowned Maia.Core.Object child in this)
                    {
                        unowned Channel? channel = child as Channel;
                        // Channel without port has owned channel
                        if (channel != null && channel.port == null)
                        {
                            channel.port = m_Device.jack.port_register (name + "-" + channel.name, global::Jack.DEFAULT_AUDIO_TYPE,
                                                                        global::Jack.Port.Flags.IsOutput, m_Device.buffer_size);
                            channel.flags |= Audio.Channel.Flags.IS_MINE;
                        }
                    }

                    // Connect to device new frames notification
                    m_Device.new_frames.add_object_observer (on_new_frames);
                }
            }
        }
    }
    // methods
    public OutputAudioPort (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    on_new_frames (Maia.Core.Notification inNotification)
    {
        unowned NewFramesNotification? notification = (NewFramesNotification)inNotification;
        if (notification != null)
        {
            lock (m_Device)
            {
                if (m_Device != null)
                {
                    bool need_sample = false;

                    // Check if a channel needs data
                    foreach (unowned Maia.Core.Object child in this)
                    {
                        unowned Channel? channel = child as Channel;
                        if (channel != null && channel.port != null && Audio.Channel.Flags.IS_MINE in channel.flags)
                        {
                            need_sample |= channel.buffered_data_available < notification.n_frames;
                        }
                    }

                    Audio.Sample sample = new Audio.Sample (2, notification.n_frames, m_Device.sample_rate);
                    if (need_sample)
                    {
                        // Post new sample notification
                        new_sample.post (sample);

                        // Get sample from notification
                        sample = new_sample.sample;
                    }

                    // Process all channels
                    uint channel_num = 0;
                    foreach (unowned Maia.Core.Object child in this)
                    {
                        unowned Channel? channel = child as Channel;
                        if (channel != null && channel.port != null && Audio.Channel.Flags.IS_MINE in channel.flags)
                        {
                            // Push sample if any in channel buffer
                            if (sample != null && channel_num < sample.channels)
                            {
                                channel.push (sample.get_channel_data (channel_num));
                            }

                            // Write buffered data in channel
                            channel.write (notification.n_frames);
                            channel_num++;
                        }
                    }
                }
            }
        }
    }

    internal override bool
    can_append_child (Maia.Core.Object inObject)
    {
        return inObject is Channel;
    }

    internal override void
    insert_child (Maia.Core.Object inObject)
    {
        base.insert_child (inObject);

        if (inObject is Channel)
        {
            lock (m_Device)
            {
                unowned Channel? channel = inObject as Channel;
                // register a new jack port for channel without (owned)
                if (channel.port == null && m_Device != null)
                {
                    channel.port = m_Device.jack.port_register (name + "-" + channel.name, global::Jack.DEFAULT_AUDIO_TYPE,
                                                                global::Jack.Port.Flags.IsOutput, m_Device.buffer_size);
                    channel.flags |= Audio.Channel.Flags.IS_MINE;
                }
            }
        }
    }

    internal override void
    remove_child (Maia.Core.Object inObject)
    {
        if (inObject in this && inObject is Channel)
        {
            lock (m_Device)
            {
                if (m_Device != null)
                {
                    unowned Channel? channel = inObject as Channel;

                    // unregister owned channel
                    if (channel.port != null && channel.port != null && Audio.Channel.Flags.IS_MINE in channel.flags)
                    {
                        m_Device.jack.port_unregister (channel.port);
                        channel.port = null;
                    }
                }
            }
        }

        base.remove_child (inObject);
    }
}
