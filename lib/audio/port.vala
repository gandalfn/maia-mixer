/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * port.vala
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

public abstract class MaiaMixer.Audio.Port : Maia.Core.Object
{
    // properties
    private unowned SampleNotification? m_SampleNotification;

    // accessors
    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    public uint channels {
        get {
            uint ret = 0;

            foreach (unowned Maia.Core.Object child in this)
            {
                if (child is Channel)
                {
                    ret++;
                }
            }

            return ret;
        }
    }

    // notifications
    public SampleNotification new_sample {
        get {
            if (m_SampleNotification == null)
            {
                SampleNotification new_notification = new SampleNotification("new-sample");
                m_SampleNotification = notifications.add (new_notification) as SampleNotification;
            }
            return m_SampleNotification;
        }
    }

    // methods
    internal override bool
    can_append_child (Maia.Core.Object inObject)
    {
        return inObject is Channel;
    }
}
