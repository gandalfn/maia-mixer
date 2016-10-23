SUBDIRS = . jack mad ffmpeg lv2 soundtouch

maia-mixer.vapi: libmaia_mixer_la_vala.stamp

maia-mixer.h: libmaia_mixer_la_vala.stamp

include_HEADERS = maia-mixer.h

vapi_DATA = maia-mixer.vapi

lib_LTLIBRARIES = libmaia-mixer.la

libmaia_mixer_la_SOURCES = \
    core/error.vala \
    core/buffer.vala \
    core/sample-cache.vala \
    core/element.vala \
    core/engine.vala \
    core/file-src.vala \
    core/gain.vala \
    core/three-band-eq.vala \
    core/bpm-detect.vala \
    audio/sample-notification.vala \
    audio/channel.vala \
    audio/port.vala \
    audio/input-port.vala \
    audio/output-port.vala \
    audio/device.vala \
    audio/sample.vala \
    audio/file.vala \
    audio/file-mpeg.vala \
    audio/file-mp4.vala \
    filters/filter.vala \
    filters/resample.vala \
    filters/speed.vala \
    filters/three-band-eq.vala \
    filters/bpm-detect.vala

libmaia_mixer_la_VALAFLAGS = \
    --hide-internal \
    --target-glib=2.42 \
    --thread \
    --debug \
    --header=maia-mixer.h \
    --library=maia-mixer \
    --vapidir=${top_srcdir}/vapi \
    --pkg=config \
    --pkg=glib-add \
    $(MAIA_MIXER_VALAFLAGS)

libmaia_mixer_la_CFLAGS = \
    -Wno-discarded-qualifiers \
    $(MAIA_MIXER_CFLAGS)

libmaia_mixer_la_LDFLAGS = \
    -Wl,--as-needed \
    -version-number @MAIA_MIXER_SO_VERSION@ \
    -no-undefined

libmaia_mixer_la_LIBADD = \
    $(MAIA_MIXER_LIBS)

VALAFILES = \
    $(filter %.vala,$(libmaia_mixer_la_SOURCES))

CLEANFILES = \
    libmaia_mixer_la_vala.stamp \
    $(VALAFILES:.vala=.c) \
    maia-mixer.h \
    maia-mixer.vapi
