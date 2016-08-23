/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * vu-meter.vala
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

public class MaiaMixer.Widget.VuMeter : Maia.Item, Maia.ItemPackable
{
    // properties
    private EventSample                 m_EventSample;
    private Maia.Core.EventListener     m_EventSampleListener;
    private double                      m_Level;
    private Maia.Graphic.LinearGradient m_Gradient;

    // accessors
    internal override string tag {
        get {
            return "VuMeter";
        }
    }

    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal bool   xshrink { get; set; default = false; }
    internal bool   xlimp   { get; set; default = false; }
    internal double xalign  { get; set; default = 0.5; }

    internal bool   yexpand { get; set; default = true; }
    internal bool   yfill   { get; set; default = true; }
    internal bool   yshrink { get; set; default = false; }
    internal bool   ylimp   { get; set; default = false; }
    internal double yalign  { get; set; default = 0.5; }

    internal double top_padding    { get; set; default = 0; }
    internal double bottom_padding { get; set; default = 0; }
    internal double left_padding   { get; set; default = 0; }
    internal double right_padding  { get; set; default = 0; }

    internal Maia.Graphic.Pattern backcell_pattern { get; set; default = null; }

    public Maia.Orientation orientation { get; set; default = Maia.Orientation.VERTICAL; }

    public double persistence { get; set; default = 0.35; }

    [CCode (notify = false)]
    public EventSample? event_sample {
        get {
            return m_EventSample;
        }
        set {
            if (m_EventSample != value)
            {
                if (m_EventSampleListener != null)
                {
                    m_EventSampleListener.parent = null;
                    m_EventSampleListener = null;
                }
                m_EventSample = value;
                if (m_EventSample != null)
                {
                    m_EventSampleListener = m_EventSample.sample_event.object_subscribe (on_sample_event);
                }
            }
        }
    }

    // methods
    public VuMeter (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private double
    iec_scale (double inDB)
    {
        double def = 0.0;

        if (inDB < -70.0)
            def = 0.0;
        else if (inDB < -60.0)
            def = (inDB + 70.0) * 0.25;
        else if (inDB < -50.0)
            def = (inDB + 60.0) * 0.5 + 2.5;
        else if (inDB < -40.0)
            def = (inDB + 50.0) * 0.75 + 7.5;
        else if (inDB < -30.0)
            def = (inDB + 40.0) * 1.5 + 15.0;
        else if (inDB < -20.0)
            def = (inDB + 30.0) * 2.0 + 30.0;
        else if (inDB < 0.0)
            def = (inDB + 20.0) * 2.5 + 50.0;
        else
            def = 100.0;

        return def / 100.0;
    }

    private void
    on_sample_event (Maia.Core.EventArgs? inArgs)
    {
        unowned EventSample.EventArgs args = (EventSample.EventArgs)inArgs;

        unowned float[] data = args.data;
        if (data.length > 0)
        {
            double peak = 0.0;
            for (int cpt = 0; cpt < data.length; ++cpt)
            {
                peak = double.max (peak, GLib.Math.fabs (data[cpt]));
            }
            double level = iec_scale (20.0 * GLib.Math.log10(peak));
            double moy = double.max (0.0, (m_Level + level) / 2.0);
            if (moy < 0.01) moy = 0.0;
            if (m_Level != moy)
            {
                m_Level = moy;
                if (damaged == null || damaged.is_empty ())
                {
                    damage.post ();
                }
            }
        }
    }

    internal override bool
    can_append_child (Maia.Core.Object inObject)
    {
        return false;
    }

    internal override void
    update (Maia.Graphic.Context inContext, Maia.Graphic.Region inAllocation) throws Maia.Graphic.Error
    {
        base.update (inContext, inAllocation);

        var item_area = area;

        Maia.Graphic.Point start = Maia.Graphic.Point (0, orientation == Maia.Orientation.VERTICAL ? item_area.extents.size.height : 0);
        Maia.Graphic.Point end = Maia.Graphic.Point (orientation == Maia.Orientation.HORIZONTAL ? item_area.extents.size.width : 0, 0);

        m_Gradient = new Maia.Graphic.LinearGradient (start, end);
        m_Gradient.add (new Maia.Graphic.Gradient.ColorStop (0.0, fill_pattern[Maia.State.NORMAL] as Maia.Graphic.Color));
        m_Gradient.add (new Maia.Graphic.Gradient.ColorStop (iec_scale (-70), fill_pattern[Maia.State.NORMAL] as Maia.Graphic.Color));
        m_Gradient.add (new Maia.Graphic.Gradient.ColorStop (iec_scale (-5), fill_pattern[Maia.State.PRELIGHT] as Maia.Graphic.Color));
        m_Gradient.add (new Maia.Graphic.Gradient.ColorStop (iec_scale (0), fill_pattern[Maia.State.ACTIVE] as Maia.Graphic.Color));
        m_Gradient.add (new Maia.Graphic.Gradient.ColorStop (1.0, fill_pattern[Maia.State.ACTIVE] as Maia.Graphic.Color));
    }

    internal override void
    paint (Maia.Graphic.Context inContext, Maia.Graphic.Region inArea) throws Maia.Graphic.Error
    {
        inContext.save ();
        {
            paint_background (inContext);

            var item_size = area.extents.size;

            Maia.Graphic.Path path = new Maia.Graphic.Path ();

            switch (orientation)
            {
                case Maia.Orientation.HORIZONTAL:
                    path.rectangle (0, 0, item_size.width * m_Level, item_size.height, 5.0, 5.0);
                    if (fill_pattern != null)
                    {
                        inContext.pattern = m_Gradient;
                        inContext.fill (path);
                    }
                    break;

                case Maia.Orientation.VERTICAL:
                    path.rectangle (0, item_size.height * (1.0 - m_Level), item_size.width, item_size.height * m_Level, 5.0, 5.0);
                    if (fill_pattern != null)
                    {
                        inContext.pattern = m_Gradient;
                        inContext.fill (path);
                    }
                    break;
            }
        }
        inContext.restore ();
    }
}
