/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * scope.vala
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

public class MaiaMixer.Widget.Scope : Maia.Item, Maia.ItemPackable
{
    // properties
    private EventSample                m_EventSample;
    private Maia.Core.EventListener    m_EventSampleListener;
    private Maia.Graphic.Surface       m_Backbuffer;
    private Maia.Graphic.Surface       m_Background;
    private Maia.Graphic.Path          m_PathFront;
    private Maia.Graphic.Path          m_PathBack;
    private double                     m_Trigger = 0.0;
    private unowned Maia.Graphic.Path? m_Index = null;
    private bool                       m_HaveUpdate = false;

    // accessors
    internal override string tag {
        get {
            return "Scope";
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

    public int step { get; set; default = 8; }
    public int frames { get; set; default = 1024; }
    public double persistence { get; set; default = 0.65; }
    public bool trigger { get; set; default = false; }

    // methods
    construct
    {
        create_path ();

        notify["step"].connect (create_path);
        notify["frames"].connect (create_path);
    }

    public Scope (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }

    private void
    create_path ()
    {
        m_PathBack = new Maia.Graphic.Path ();
        m_PathFront = new Maia.Graphic.Path ();

        for (int cpt = 0; cpt < frames / step; cpt++)
        {
            if (cpt == 0)
            {
                m_PathBack.move_to ((double)cpt / (double)(frames / step), 0.0);
                m_PathFront.move_to ((double)cpt / (double)(frames / step), 0.0);
            }
            else
            {
                m_PathBack.line_to ((double)cpt / (double)(frames / step), 0.0);
                m_PathFront.line_to ((double)cpt / (double)(frames / step), 0.0);
            }
        }
    }

    private void
    on_sample_event (Maia.Core.EventArgs? inArgs)
    {
        unowned EventSample.EventArgs args = (EventSample.EventArgs)inArgs;

        unowned float[] data = args.data;
        int triggerValue = 0;

        if (m_Index == null)
        {
            if (trigger)
            {
                float prev = 0;
                for (int cpt = 0; cpt < data.length; cpt += step)
                {
                    float val = 0;
                    for (int i = 0; i < step; ++i)
                    {
                        val += data[i + cpt];
                    }
                    val /= (float)step;
                    if (cpt > 0 && prev >= m_Trigger && val <= m_Trigger)
                    {
                        triggerValue = cpt;
                        break;
                    }
                    prev = val;
                }
            }

            m_Index = m_PathBack.first () as Maia.Graphic.Path;
            m_HaveUpdate = false;
        }

        for (int cpt = triggerValue; cpt < data.length && m_Index != null; cpt += step, m_Index = m_Index.next () as Maia.Graphic.Path)
        {
            float val = 0;
            int i = 0;
            for (i = 0; i < step && i + cpt < data.length; ++i)
            {
                val += data[i + cpt];
            }
            val /= (float)i;
            unowned Maia.Graphic.Point? point = m_Index[0];
            if ((float)point.y != val)
            {
                point.y = (double)val;
                m_HaveUpdate = true;
            }
        }

        if (m_HaveUpdate && m_Index == null && (damaged == null || damaged.is_empty ()))
        {
            var tmp = m_PathFront;
            m_PathFront = m_PathBack;
            m_PathBack = tmp;
            damage.post ();
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

        m_Backbuffer = new Maia.Graphic.Surface.similar (inContext.surface, (uint)GLib.Math.ceil (area.extents.size.width), (uint)GLib.Math.ceil (area.extents.size.height));
        m_Backbuffer.clear ();

        m_Background = null;
        if (background_pattern != null)
        {
            m_Background = new Maia.Graphic.Surface.similar (inContext.surface, (uint)GLib.Math.ceil (area.extents.size.width), (uint)GLib.Math.ceil (area.extents.size.height));
            m_Background.clear ();

            var ctx = m_Background.context;
            ctx.save ();
            unowned Maia.Graphic.Image? image = background_pattern[state] as Maia.Graphic.Image;
            if (image != null)
            {
                var item_area = area;
                Maia.Graphic.Size image_size = image.size;
                var transform = new Maia.Graphic.Transform.init_scale (image_size.width / item_area.extents.size.width,
                                                                       image_size.height / item_area.extents.size.height);
                image.transform = transform;
                ctx.pattern = background_pattern[state];
            }
            else
            {
                ctx.pattern = background_pattern[state];
            }

            ctx.paint ();
            ctx.restore ();

            m_Backbuffer.context.pattern = m_Background;
            m_Backbuffer.context.paint ();
        }
    }

    internal override void
    paint (Maia.Graphic.Context inContext, Maia.Graphic.Region inArea) throws Maia.Graphic.Error
    {
        var ctx = m_Backbuffer.context;
        ctx.save ();
        {
            if (m_Background != null)
            {
                ctx.pattern = m_Background;
                ctx.paint_with_alpha (1.0 - persistence);
            }

            if (m_PathFront != null)
            {
                var item_size = area.extents.size;

                ctx.line_join = Maia.Graphic.LineJoin.ROUND;
                ctx.line_cap = Maia.Graphic.LineCap.ROUND;

                ctx.line_width = 1.0 * line_width / item_size.height;
                ctx.pattern = stroke_pattern[state];

                var transform = new Maia.Graphic.Transform.identity ();
                transform.translate (0, item_size.height / 2.0);
                transform.scale (item_size.width, item_size.height / 2.0);
                ctx.transform = transform;
                ctx.stroke (m_PathFront);
            }
        }
        ctx.restore ();

        inContext.save ();
        {
            inContext.pattern = m_Backbuffer;
            inContext.paint ();
        }
        inContext.restore ();
    }
}
