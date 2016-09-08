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

namespace MaiaMixer.FFMpeg
{
    [CCode (cname = "backend_load")]
    public void backend_load ()
    {
        Av.Format.register_all ();
        Av.Codec.register_all ();

        Maia.Core.Any.delegate (typeof (MaiaMixer.Audio.FileMpeg), typeof (MaiaMixer.FFMpeg.FileMpeg));
        Maia.Core.Any.delegate (typeof (MaiaMixer.Audio.FileMp4), typeof (MaiaMixer.FFMpeg.FileMp4));
        //Maia.Core.Any.delegate (typeof (MaiaMixer.Filters.Resample), typeof (MaiaMixer.FFMpeg.Resample));
    }

    [CCode (cname = "backend_unload")]
    public void backend_unload ()
    {
        Maia.Core.Any.undelegate (typeof (MaiaMixer.Audio.FileMpeg));
        Maia.Core.Any.undelegate (typeof (MaiaMixer.Audio.FileMp4));
        //Maia.Core.Any.undelegate (typeof (MaiaMixer.Filters.Resample));
    }
}
