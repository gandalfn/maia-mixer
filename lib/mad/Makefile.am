lib_LTLIBRARIES = libmaia-mixer-mad.la

libmaia_mixer_mad_la_SOURCES = \
    init.vala \
    sample.vala \
    file-mpeg.vala \
    resample.vala \
    speed.vala

libmaia_mixer_mad_la_VALAFLAGS = \
    --hide-internal \
    --target-glib=2.42 \
    --thread \
    --debug \
    --vapidir=${top_srcdir}/vapi \
    --pkg=config \
    --pkg=mad \
    --vapidir=${top_builddir}/lib \
    --pkg=maia-mixer \
    $(MAIA_MIXER_VALAFLAGS)

libmaia_mixer_mad_la_CFLAGS = \
    -Wno-discarded-qualifiers \
    -Wno-incompatible-pointer-types \
    -I${top_builddir}/lib \
    $(MAIA_MIXER_CFLAGS) \
    $(MAIA_MIXER_MAD_CFLAGS)

libmaia_mixer_mad_la_LDFLAGS = \
    -Wl,--as-needed \
    -avoid-version \
    -no-undefined

libmaia_mixer_mad_la_LIBADD = \
    $(MAIA_MIXER_LIBS) \
    $(MAIA_MIXER_MAD_LIBS)

backend_DATA = maia-mixer-mad.backend

VALAFILES = \
    $(filter %.vala,$(libmaia_mixer_mad_la_SOURCES))

CLEANFILES = \
    libmaia_mixer_mad_la_vala.stamp \
    $(VALAFILES:.vala=.c)
