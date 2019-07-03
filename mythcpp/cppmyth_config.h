
#ifndef CPPMYTH_CONFIG_H
#define CPPMYTH_CONFIG_H

#undef HAVE_TIMEGM
#define HAVE_TIMEGM 1

#undef HAVE_LOCALTIME_R
#define HAVE_LOCALTIME_R 1

#undef HAVE_GMTIME_R
#define HAVE_GMTIME_R 1

#undef HAVE_ZLIB
#define HAVE_ZLIB 1

#undef HAVE_OPENSSL
#define HAVE_OPENSSL 0

#undef CC_INLINE
#define CC_INLINE inline

#undef NSROOT
#define NSROOT Myth

#undef LIBTAG
#define LIBTAG "CPPMyth"

#endif	/* CPPMYTH_CONFIG_H */
