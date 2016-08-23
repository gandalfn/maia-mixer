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

public class MaiaMixer.Audio.Device : Maia.Core.Object
{
    // accessors
    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    public virtual int sample_rate {
        get {
            return 44100;
        }
    }

    public virtual uint32 buffer_size {
        get {
            return 1024;
        }
    }

    // methods
    public Device (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    internal override bool
    can_append_child (Maia.Core.Object inChild)
    {
        return inChild is Port;
    }

    internal override string
    to_string ()
    {
        string ret = "";

        foreach (unowned Maia.Core.Object child in this)
        {
            unowned Port port = child as Port;
            if (port != null)
            {
                ret += port.to_string ();
            }
        }

        return ret;
    }

    public Maia.Core.Array<unowned Channel>
    find_channels (string? inPort = null, string? inPattern = null, Channel.Flags? inFlags = Channel.Flags.INPUT | Channel.Flags.OUTPUT)
    {
        Maia.Core.Array<unowned Channel> channels = new Maia.Core.Array<unowned Channel> ();

        foreach (unowned Maia.Core.Object child in this)
        {
            unowned Port port = child as Port;
            if (port != null &&
                (inPort == null || port.name.has_prefix (inPort)))
            {
                foreach (unowned Maia.Core.Object childPort in port)
                {
                    unowned Channel channel = childPort as Channel;
                    if (channel != null &&
                        (inPattern == null || channel.name.has_prefix (inPattern)) &&
                        (inFlags in channel.flags))
                    {
                        channels.insert (channel);
                    }
                }
            }
        }

        return channels;
    }

    public virtual void
    link (Channel inOutputChannel, Channel inInputChannel) throws Error
    {
        throw new Core.Error.NOT_IMPLEMENTED ("channel link not implemented");
    }

    public virtual void
    start () throws Core.Error
    {
        throw new Core.Error.NOT_IMPLEMENTED ("engine start not implemented");
    }

    public virtual void
    stop () throws Error
    {
        throw new Core.Error.NOT_IMPLEMENTED ("engine start not implemented");
    }
}
