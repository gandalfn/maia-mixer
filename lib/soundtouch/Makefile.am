lib_LTLIBRARIES = libmaia-mixer-soundtouch.la

libmaia_mixer_soundtouch_la_SOURCES = \
    init.vala \
    bpm-detect.vala \
    speed.vala \
    soundtouch-bpm-detect.cpp \
    soundtouch-bpm-detect.h \
    soundtouch.cpp \
    soundtouch.h

libmaia_mixer_soundtouch_la_VALAFLAGS = \
    --hide-internal \
    --target-glib=2.32 \
    --thread \
    --debug \
    --vapidir=${top_srcdir}/vapi \
    --pkg=config \
    --pkg=soundtouch-bpm-detect \
    --pkg=soundtouch \
    --vapidir=${top_builddir}/lib \
    --pkg=maia-mixer \
    $(MAIA_MIXER_VALAFLAGS)

libmaia_mixer_soundtouch_la_CFLAGS = \
    -Wno-discarded-qualifiers \
    -Wno-incompatible-pointer-types \
    -I${top_builddir}/lib \
    -I${top_srcdir}/vapi \
    $(MAIA_MIXER_CFLAGS) \
    $(MAIA_MIXER_SOUNDTOUCH_CFLAGS)

libmaia_mixer_soundtouch_la_LDFLAGS = \
    -Wl,--as-needed \
    -avoid-version \
    -no-undefined

libmaia_mixer_soundtouch_la_LIBADD = \
    $(MAIA_MIXER_LIBS) \
    $(MAIA_MIXER_SOUNDTOUCH_LIBS)

backend_DATA = maia-mixer-soundtouch.backend

VALAFILES = \
    $(filter %.vala,$(libmaia_mixer_soundtouch_la_SOURCES))

CLEANFILES = \
    libmaia_mixer_soundtouch_la_vala.stamp \
    $(VALAFILES:.vala=.c)
