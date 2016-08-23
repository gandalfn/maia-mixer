/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * init.vala
 * Copyright (C) Nicolas Bruguier 2010-2013 <gandalfn@club-internet.fr>
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

namespace MaiaMixer.Soundtouch
{
    [CCode (cname = "backend_load")]
    public void backend_load ()
    {
        Maia.Core.Any.delegate (typeof (MaiaMixer.Filters.BPMDetect), typeof (MaiaMixer.Soundtouch.BPMDetect));
    }

    [CCode (cname = "backend_unload")]
    public void backend_unload ()
    {
        Maia.Core.Any.undelegate (typeof (MaiaMixer.Filters.BPMDetect));
    }
}
