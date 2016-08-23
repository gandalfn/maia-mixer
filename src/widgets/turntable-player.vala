/* -*- Mode: Vala; indent-tabs-mode: nil; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * turntable-player.vala
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

public class MaiaMixer.Widget.TurntablePlayer : Maia.Grid
{
    // properties
    private Core.FileSrc?             m_FileSrc = null;
    private Maia.Adjustment           m_Adjustment = null;
    private unowned Maia.Image        m_Vinyl = null;
    private unowned Maia.Image        m_Handle = null;
    private unowned Maia.ToggleButton m_PlayPauseButton = null;
    private unowned Widget.Knob       m_SpeedButton = null;
    private unowned Maia.Label        m_LabelURI = null;
    private unowned Maia.Label        m_LabelDuration = null;
    private Maia.Graphic.Surface      m_VinylSurface = null;
    private Maia.Graphic.Surface      m_HandleSurface = null;
    private bool                      m_InMove = false;
    private Maia.Core.EventListener   m_PositionEventListerner = null;
    private long                      m_LastTurnTime;
    private double                    m_CurrentTurnPos = 0.0;

    // accessors
    internal override string tag {
        get {
            return "TurntablePlayer";
        }
    }

    [CCode (notify = false)]
    public Core.FileSrc? file_src {
        get {
            return m_FileSrc;
        }
        set {
            if (m_FileSrc != value)
            {
                if (m_FileSrc != null)
                {
                    m_FileSrc.notify["filename"].connect (on_filename_changed);
                    if (m_PositionEventListerner != null)
                    {
                        m_PositionEventListerner.parent = null;
                        m_PositionEventListerner = null;
                    }
                }
                m_FileSrc = value;
                if (m_FileSrc != null)
                {
                    m_FileSrc.notify["filename"].connect (on_filename_changed);
                    m_PositionEventListerner = m_FileSrc.position_event.object_subscribe (on_position_changed);
                    m_FileSrc.speed = m_SpeedButton.adjustment.value;

                    on_filename_changed ();
                }
            }
        }
    }

    public string font_description { get; set; default = "Sans 12"; }

    public double vinyl_size {
        get {
            return m_Vinyl.size.width;
        }
        set {
            m_Vinyl.size = Maia.Graphic.Size (value, value);
            m_Handle.size = Maia.Graphic.Size (32, value);
        }
        default = 400;
    }

    public double handle_size { get; set; default = 16; }

    public string play_icon_filename { get; set; default = null; }

    public string pause_icon_filename { get; set; default = null; }

    public Maia.Graphic.Pattern vinyl_pattern { get; set; default = null; }

    public Maia.Graphic.Pattern handle_pattern { get; set; default = null; }

    // methods
    construct
    {
        // Set default spacing
        row_spacing = 5;
        column_spacing = 5;

        // Create timeline
        Maia.Application.default.new_frame.add_object_observer (on_new_frame);

        // Create adjustment
        m_Adjustment = new Maia.Adjustment ();
        m_Adjustment.notify["value"].connect (on_adjustment_value_changed);
        m_Adjustment.notify["lower"].connect (on_adjustment_changed);
        m_Adjustment.notify["upper"].connect (on_adjustment_changed);
        m_Adjustment.notify["page-size"].connect (on_adjustment_changed);

        // Create label uri
        var label_uri = new Maia.Label (@"$(name)-label-uri", "");
        label_uri.columns = 2;
        label_uri.xfill = false;
        label_uri.xexpand = false;
        label_uri.xshrink = true;
        label_uri.yfill = false;
        label_uri.alignment = Maia.Graphic.Glyph.Alignment.LEFT;
        label_uri.state = Maia.State.ACTIVE;
        add (label_uri);
        m_LabelURI = label_uri;

        // Create vinyl image
        var vinyl_image = new Maia.Image ("$(name)-vinyl", null);
        vinyl_image.row = 1;
        vinyl_image.xfill = false;
        vinyl_image.xexpand = false;
        add (vinyl_image);
        m_Vinyl = vinyl_image;

        // Create handle image
        var handle_image = new Maia.Image ("$(name)-handle", null);
        handle_image.row = 1;
        handle_image.column = 1;
        handle_image.xexpand = false;
        handle_image.xfill = false;
        handle_image.size = Maia.Graphic.Size (24, 24);
        add (handle_image);
        m_Handle = handle_image;

        // Create button play pause
        var button_play_pause = new Maia.ToggleButton (@"$(name)-play-pause", "");
        button_play_pause.row = 2;
        button_play_pause.columns = 2;
        button_play_pause.xfill = false;
        button_play_pause.xexpand = false;
        button_play_pause.yexpand = false;
        button_play_pause.top_padding = 8;
        button_play_pause.bottom_padding = 8;
        button_play_pause.relief = Maia.Button.Relief.NONE;
        button_play_pause.spacing = 0;
        button_play_pause.size = Maia.Graphic.Size (64, 64);
        add (button_play_pause);
        m_PlayPauseButton = button_play_pause;

        // Create label duration
        var label_duration = new Maia.Label (@"$(name)-label-duration", "00:00:00/00:00:00");
        label_duration.row = 2;
        label_duration.columns = 2;
        label_duration.xexpand = false;
        label_duration.xfill = false;
        label_duration.yfill = false;
        label_duration.state = Maia.State.ACTIVE;
        add (label_duration);
        m_LabelDuration = label_duration;

        // Create speed button
        var button_speed = new Widget.Knob (@"$(name)-speed");
        button_speed.row = 2;
        button_speed.columns = 2;
        button_speed.size = Maia.Graphic.Size (64, 64);
        button_speed.border = 12;
        button_speed.xfill = false;
        button_speed.xexpand = false;
        button_speed.yfill = false;
        button_speed.adjustment = new Maia.Adjustment ();
        button_speed.adjustment.upper = 1.1;
        button_speed.adjustment.lower = 0.9;
        button_speed.adjustment.value = 1.0;
        button_speed.adjustment.notify["value"].connect (on_adjustment_speed_changed);
        add (button_speed);
        m_SpeedButton = button_speed;

        // Create label
        var tmp = new Maia.Label (@"$(name)-tmp", "");
        tmp.row = 2;
        tmp.yfill = false;
        tmp.alignment = Maia.Graphic.Glyph.Alignment.LEFT;
        tmp.state = Maia.State.ACTIVE;
        add (tmp);

        plug_property ("stroke-pattern", m_LabelURI, "stroke-pattern");
        plug_property ("font-description", m_LabelURI, "font-description");

        plug_property ("stroke-pattern", m_LabelDuration, "stroke-pattern");
        plug_property ("font-description", m_LabelDuration, "font-description");

        plug_property ("pause-icon-filename", m_PlayPauseButton, "icon-filename");
        plug_property ("fill-pattern", m_PlayPauseButton, "fill-pattern");

        plug_property ("fill-pattern", m_SpeedButton, "fill-pattern");
        plug_property ("stroke-pattern", m_SpeedButton, "stroke-pattern");
    }

    public TurntablePlayer (string inId)
    {
        GLib.Object (id: GLib.Quark.from_string (inId));
    }


    private void
    on_adjustment_value_changed ()
    {
        if (m_InMove && m_FileSrc != null)
        {
            m_FileSrc.position = (long)m_Adjustment.value;
        }

        damage.post ();
    }

    private void
    on_adjustment_speed_changed ()
    {
        if (m_FileSrc != null)
        {
            print(@"speed: $(m_SpeedButton.adjustment.value)\n");
            m_FileSrc.speed = m_SpeedButton.adjustment.value;
        }
    }

    private void
    on_adjustment_changed ()
    {
        damage.post ();
    }

    private double
    get_angle_progress ()
    {
        double angle = 0.0;

        if (m_Adjustment != null && GLib.Math.fabs (m_Adjustment.upper - m_Adjustment.lower) != 0.0)
        {
            double percent = m_Adjustment.@value / (m_Adjustment.upper - m_Adjustment.lower);
            double upper = GLib.Math.PI / 7.5;
            double lower = GLib.Math.PI / 42.0;

            angle = lower + ((upper - lower) * percent);
        }

        return angle;
    }

    private void
    on_new_frame (Maia.Core.Notification inNotification)
    {
        damage.post ();
    }

    internal override void
    on_gesture (Maia.Gesture.Notification inNotification)
    {
        if (inNotification.button == 1)
        {
            switch (inNotification.gesture_type)
            {
                case Maia.Gesture.Type.PRESS:
                    m_InMove = true;
                    break;

                case Maia.Gesture.Type.RELEASE:
                    m_InMove = false;
                    m_FileSrc.speed = m_SpeedButton.adjustment.value;
                    break;

                case Maia.Gesture.Type.VSCROLL:
                    double delta = -inNotification.position.y / area.extents.size.height;

                    if (GLib.Math.fabs (delta) > 0.05)
                    {
                        m_FileSrc.speed = 9.0 * delta;
                    }
                    break;

                case Maia.Gesture.Type.HSCROLL:
                    double delta = -inNotification.position.x / area.extents.size.width;

                    if (m_Adjustment != null && GLib.Math.fabs (delta) > 0.01)
                    {
                        double offset = (m_Adjustment.upper - m_Adjustment.lower) * (delta / 100.0);
                        double val = m_Adjustment.value + offset;
                        if (val > m_Adjustment.upper)
                        {
                            m_Adjustment.value = m_Adjustment.upper;
                        }
                        else if (val < m_Adjustment.lower)
                        {
                            m_Adjustment.value = m_Adjustment.lower;
                        }
                        else
                        {
                            m_Adjustment.value = val;
                        }
                    }
                    break;
            }
        }
    }

    private void
    on_filename_changed ()
    {
        var filename = m_FileSrc.filename;
        string basename = GLib.Path.get_basename (filename);
        string dirname = GLib.Path.get_dirname (filename);
        int i = basename.last_index_of (".");
        m_LabelURI.text = basename.substring (0, i);

        string jacket = @"$(dirname)/album.jpg";
        if (GLib.FileUtils.test (jacket, GLib.FileTest.EXISTS))
        {
            background_pattern[Maia.State.NORMAL] = Maia.Graphic.Image.create (jacket);
        }
    }

    private void
    on_position_changed (Maia.Core.EventArgs? inArgs)
    {
        unowned Core.FileSrc.PositionEventArgs args = (Core.FileSrc.PositionEventArgs)inArgs;

        if (m_Adjustment.upper != (double)args.duration)
        {
            m_Adjustment.lower = 0;
            m_Adjustment.upper = (double)args.duration;
        }

        if (!m_InMove)
        {
            m_Adjustment.value = (double)args.position;
        }

        int hoursDuration = (int)(args.duration / 3600000);
        int minutesDuration = (int)(args.duration / 60000) - (hoursDuration * 60);
        int secondsDuration = (int)(args.duration / 1000) - (hoursDuration * 3600) - (minutesDuration * 60);

        int hoursPosition = (int)(args.position / 3600000);
        int minutesPosition = (int)(args.position / 60000) - (hoursPosition * 60);
        int secondsPosition = (int)(args.position / 1000) - (hoursPosition * 3600) - (minutesPosition * 60);

        if (hoursDuration > 0)
        {
            m_LabelDuration.text = "%02i:%02i:%02i / %02i:%02i:%02i".printf (hoursPosition, minutesPosition, secondsPosition,
                                                                             hoursDuration, minutesDuration, secondsDuration);
        }
        else
        {
            m_LabelDuration.text = "%02i:%02i /%02i:%02i".printf (minutesPosition, secondsPosition,
                                                                  minutesDuration, secondsDuration);
        }
    }

    internal override void
    update (Maia.Graphic.Context inContext, Maia.Graphic.Region inAllocation) throws Maia.Graphic.Error
    {
        base.update (inContext, inAllocation);

        // get handle geometry
        var handleGeometry = m_Handle.geometry.extents;

        // get delta to set position in middle of area
        double delta = (area.extents.size.width - (handleGeometry.origin.x + handleGeometry.size.width)) / 2.0;

        // Set position of vinyl
        var vinylGeometry = m_Vinyl.geometry.extents;
        m_Vinyl.update (inContext, new Maia.Graphic.Region (Maia.Graphic.Rectangle (vinylGeometry.origin.x + delta, vinylGeometry.origin.y,
                                                                                    vinylGeometry.size.width, vinylGeometry.size.height)));

        // Set position of handle
        m_Handle.update (inContext, new Maia.Graphic.Region (Maia.Graphic.Rectangle (handleGeometry.origin.x + delta, handleGeometry.origin.y,
                                                                                     handleGeometry.size.width, handleGeometry.size.height)));

        // Set position of button play
        var buttonPlayPauseGeometry = m_PlayPauseButton.geometry.extents;
        m_PlayPauseButton.update (inContext, new Maia.Graphic.Region (Maia.Graphic.Rectangle (buttonPlayPauseGeometry.origin.x + delta, buttonPlayPauseGeometry.origin.y,
                                                                                              buttonPlayPauseGeometry.size.width, buttonPlayPauseGeometry.size.height)));

        // Set position of duration label
        var labelDurationGeometry = m_LabelDuration.geometry.extents;
        double xLabelDuration = (handleGeometry.origin.x + handleGeometry.size.width - labelDurationGeometry.size.width) / 2.0;
        m_LabelDuration.update (inContext, new Maia.Graphic.Region (Maia.Graphic.Rectangle (xLabelDuration + delta, labelDurationGeometry.origin.y,
                                                                                            labelDurationGeometry.size.width, labelDurationGeometry.size.height)));


        // Set position of speed knob
        var knobSpeedGeometry = m_SpeedButton.geometry.extents;
        double xKnobSpeed = handleGeometry.origin.x + handleGeometry.size.width - knobSpeedGeometry.size.width;
        m_SpeedButton.update (inContext, new Maia.Graphic.Region (Maia.Graphic.Rectangle (xKnobSpeed + delta, knobSpeedGeometry.origin.y,
                                                                                          knobSpeedGeometry.size.width, knobSpeedGeometry.size.height)));


        // Create vinyl surface
        m_VinylSurface = new Maia.Graphic.Surface.similar (inContext.surface, (int)GLib.Math.ceil (vinyl_size), (int)GLib.Math.ceil (vinyl_size));
        m_VinylSurface.clear ();

        var ctx = m_VinylSurface.context;
        ctx.save ();
        {
            paint_vinyl (ctx);
        }
        ctx.restore ();
    }

    internal override void
    paint (Maia.Graphic.Context inContext, Maia.Graphic.Region inArea) throws Maia.Graphic.Error
    {
        var vinyl_area = m_Vinyl.geometry.extents;
        var vinyl_top_left = Maia.Graphic.Point (vinyl_area.origin.x + double.max(0, (vinyl_area.size.width - vinyl_size) / 2.0),
                                                 vinyl_area.origin.y);
        var vinyl_center = Maia.Graphic.Point ((vinyl_size / 2.0), (vinyl_size / 2.0));

        long now = m_FileSrc.position;

        inContext.save ();
        {
            double turn_per_ms = 45.0 / 60000.0;
            double nb_turns = turn_per_ms * (double)(m_LastTurnTime - now);
            m_CurrentTurnPos = (m_CurrentTurnPos + (2.0 * GLib.Math.PI * nb_turns)) % (2.0 * GLib.Math.PI);

            var transform = new Maia.Graphic.Transform.init_translate (vinyl_top_left.x, vinyl_top_left.y);
            transform.translate (vinyl_center.x, vinyl_center.y);
            transform.rotate (-m_CurrentTurnPos);
            transform.translate (-vinyl_center.x, -vinyl_center.y);
            inContext.transform = transform;

            inContext.operator = Maia.Graphic.Operator.SOURCE;
            var path = new Maia.Graphic.Path ();
            path.rectangle (0, 0, vinyl_size, vinyl_size);
            inContext.clip (path);
            inContext.pattern = m_VinylSurface;
            inContext.paint ();
        }
        inContext.restore ();

        inContext.save ();
        {
            var handle_area = m_Handle.geometry.extents;
            var handle_top_left = Maia.Graphic.Point (((handle_area.size.width - handle_size) / 2.0) - (handle_size / 2.0), handle_size / 2.0);
            var handle_top_right = Maia.Graphic.Point (((handle_area.size.width - handle_size) / 2.0) + (handle_size / 2.0), handle_size / 2.0);
            var corner_left_start = handle_area.origin.x + handle_top_left.x - vinyl_center.x;
            var corner_right_start = handle_area.origin.x + handle_top_right.x - vinyl_center.x;
            var diamond_pos = (vinyl_size / 2.0) * GLib.Math.sin (GLib.Math.PI / 4.5);

            var transform = new Maia.Graphic.Transform.init_translate (handle_area.origin.x, handle_area.origin.y);
            transform.translate (handle_top_left.x + handle_size / 2.0, handle_top_left.y + handle_size * 2.0);
            transform.rotate (get_angle_progress ());
            transform.translate (-(handle_top_left.x + handle_size / 2.0), -(handle_top_left.y + handle_size * 2.0));
            inContext.transform = transform;

            var path = new Maia.Graphic.Path ();
            path.arc (handle_top_left.x + handle_size / 2.0, handle_top_left.y + handle_size * 2.0,
                      3.0 * handle_size / 2.0, 3.0 * handle_size / 2.0, 0, 2.0 * GLib.Math.PI);

            inContext.pattern = stroke_pattern[state] ?? new Maia.Graphic.Color (0, 0, 0);
            inContext.stroke (path);
            inContext.pattern = fill_pattern[state] ?? new Maia.Graphic.Color (0, 0, 0);
            inContext.fill (path);

            path = new Maia.Graphic.Path ();
            path.move_to (handle_top_left.x, handle_top_left.y);
            path.line_to (handle_top_right.x, handle_top_right.y);
            path.line_to (handle_top_right.x, (vinyl_size / 2.0) + (GLib.Math.sin (GLib.Math.PI / 10.0) * corner_right_start));
            path.line_to (-handle_area.origin.x + vinyl_top_left.x + vinyl_center.x + (vinyl_size / 2.3),
                          (vinyl_size / 2.0) + diamond_pos);
            path.line_to (handle_top_left.x, (vinyl_size / 2.0) + (GLib.Math.sin (GLib.Math.PI / 10.0) * corner_left_start));
            path.line_to (handle_top_left.x, handle_top_left.y);


            inContext.line_width = line_width * 2.0;
            inContext.pattern = stroke_pattern[state] ?? new Maia.Graphic.Color (0, 0, 0);
            inContext.stroke (path);
            inContext.pattern = fill_pattern[state] ?? new Maia.Graphic.Color (0, 0, 0);
            inContext.fill (path);

            transform = new Maia.Graphic.Transform.identity ();
            transform.translate (handle_top_left.x, (vinyl_size / 2.0) + (GLib.Math.sin (GLib.Math.PI / 10.0) * corner_left_start));
            transform.rotate (GLib.Math.PI / 10.0);
            transform.translate (-handle_top_left.x, -((vinyl_size / 2.0) + GLib.Math.sin (GLib.Math.PI / 10.0) * corner_left_start));
            inContext.transform = transform;
            path = new Maia.Graphic.Path ();
            path.move_to (handle_top_left.x, (vinyl_size / 2.0) + GLib.Math.sin (GLib.Math.PI / 10.0) * corner_left_start);
            path.line_to (handle_top_right.x + (3.0 * handle_size / 2.0), (vinyl_size / 2.0) + (GLib.Math.sin (GLib.Math.PI / 10.0) * corner_left_start));
            inContext.line_width = line_width * 4.0;
            inContext.pattern = stroke_pattern[state] ?? new Maia.Graphic.Color (0, 0, 0);
            inContext.stroke (path);
        }
        inContext.restore ();

        m_SpeedButton.draw (inContext, area_to_child_item_space (m_SpeedButton, inArea));
        m_LabelDuration.draw (inContext, area_to_child_item_space (m_LabelDuration, inArea));
        m_PlayPauseButton.draw (inContext, area_to_child_item_space (m_PlayPauseButton, inArea));
        m_LabelURI.draw (inContext, area_to_child_item_space (m_LabelURI, inArea));

        m_LastTurnTime = now;
    }

    public virtual void
    paint_vinyl (Maia.Graphic.Context inContext) throws Maia.Graphic.Error
    {
        inContext.save ();
        {
            if (vinyl_pattern != null)
            {
                var vinyl_center = Maia.Graphic.Point ((vinyl_size / 2.0), (vinyl_size / 2.0));
                var vinyl_area = Maia.Graphic.Size ((vinyl_size / 2.0), (vinyl_size / 2.0));

                var path = new Maia.Graphic.Path ();
                path.arc (vinyl_center.x, vinyl_center.y, vinyl_area.width, vinyl_area.height, 0, 2 * GLib.Math.PI);
                path.arc (vinyl_center.x, vinyl_center.y, (1.0 / 20.0) * vinyl_area.width, (1.0 / 20.0) * vinyl_area.height, 0, 2 * GLib.Math.PI);

                path = new Maia.Graphic.Path ();
                path.arc (vinyl_center.x, vinyl_center.y, vinyl_size / 2.0, vinyl_size / 2.0, 0, 2 * GLib.Math.PI);
                path.arc (vinyl_center.x, vinyl_center.y, (1.0 / 20.0) * (vinyl_size / 2.0), (1.0 / 20.0) * (vinyl_size / 2.0), 0, 2 * GLib.Math.PI);

                inContext.save ();
                {
                    unowned Maia.Graphic.Image? image = vinyl_pattern as Maia.Graphic.Image;
                    if (image != null)
                    {
                        Maia.Graphic.Size image_size = image.size;
                        double scale = double.max (image_size.width / (vinyl_area.width * 2.0),
                                                   image_size.height / (vinyl_area.height * 2.0));
                        var back_transform = new Maia.Graphic.Transform.identity ();
                        back_transform.scale (scale, scale);
                        image.transform = back_transform;
                        inContext.pattern = vinyl_pattern;
                    }
                    else
                    {
                        inContext.pattern = vinyl_pattern;
                    }

                    inContext.fill (path);
                }
                inContext.restore ();
            }
            else
            {
                var vinyl_center = Maia.Graphic.Point ((vinyl_size / 2.0), (vinyl_size / 2.0));
                var vinyl_area = Maia.Graphic.Size ((vinyl_size / 2.0) - line_width, (vinyl_size / 2.0) - line_width);

                var path = new Maia.Graphic.Path ();
                path.arc (vinyl_center.x, vinyl_center.y, vinyl_area.width, vinyl_area.height, 0, 2 * GLib.Math.PI);
                path.arc (vinyl_center.x, vinyl_center.y, (1.0 / 20.0) * vinyl_area.width, (1.0 / 20.0) * vinyl_area.height, 0, 2 * GLib.Math.PI);

                if (background_pattern[state] != null)
                {
                    path = new Maia.Graphic.Path ();
                    path.arc (vinyl_center.x, vinyl_center.y, vinyl_size / 2.0, vinyl_size / 2.0, 0, 2 * GLib.Math.PI);
                    path.arc (vinyl_center.x, vinyl_center.y, (1.0 / 20.0) * (vinyl_size / 2.0), (1.0 / 20.0) * (vinyl_size / 2.0), 0, 2 * GLib.Math.PI);

                    inContext.save ();
                    {
                        unowned Maia.Graphic.Image? image = background_pattern[state] as Maia.Graphic.Image;
                        if (image != null)
                        {
                            Maia.Graphic.Size image_size = image.size;
                            double scale = double.max (image_size.width / (vinyl_area.width * 2.0),
                                                       image_size.height / (vinyl_area.height * 2.0));
                            var back_transform = new Maia.Graphic.Transform.identity ();
                            back_transform.scale (scale, scale);
                            image.transform = back_transform;
                            inContext.pattern = background_pattern[state];
                        }
                        else
                        {
                            inContext.pattern = background_pattern[state];
                        }

                        inContext.fill (path);
                    }
                    inContext.restore ();
                }

                path = new Maia.Graphic.Path ();
                path.arc (vinyl_center.x, vinyl_center.y, (1.0 / 20.0) * vinyl_area.width, (1.0 / 20.0) * vinyl_area.height, 0, 2 * GLib.Math.PI);
                path.arc (vinyl_center.x, vinyl_center.y, (1.0 / 5.0) * vinyl_area.height, (1.0 / 5.0) * vinyl_area.height, 0, 2 * GLib.Math.PI);
                inContext.pattern = stroke_pattern[state] ?? new Maia.Graphic.Color (0, 0, 0);
                inContext.fill (path);


                path = new Maia.Graphic.Path ();
                path.arc (vinyl_center.x, vinyl_center.y, vinyl_area.width, vinyl_area.height, 0, 2 * GLib.Math.PI);

                inContext.line_width = line_width * 2.0;
                inContext.pattern = stroke_pattern[state] ?? new Maia.Graphic.Color (0, 0, 0);
                inContext.stroke (path);

                inContext.line_width = line_width;
                path = new Maia.Graphic.Path ();
                path.arc (vinyl_center.x, vinyl_center.y, (3.0 / 4.0) * vinyl_area.width, (3.0 / 4.0) * vinyl_area.height, 0, GLib.Math.PI / 2.0);
                inContext.stroke (path);
                path = new Maia.Graphic.Path ();
                path.arc (vinyl_center.x, vinyl_center.y, (5.0 / 8.0) * vinyl_area.width, (5.0 / 8.0) * vinyl_area.height, 0, GLib.Math.PI / 2.0);
                inContext.stroke (path);
                path = new Maia.Graphic.Path ();
                path.arc (vinyl_center.x, vinyl_center.y, (1.0 / 2.0) * vinyl_area.width, (1.0 / 2.0) * vinyl_area.height, 0, GLib.Math.PI / 2.0);
                inContext.stroke (path);
            }
        }
        inContext.restore ();
    }
}
