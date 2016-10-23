lib_LTLIBRARIES = libmaia-mixer-lv2.la

libmaia_mixer_lv2_la_SOURCES = \
    init.vala \
    three-band-eq.vala

libmaia_mixer_lv2_la_VALAFLAGS = \
    --hide-internal \
    --target-glib=2.42 \
    --thread \
    --debug \
    --vapidir=${top_srcdir}/vapi \
    --pkg=config \
    --pkg=lilv \
    --vapidir=${top_builddir}/lib \
    --pkg=maia-mixer \
    $(MAIA_MIXER_VALAFLAGS)

libmaia_mixer_lv2_la_CFLAGS = \
    -Wno-discarded-qualifiers \
    -Wno-incompatible-pointer-types \
    -I${top_builddir}/lib \
    $(MAIA_MIXER_CFLAGS) \
    $(MAIA_MIXER_LV2_CFLAGS)

libmaia_mixer_lv2_la_LDFLAGS = \
    -Wl,--as-needed \
    -avoid-version \
    -no-undefined

libmaia_mixer_lv2_la_LIBADD = \
    $(MAIA_MIXER_LIBS) \
    $(MAIA_MIXER_LV2_LIBS)

backend_DATA = maia-mixer-lv2.backend

VALAFILES = \
    $(filter %.vala,$(libmaia_mixer_lv2_la_SOURCES))

CLEANFILES = \
    libmaia_mixer_lv2_la_vala.stamp \
    $(VALAFILES:.vala=.c)
