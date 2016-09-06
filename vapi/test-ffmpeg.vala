static int
main (string[] inArgs)
{
    string filename = "/home/gandalfn/Téléchargements/Eat Sleep Rave Repeat (feat. Beardyman) [Calvin Harris Remix].mp3";
    //string filename = "/home/gandalfn/Musique/Artiste inconnu/Classic and Rare_ La Collection, Chapter 3/Velvet Blues.m4a";
    Av.Format.register_all ();
    Av.Codec.register_all ();

    unowned Av.Format.Context ctx;
    int ret = Av.Format.Context.open_input (out ctx, filename, null, null);
    if (ret < 0)
    {
        error ("Cannot open input file");
    }

    ret = ctx.find_stream_info (null);
    if (ret < 0)
    {
        error ("Cannot find stream information");
    }

    long ctxDur = (long)((double)(ctx.duration * 1000.0) / (double)Av.Util.TIME_BASE);
    print(@"context: $ctxDur\n");
    //ctx.dump_format (0, filename, false);

    unowned Av.Codec.Codec codec;
    int numStream = ctx.find_best_stream (Av.Util.MediaType.AUDIO, -1, -1, out codec, 0);
    if (numStream < 0)
    {
        error ("Cannot find a audio stream in the input file");
    }
    print (@"$(Av.Util.MediaType.AUDIO) stream: $numStream duration: $(ctx.streams[numStream].duration) time_base: $(ctx.streams[numStream].time_base.num)/$(ctx.streams[numStream].time_base.den) codec: $(codec.long_name)\n");

    var codecCtx = new Av.Codec.Context (codec);
    ret = codecCtx.set_parameters (ctx.streams[numStream].codecpar);
    if (ret < 0)
    {
        error ("Cannot set codec parameters");
    }
    print (@"sample format: $(codecCtx.sample_fmt) sample_rate: $(codecCtx.sample_rate) channels: $(codecCtx.channels)\n");

    ret = codecCtx.open (codec, null);
    if (ret < 0)
    {
        error ("Error on open codec context");
    }

    Av.Codec.Packet packet = new Av.Codec.Packet ();
    packet.init ();

    var frame = new Av.Util.Frame ();
    while (ctx.read_frame (packet) == 0)
    {
        long offset = (long)((double)packet.pts * ctx.streams[numStream].time_base.q2d () * 1000.0);
        long dur = (long)((double)packet.duration * ctx.streams[numStream].time_base.q2d () * 1000.0);
        print(@"offset: $offset duration: $dur\n");
        if (packet.stream_index == numStream)
        {
            ret = codecCtx.send_packet (packet);
            if (ret < 0)
            {
                error (@"Error on send packet, $ret");
            }
            print (@"read packet $(packet.size)\n");

            ret = codecCtx.receive_frame (frame);
            if (ret < 0)
            {
                if (ret == Av.Util.Error.from_posix (Posix.EAGAIN))
                {
                    print (@"EGAIN\n");
                    continue;
                }
                else if (ret == Av.Util.Error.EOF)
                {
                    print (@"EOF\n");
                    break;
                }
                else
                {
                    error (@"error on receive frame $ret");
                }
            }
            double pos = (double)frame.pkt_pts * ctx.streams[numStream].time_base.q2d ();
            double duration = ((double)frame.nb_samples / (double)frame.sample_rate) * 1000.0;
            int minutes = (int)(pos / 60.0);
            int seconds = (int)pos - (minutes * 60);
            print (@"frame channels: $(frame.channels) size: $(frame.nb_samples) sample_rate: $(frame.sample_rate) duration: $(duration) pos: $pos <=> $(minutes):$(seconds)\n");

            var resample = new Sw.Resample.Context ();
            Av.Util.Options.set_channel_layout (resample, "in_channel_layout", frame.channel_layout);
            Av.Util.Options.set_channel_layout (resample, "out_channel_layout", frame.channel_layout);
            Av.Util.Options.set_int (resample, "in_sample_rate", frame.sample_rate);
            Av.Util.Options.set_int (resample, "out_sample_rate", 44100);
            Av.Util.Options.set_sample_fmt (resample, "in_sample_fmt", frame.format);
            Av.Util.Options.set_sample_fmt (resample, "out_sample_fmt", Av.Util.SampleFormat.FLTP);
            resample.init ();

            var outFrame = new Av.Util.Frame ();
            outFrame.sample_rate = 44100;
            outFrame.format = Av.Util.SampleFormat.FLTP;
            outFrame.nb_samples = resample.get_out_samples (frame.nb_samples);
            outFrame.channel_layout = frame.channel_layout;
            ret = outFrame.get_buffer (false);
            if (ret < 0)
            {
                error (@"error on get out frame buffer\n");
            }

            ret = resample.convert_frame (outFrame, frame);
            if (ret < 0)
            {
                error ("Error on resample\n");
            }

            resample.close ();
        }
    }

    Av.Format.Context.close_input (ref ctx);

    return 0;
}
