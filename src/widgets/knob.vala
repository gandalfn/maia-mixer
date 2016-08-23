/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * knob.vala
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

public class MaiaMixer.Widget.Knob : Maia.Item, Maia.ItemPackable, Maia.ItemFocusable
{
    // properties
    private Maia.FocusGroup  m_FocusGroup = null;
    private Maia.Adjustment? m_Adjustment = null;

    // accessors
    internal override string tag {
        get {
            return "Knob";
        }
    }

    internal uint   row     { get; set; default = 0; }
    internal uint   column  { get; set; default = 0; }
    internal uint   rows    { get; set; default = 1; }
    internal uint   columns { get; set; default = 1; }

    internal bool   xexpand { get; set; default = true; }
    internal bool   xfill   { get; set; default = true; }
    internal bool   xshrink { get; set; default = true; }
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

    internal bool can_focus   { get; set; default = true; }
    internal bool have_focus  { get; set; default = false; }
    internal int  focus_order { get; set; default = -1; }

    internal Maia.FocusGroup focus_group {
        get {
            return m_FocusGroup;
        }
        set {
            if (m_FocusGroup != null)
            {
                m_FocusGroup.remove (this);
            }

            m_FocusGroup = value;

            if (m_FocusGroup != null)
            {
                m_FocusGroup.add (this);
            }
        }
        default = null;
    }

    public Maia.Adjustment? adjustment {
        get {
            return m_Adjustment;
        }
        set {
            if (m_Adjustment != null)
            {
                m_Adjustment.notify["value"].disconnect (on_adjustment_changed);
                m_Adjustment.notify["lower"].disconnect (on_adjustment_changed);
                m_Adjustment.notify["upper"].disconnect (on_adjustment_changed);
                m_Adjustment.notify["page-size"].disconnect (on_adjustment_changed);
            }
            m_Adjustment = value;
            if (m_Adjustment != null)
            {
                m_Adjustment.notify["value"].connect (on_adjustment_changed);
                m_Adjustment.notify["lower"].connect (on_adjustment_changed);
                m_Adjustment.notify["upper"].connect (on_adjustment_changed);
                m_Adjustment.notify["page-size"].connect (on_adjustment_changed);
            }
        }
    }

    public double border { get; set; default = 5.0; }

    // methods
    construct
    {
        not_dumpable_attributes.insert ("adjustment");

        // Default colors
        background_pattern[Maia.State.NORMAL] = new Maia.Graphic.Color (1, 1, 1);
        stroke_pattern[Maia.State.NORMAL]     = new Maia.Graphic.Color (0, 0, 0);
        fill_pattern[Maia.State.NORMAL]       = new Maia.Graphic.Color (0.6, 0.6, 0.6);
    }

    public Knob (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    on_adjustment_changed ()
    {
        damage.post ();
    }

    internal override bool
    can_append_child (Maia.Core.Object inObject)
    {
        return false;
    }

    internal override void
    paint (Maia.Graphic.Context inContext, Maia.Graphic.Region inArea) throws Maia.Graphic.Error
    {
        inContext.save ();
        {
            Maia.Graphic.Point center = Maia.Graphic.Point (area.extents.size.width / 2.0, area.extents.size.height / 2.0);

            // Get lowest size to determine to knob area
            double radius = double.min (center.x, center.y);

            // Graduation stpep
            double step = GLib.Math.PI / 6.5;

            // Calculate rate
            double percent = 0.0;
            if (m_Adjustment != null)
            {
                percent = (m_Adjustment.@value - m_Adjustment.lower) / (m_Adjustment.upper - m_Adjustment.lower);
            }

            // Draw border graduations
            for (int cpt = 0; cpt < 10; ++cpt)
            {
                var angle = (GLib.Math.PI / 2.0) + ((4.5 - cpt) * step);
                var transform = new Maia.Graphic.Transform.init_rotate (-angle);

                var path = new Maia.Graphic.Path ();
                path.arc (center.x + radius - (border / 2.0), center.y, border / 4.0, border / 4.0, 0, 2 * GLib.Math.PI);

                inContext.save ();
                {
                    inContext.translate (center);
                    inContext.transform = transform;
                    inContext.translate (center.invert ());

                    inContext.pattern = fill_pattern[cpt <= GLib.Math.floor ((percent * 10.0) - 0.5) ? Maia.State.ACTIVE : Maia.State.NORMAL] ?? new Maia.Graphic.Color (0.7, 0.7, 0.7);
                    inContext.fill (path);
                }
                inContext.restore ();
            }

            // Draw knob
            inContext.save ();
            {
                var path = new Maia.Graphic.Path ();
                path.arc (center.x, center.y, radius - border, radius - border, 0, 2 * GLib.Math.PI);
                inContext.pattern = stroke_pattern[state] ?? new Maia.Graphic.Color (0.7, 0.7, 0.7);
                inContext.stroke (path);

                path = new Maia.Graphic.Path ();
                path.move_to (center.x, center.y);
                path.line_to (center.x + radius - border, center.y);

                var angle = (GLib.Math.PI / 2.0) + ((4.5 - (percent * 10.0) + 0.5) * step);
                var transform = new Maia.Graphic.Transform.init_rotate (-angle);

                inContext.translate (center);
                inContext.transform = transform;
                inContext.translate (center.invert ());

                inContext.pattern = stroke_pattern[Maia.State.ACTIVE] ?? new Maia.Graphic.Color (0.7, 0.7, 0.7);
                inContext.stroke (path);
            }
            inContext.restore ();
        }
        inContext.restore ();
    }

    internal override bool
    on_button_press_event (uint inButton, Maia.Graphic.Point inPoint)
    {
        bool ret = inPoint in area;

        if (ret && inButton >= 4)
        {
            grab_pointer (this);
        }

        return ret;
    }

    internal override bool
    on_button_release_event (uint inButton, Maia.Graphic.Point inPoint)
    {
        bool ret = inPoint in area;

        if (inButton >= 4)
        {
            ungrab_pointer (this);
        }

        return ret;
    }

    internal override bool
    on_scroll_event (Maia.Scroll inScroll, Maia.Graphic.Point inPoint)
    {
        bool ret = inPoint in area;

        if (ret && m_Adjustment != null)
        {
            switch (inScroll)
            {
                case Maia.Scroll.UP:
                    m_Adjustment.@value += 0.01 * (m_Adjustment.upper - m_Adjustment.lower);
                    break;

                case Maia.Scroll.DOWN:
                    m_Adjustment.@value -= 0.01 * (m_Adjustment.upper - m_Adjustment.lower);
                    break;
            }
        }

        return ret;
    }
}
