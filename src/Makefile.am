bin_PROGRAMS = \
    maia-mixer

maia_mixer_SOURCES = \
    widgets/event-sample.vala \
    widgets/vu-meter.vala \
    widgets/scope.vala \
    widgets/turntable-player.vala \
    widgets/knob.vala \
    maia-mixer.vala

#    widgets/input-buffered-port.vala
#    widgets/scope.vala
#    widgets/vu-meter.vala
#    widgets/turntable-player.vala
#    workspace.vala

maia_mixer_VALAFLAGS = \
    $(MAIA_MIXER_VALAFLAGS) \
    --target-glib=2.32 \
    --thread \
    --hide-internal \
    --debug \
    --vapidir=${top_srcdir}/vapi \
    --pkg=config \
    --pkg=glib-add \
    --pkg=posix \
    --vapidir=${top_builddir}/lib \
    --pkg=maia-mixer

maia_mixer_CFLAGS = \
    -Wno-incompatible-pointer-types \
    -Wno-discarded-qualifiers \
    -I${top_builddir}/lib \
    $(MAIA_MIXER_CFLAGS)

maia_mixer_LDADD = \
    $(MAIA_MIXER_LIBS) \
    $(MAIA_MIXER_JACK_LIBS) \
    $(MAIA_MIXER_GSTREAMER_LIBS) \
    ${top_builddir}/lib/libmaia-mixer.la \
    -lprofiler

VALAFILES = \
    $(filter %.vala,$(maia_mixer_SOURCES))

CLEANFILES = \
    maia_mixer_vala.stamp \
    $(VALAFILES:.vala=.c)
