m4_define(maia_mixer_version_major, 0)
m4_define(maia_mixer_version_minor, 1)
m4_define(maia_mixer_version_micro, 0)
AC_INIT([maia-mixer],[maia_mixer_version_major.maia_mixer_version_minor.maia_mixer_version_micro])
AC_PREREQ(2.63)

dnl ****************************************************************************
dnl Define default build directory
dnl ****************************************************************************
AC_CONFIG_SRCDIR([src/maia-mixer.vala])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([build-aux])
AC_CONFIG_HEADERS(build-aux/config.h)

dnl ****************************************************************************
dnl Init automake
dnl ****************************************************************************
AM_INIT_AUTOMAKE([1.11 subdir-objects tar-pax dist-bzip2 silent-rules -Wno-portability])
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])
AC_ARG_VAR([ACLOCAL_FLAGS], [aclocal flags, e.g. -I <macro dir>])
AM_MAINTAINER_MODE

dnl ****************************************************************************
dnl define version
dnl ****************************************************************************
MAIA_MIXER_MAJOR_VERSION=maia_mixer_version_major
MAIA_MIXER_MINOR_VERSION=maia_mixer_version_minor
MAIA_MIXER_MICRO_VERSION=maia_mixer_version_micro
MAIA_MIXER_SO_VERSION="maia_mixer_version_major:maia_mixer_version_minor:maia_mixer_version_micro"
AC_DEFINE_UNQUOTED(MAIA_MIXER_MAJOR_VERSION, $MAIA_MIXER_MAJOR_VERSION, [Major version])
AC_DEFINE_UNQUOTED(MAIA_MIXER_MINOR_VERSION, $MAIA_MIXER_MINOR_VERSION, [Minor version])
AC_DEFINE_UNQUOTED(MAIA_MIXER_MICRO_VERSION, $MAIA_MIXER_MICRO_VERSION, [Micro version])
AC_DEFINE_UNQUOTED(MAIA_MIXER_VERSION, $MAIA_MIXER_VERSION, [Version])
AC_SUBST(MAIA_MIXER_SO_VERSION)
AC_SUBST(MAIA_MIXER_VERSION)

dnl ****************************************************************************
dnl Internationalization
dnl ****************************************************************************
GETTEXT_PACKAGE=AC_PACKAGE_NAME
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE, "$GETTEXT_PACKAGE", [The gettext translation domain])
IT_PROG_INTLTOOL([0.40.1])
AM_GNU_GETTEXT([external])
AM_GNU_GETTEXT_VERSION([0.17])

dnl ****************************************************************************
dnl Check for build
dnl ****************************************************************************
AC_SEARCH_LIBS([strerror], [cposix])
AC_PROG_CC
AC_LANG([C++])

dnl ****************************************************************************
dnl Check for libtool
dnl ****************************************************************************
LT_PREREQ([2.2])
LT_INIT([disable-static pic-only])

dnl ****************************************************************************
dnl Requirements
dnl ****************************************************************************
GSTREAMER_REQUIRED=1.8.0
MAIA_REQUIRED=0.4.0

dnl ****************************************************************************
dnl Check for packages
dnl ****************************************************************************
PKG_CHECK_MODULES(MAIA_MIXER, [maia-0.4 >= $MAIA_REQUIRED])
MAIA_MIXER_CFLAGS="$MAIA_MIXER_CFLAGS -Ofast"
AC_SUBST(MAIA_MIXER_CFLAGS)
AC_SUBST(MAIA_MIXER_LIBS)
MAIA_MIXER_VALAFLAGS="--vapidir=$($PKG_CONFIG --variable=vapidir maia-0.4) --pkg=maia-0.4"
AC_SUBST(MAIA_MIXER_VALAFLAGS)

dnl ****************************************************************************
dnl Check for jack packages
dnl ****************************************************************************
PKG_CHECK_MODULES(MAIA_MIXER_JACK, [jack])
AC_SUBST(MAIA_MIXER_JACK_CFLAGS)
AC_SUBST(MAIA_MIXER_JACK_LIBS)

dnl ****************************************************************************
dnl Check for mad packages
dnl ****************************************************************************
PKG_CHECK_MODULES(MAIA_MIXER_MAD, [mad])
AC_SUBST(MAIA_MIXER_MAD_CFLAGS)
AC_SUBST(MAIA_MIXER_MAD_LIBS)

dnl ****************************************************************************
dnl Check for ffmpeg packages
dnl ****************************************************************************
PKG_CHECK_MODULES(MAIA_MIXER_FFMPEG, [libavutil >= 55.28.100
                                      libavformat >= 57.41.100
                                      libavcodec >= 57.48.101
                                      libswresample >= 2.1.100])
AC_SUBST(MAIA_MIXER_FFMPEG_CFLAGS)
AC_SUBST(MAIA_MIXER_FFMPEG_LIBS)

dnl ****************************************************************************
dnl Check for mad packages
dnl ****************************************************************************
PKG_CHECK_MODULES(MAIA_MIXER_LV2, [lilv-0])
AC_SUBST(MAIA_MIXER_LV2_CFLAGS)
AC_SUBST(MAIA_MIXER_LV2_LIBS)

dnl ****************************************************************************
dnl Check for soundtouch packages
dnl ****************************************************************************
PKG_CHECK_MODULES(MAIA_MIXER_SOUNDTOUCH, [soundtouch])
AC_SUBST(MAIA_MIXER_SOUNDTOUCH_CFLAGS)
AC_SUBST(MAIA_MIXER_SOUNDTOUCH_LIBS)

dnl ****************************************************************************
dnl Check for bootstrap
dnl ****************************************************************************
AC_MSG_CHECKING([bootstrap])
if test -e ${ac_pwd}/${srcdir}/bootstrap/build
then
    bootstrapdir="${ac_pwd}/${srcdir}/bootstrap/build"
    export PKG_CONFIG_PATH="${bootstrapdir}/lib/pkgconfig"
    VALAC="${bootstrapdir}/bin/valac"
    AC_MSG_RESULT([$bootstrapdir])
else
    bootstrapdir=""
    AC_MSG_RESULT([not found ! launch bootstrap.sh build])
fi

dnl ****************************************************************************
dnl Check for vala
dnl ****************************************************************************
AM_PROG_VALAC($VALA_REQUIRED)

dnl ****************************************************************************
dnl Define path
dnl ****************************************************************************
vapidir=${datadir}/vala/vapi
uidir=${datadir}/maia-mixer/ui
backenddir=${libdir}/maia-mixer/backends
AC_DEFINE_DIR([MAIA_MIXER_UI_PATH], [uidir], [ui path])
AC_DEFINE_DIR([MAIA_MIXER_BACKEND_PATH], [backenddir], [backends path])
AC_SUBST(vapidir)
AC_SUBST(backenddir)
AC_SUBST(uidir)

dnl ****************************************************************************
dnl Generate outputs
dnl ****************************************************************************
AC_CONFIG_FILES([
Makefile
lib/Makefile
lib/jack/Makefile
lib/mad/Makefile
lib/ffmpeg/Makefile
lib/lv2/Makefile
lib/soundtouch/Makefile
src/Makefile
data/Makefile
vapi/Makefile
po/Makefile.in
])

AC_OUTPUT
