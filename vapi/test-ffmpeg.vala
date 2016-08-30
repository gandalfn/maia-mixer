static int
main (string[] inArgs)
{
    //string filename = "/home/gandalfn/Téléchargements/Eat Sleep Rave Repeat (feat. Beardyman) [Calvin Harris Remix].mp3";
    string filename = "/home/gandalfn/Musique/Artiste inconnu/Classic and Rare_ La Collection, Chapter 3/Velvet Blues.m4a";
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
    unowned Av.Codec.Codec codec;
    ret = ctx.find_best_stream (Av.Util.MediaType.AUDIO, -1, -1, out codec, 0);
    if (ret < 0)
    {
        error ("Cannot find a audio stream in the input file");
    }
    print (@"$(Av.Util.MediaType.AUDIO) stream: $ret codec: $(codec.long_name)\n");
    ctx.dump_format (0, filename, false);

    Av.Format.Context.close_input (ref ctx);

    return 0;
}
