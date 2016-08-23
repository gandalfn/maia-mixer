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

public class MaiaMixer.Core.Engine : Maia.Core.Object
{
    // properties
    public Audio.Port m_Port;

    // accessors
    public string name {
        owned get {
            return ((GLib.Quark)id).to_string ();
        }
    }

    // methods
    public Engine (string inId, Audio.Port inPort)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));

        m_Port = inPort;
        m_Port.new_sample.add_object_observer (on_new_sample);
    }

    private void
    on_new_sample (Maia.Core.Notification inNotification)
    {
        unowned Audio.SampleNotification? notification = (Audio.SampleNotification)inNotification;
        if (notification != null)
        {
            foreach (unowned Maia.Core.Object child in this)
            {
                unowned Element? element = child as Element;
                if (element != null)
                {
                    var new_sample = element.process (notification.sample);
                    notification.sample = new_sample;
                }
            }
        }
    }

    internal override bool
    can_append_child (Maia.Core.Object inChild)
    {
        return inChild is Element;
    }
}
