lib_LTLIBRARIES = libmaia-mixer-jack.la

libmaia_mixer_jack_la_SOURCES = \
    init.vala \
    device.vala \
    buffer.vala \
    channel.vala \
    input-audio-port.vala \
    output-audio-port.vala

libmaia_mixer_jack_la_VALAFLAGS = \
    --hide-internal \
    --target-glib=2.32 \
    --thread \
    --debug \
    --vapidir=${top_srcdir}/vapi \
    --pkg=config \
    --pkg=jack \
    --vapidir=${top_builddir}/lib \
    --pkg=maia-mixer \
    $(MAIA_MIXER_VALAFLAGS)

libmaia_mixer_jack_la_CFLAGS = \
    -Wno-discarded-qualifiers \
    -Wno-incompatible-pointer-types \
    -I${top_builddir}/lib \
    $(MAIA_MIXER_CFLAGS) \
    $(MAIA_MIXER_JACK_CFLAGS)

libmaia_mixer_jack_la_LDFLAGS = \
    -Wl,--as-needed \
    -avoid-version \
    -no-undefined

libmaia_mixer_jack_la_LIBADD = \
    $(MAIA_MIXER_LIBS) \
    $(MAIA_MIXER_JACK_LIBS)

backend_DATA = maia-mixer-jack.backend

VALAFILES = \
    $(filter %.vala,$(libmaia_mixer_jack_la_SOURCES))

CLEANFILES = \
    libmaia_mixer_jack_la_vala.stamp \
    $(VALAFILES:.vala=.c)
