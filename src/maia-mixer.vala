static int
main (string[] inArgs)
{
    //Maia.Log.set_default_logger (new Maia.Log.Stderr (Maia.Log.Level.DEBUG, Maia.Log.Category.ALL, "maia-mixer"));

    Maia.Application.add_backends_path ("lib/jack");
    Maia.Application.add_backends_path ("lib/mad");
    Maia.Application.add_backends_path ("lib/lv2");
    Maia.Application.add_backends_path ("lib/soundtouch");

    var application = new Maia.Application ("maia-mixer", 30, { "gtk", "jack", "mad", "lv2", "soundtouch" });

    Maia.Manifest.Element.register ("Knob", typeof (MaiaMixer.Widget.Knob));
    Maia.Manifest.Element.register ("Scope", typeof (MaiaMixer.Widget.Scope));
    Maia.Manifest.Element.register ("VuMeter", typeof (MaiaMixer.Widget.VuMeter));
    Maia.Manifest.Element.register ("TurntablePlayer", typeof (MaiaMixer.Widget.TurntablePlayer));

    try
    {
        var device = new MaiaMixer.Audio.Device ("maia-mixer");
        var port = new MaiaMixer.Audio.OutputPort ("player");
        var left = new MaiaMixer.Audio.Channel ("left");
        var right = new MaiaMixer.Audio.Channel ("right");

        port.add (left);
        port.add (right);

        device.add (port);

        var filesrc = new MaiaMixer.Core.FileSrc ("filesrc", device.sample_rate);
        filesrc.filename = inArgs[1];
        //filesrc.speed = -1.0;
        filesrc.position = filesrc.duration;


        var eq = new MaiaMixer.Core.ThreeBandEq ("eq", device.sample_rate, device.buffer_size);

        var bpm = new MaiaMixer.Core.BPMDetect ("bpm", device.sample_rate);

        var leftevent = new MaiaMixer.Widget.EventSample("left-event", 0);
        var rightevent = new MaiaMixer.Widget.EventSample("right-event", 1);

        var engine = new MaiaMixer.Core.Engine ("mm-player", port);
        engine.add (filesrc);
        engine.add (bpm);
        engine.add (eq);
        engine.add (leftevent);
        engine.add (rightevent);

        var document = new Maia.Manifest.Document ("data/maia-mixer.maia");

        var window = document["mixer"] as Maia.Window;
        window.destroy_event.subscribe (() => {
            application.quit ();
        });

        var vumeter_left = window.find (GLib.Quark.from_string ("vumeter_left")) as MaiaMixer.Widget.VuMeter;
        vumeter_left.event_sample = leftevent;

        var scope_left = window.find (GLib.Quark.from_string ("scope_left")) as MaiaMixer.Widget.Scope;
        scope_left.event_sample = leftevent;

        var vumeter_right = window.find (GLib.Quark.from_string ("vumeter_right")) as MaiaMixer.Widget.VuMeter;
        vumeter_right.event_sample = rightevent;

        var scope_right = window.find (GLib.Quark.from_string ("scope_right")) as MaiaMixer.Widget.Scope;
        scope_right.event_sample = rightevent;

        var turntable = window.find (GLib.Quark.from_string ("turntable_player")) as MaiaMixer.Widget.TurntablePlayer;
        turntable.file_src = filesrc;

        var volume = window.find (GLib.Quark.from_string ("volume")) as MaiaMixer.Widget.Knob;
        volume.adjustment = new Maia.Adjustment.with_properties (-24, 24, 1);
        volume.adjustment.value = eq.master;
        volume.adjustment.notify["value"].connect (() => {
            eq.master = (int)volume.adjustment.value;
        });

        var low = window.find (GLib.Quark.from_string ("low")) as MaiaMixer.Widget.Knob;
        low.adjustment = new Maia.Adjustment.with_properties (-24, 24, 1);
        low.adjustment.value = eq.low;
        low.adjustment.notify["value"].connect (() => {
            eq.low = (int)low.adjustment.value;
        });

        var med = window.find (GLib.Quark.from_string ("medium")) as MaiaMixer.Widget.Knob;
        med.adjustment = new Maia.Adjustment.with_properties (-24, 24, 1);
        med.adjustment.value = eq.med;
        med.adjustment.notify["value"].connect (() => {
            eq.med = (int)med.adjustment.value;
        });

        var high = window.find (GLib.Quark.from_string ("high")) as MaiaMixer.Widget.Knob;
        high.adjustment = new Maia.Adjustment.with_properties (-24, 24, 1);
        high.adjustment.value = eq.high;
        high.adjustment.notify["value"].connect (() => {
            eq.high = (int)high.adjustment.value;
        });

        var bpmLabel = window.find (GLib.Quark.from_string ("bpm")) as Maia.Label;
        bpm.bpm_changed.subscribe ((inArgs) => {
            unowned MaiaMixer.Core.BPMDetect.EventArgs args = inArgs as MaiaMixer.Core.BPMDetect.EventArgs;
            bpmLabel.text = @"BPM: $((int)args.bpm)";
        });
        filesrc.notify["speed"].connect (() => {
            bpm.reset ();
        });


        window.visible = true;
        application.add (window);

        device.start ();

        var channels = device.find_channels ("system", null, MaiaMixer.Audio.Channel.Flags.INPUT | MaiaMixer.Audio.Channel.Flags.PHYSICAL);
        if (channels.length >= 2)
        {
            device.link (left, channels[0]);
            device.link (right, channels[1]);
        }

        application.run ();
    }
    catch (GLib.Error err)
    {
        print (@"$(err.message)\n");
    }

    return 0;
}
