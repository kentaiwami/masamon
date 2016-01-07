/*---------------------------------------------------------------------------*
 |          Copyright (c) 2002-2015 PDFlib GmbH. All rights reserved.        |
 +---------------------------------------------------------------------------+
 |    This software may not be copied or distributed except as expressly     |
 |    authorized by PDFlib GmbH's general license agreement or a custom      |
 |    license agreement signed by PDFlib GmbH.                               |
 |    For more information about licensing please refer to www.pdflib.com.   |
 *---------------------------------------------------------------------------*/

/* $Id: tetlib.h,v 1.241 2015/11/03 17:34:54 tm Exp $
 *
 * TET public function declarations
 *
 */

/*
 * ----------------------------------------------------------------------
 * Setup, mostly Windows calling conventions and DLL stuff
 * ----------------------------------------------------------------------
 */

#ifndef TETLIB_H
#define TETLIB_H

#include <stdio.h>
#include <setjmp.h>

#if defined(WIN32) && !defined(PDFLIB_CALL)
#define PDFLIB_CALL     __cdecl
#endif

#undef PDFLIB_API
#if defined(WIN32)

    #ifdef PDFLIB_EXPORTS
    #define PDFLIB_API __declspec(dllexport) /* prepare a DLL (internal use) */

    #elif defined(PDFLIB_DLL)

    #define PDFLIB_API __declspec(dllimport) /* PDFlib clients: import  DLL */
    #endif	/* PDFLIB_DLL */

#else
    #if __GNUC__ >= 4
	#define PDFLIB_API __attribute__ ((visibility("default")))
    #elif (defined(__SUNPRO_CC) && __SUNPRO_CC >= 0x550) \
	   || (defined(__SUNPRO_C) && __SUNPRO_C >= 0x550)
	#define PDFLIB_API __global
    #endif
#endif /* WIN32 */

#ifndef PDFLIB_CALL
    #define PDFLIB_CALL	/* */	/* default: no special calling conventions */
#endif

#ifndef PDFLIB_API
    #define PDFLIB_API /* */	 /* default: generate or use static library */
#endif

/* Make our declarations C++ compatible */
#ifdef __cplusplus
extern "C" {
#endif

/*
 * There's a redundant product name literal elsewhere that needs to be
 * changed with this one!
 */
#define IFILTER_PRODUCTNAME     "TET PDF IFilter"
#define IFILTER_WCHAR_PRODUCTNAME L"TET PDF IFilter"
#define IFILTER_PRODUCTDESCR    "PDFlib TET PDF IFilter"
#define IFILTER_COPYRIGHT \
        "(c) 2002-2015 PDFlib GmbH  www.pdflib.com  sales@pdflib.com\n"

#define IFILTER_MAJORVERSION	5
#define IFILTER_MINORVERSION	0
#define IFILTER_REVISION        0

/* Patched by the dist/ifilter/version.pl script */
#define IFILTER_SHORT_VERSIONSTRING	"5"
#define IFILTER_WCHAR_SHORT_VERSIONSTRING	L"5"
#define IFILTER_LONG_VERSIONSTRING	"5.0"
#define IFILTER_WCHAR_LONG_VERSIONSTRING	L"5.0"

#define TET_PRODUCTNAME         "TET"
#define TET_PRODUCTDESCR        "PDFlib Text and Image Extraction Toolkit"
#define TET_COPYRIGHT \
        "(c) 2002-2015 PDFlib GmbH  www.pdflib.com  sales@pdflib.com\n"

#define TET_MAJORVERSION	5
#define TET_MINORVERSION	0
#define TET_REVISION		0
/* ALWAYS change all version strings in the same way */
#define TET_SHORT_VERSIONSTRING		 "5"
#define TET_WCHAR_SHORT_VERSIONSTRING	L"5"
#define TET_LONG_VERSIONSTRING		 "5.0"
#define TET_WCHAR_LONG_VERSIONSTRING	L"5.0"

/* Opaque data type for the TET context. */
#if !defined(TET) || defined(ACTIVEX)
typedef struct TET_s TET;
#endif

/* The API structure with function pointers. */
typedef struct TET_api_s TET_api;

/*
 * ----------------------------------------------------------------------
 * pCOS-specific enums and defines
 * ----------------------------------------------------------------------
 */

/*
 * Guard against multiple definition of pcos_mode and pcos_object_type for the
 * case that multiple PDFlib products are used in the same program.
 */
#ifndef PDF_PCOS_ENUMS

/* document access levels.
*/
typedef enum
{
    pcos_mode_minimum	 = 0, /* encrypted doc (opened w/o password)	      */
    pcos_mode_restricted = 1, /* encrypted doc (opened w/ user password)      */
    pcos_mode_full	 = 2  /* unencrypted doc or opened w/ master password */
} pcos_mode;


/* object types.
*/
typedef enum
{
    pcos_ot_null	= 0,
    pcos_ot_boolean	= 1,
    pcos_ot_number	= 2,
    pcos_ot_name	= 3,
    pcos_ot_string	= 4,
    pcos_ot_array	= 5,
    pcos_ot_dict	= 6,
    pcos_ot_stream	= 7,
    pcos_ot_fstream	= 8
} pcos_object_type;

#define PDF_PCOS_ENUMS

#endif /* PDF_PCOS_ENUMS */

/* enums for the return values of unsupported function TET_get_unicode_format()
*/
typedef enum
{
    tet_uni_none     = 0,   /* no Unicode format */
    tet_uni_utf8     = 5,   /* UTF-8 */
    tet_uni_utf16    = 7,   /* UTF-16 */
    tet_uni_utf16be  = 8,   /* UTF-16 BE */
    tet_uni_utf16le  = 9,   /* UTF-16 LE */
    tet_uni_utf32    = 10   /* UTF-32 */
}
tet_unicode_format;


/*
 * ----------------------------------------------------------------------
 * TET-specific enums, structures, and defines
 * ----------------------------------------------------------------------
 */

/* Image formats returned by TET_write_image_file() */
typedef enum
{
                                /* MIME type and file name suffix            */
    tet_if_error = -1,          /* error, cannot retrieve image              */
    tet_if_auto	 =  0,          /* never returned                            */
    tet_if_tiff	 = 10,          /* image/tiff, *.tif                         */
    tet_if_jpeg	 = 20,          /* image/jpeg, *.jpg                         */
    /*tet_if_jpx = 30,             no longer used, replaced by:              */
    tet_if_jp2   = 31,          /* image/jp2, *.jp2                          */
    tet_if_jpf   = 32,          /* image/jpx, *.jpf                          */
    tet_if_j2k   = 33,          /* raw JPEG 2000 code stream, *.j2k          */
    /*tet_if_raw = 40,		   no longer used                            */
    tet_if_jbig2 = 50           /* image/x-jbig2, *.jbig2                    */
} tet_image_format;

/* TET_char_info character types with real geometry info.
*/
#define TET_CT__REAL		0
#define TET_CT_NORMAL		0
#define TET_CT_SEQ_START	1

/* TET_char_info character types with artificial geometry info.
*/
#define TET_CT__ARTIFICIAL	10
#define TET_CT_SEQ_CONT		10
#define TET_CT_SUR_TRAIL	11	/* deprecated */
#define TET_CT_INSERTED		12


/* TET_char_info text rendering modes.
*/
#define TET_TR_FILL		0	/* fill text                         */
#define TET_TR_STROKE		1	/* stroke text (outline)             */
#define TET_TR_FILLSTROKE	2	/* fill and stroke text              */
#define TET_TR_INVISIBLE	3	/* invisible text                    */
#define TET_TR_FILL_CLIP	4	/* fill text and
                                           add it to the clipping path       */
#define TET_TR_STROKE_CLIP	5	/* stroke text and
                                           add it to the clipping path       */
#define TET_TR_FILLSTROKE_CLIP	6	/* fill and stroke text and
                                           add it to the clipping path       */
#define TET_TR_CLIP		7	/* add text to the clipping path     */


/* TET_char_info attributes
*/

#define TET_ATTR_NONE         0x00000000
#define TET_ATTR_SUB          0x00000001	/* subscript                */
#define TET_ATTR_SUP          0x00000002	/* superscript              */
#define TET_ATTR_DROPCAP      0x00000004	/* initial large letter     */
#define TET_ATTR_SHADOW       0x00000008	/* shadowed text            */

/* character before hyphenation     */
#define TET_ATTR_DEHYPHENATION_PRE       0x00000010
/* hyphenation artifact, i.e. the dash */
#define TET_ATTR_DEHYPHENATION_ARTIFACT  0x00000020
/* character after hyphenation     */
#define TET_ATTR_DEHYPHENATION_POST      0x00000040


/* ensure correct structure alignment */
#if _MSC_VER >= 1310  /* VS .NET 2003 and later */
#pragma pack(push)
#pragma pack(8)
#endif /* _MSC_VER >= 1310 */

typedef struct
{
    int         uv;             /* current character in UTF-32               */
    int         type;           /* character type, see TET_CT_* above        */
    int         unknown;        /* 1: glyph was mapped to PUA by TET          */

    int         attributes;     /* character attributes, see TET_ATTR_* above*/

    double      x;              /* x position of the char's reference point  */
    double      y;              /* y position of the char's reference point  */
    double      width;          /* horizontal character extent               */
    double      height;         /* vertical character extent                 */
    double      alpha;          /* text baseline angle in degrees            */
    double      beta;           /* vertical character slanting angle         */

    int         fontid;         /* pCOS font id                              */
    double      fontsize;       /* size of the font                          */

    int         colorid;        /* unique text color id                      */
    int         textrendering;  /* text rendering mode, see TET_TR_* above   */
} TET_char_info;

#define TET_COL_MAXCOMP 8       /* maximum number of color components        */

typedef struct
{
    int         colorspaceid;   /* colorspace id or -1                       */
    int         patternid;      /* pattern id or -1                          */
    double      components[TET_COL_MAXCOMP]; /* color components             */
    int         n;              /* number of relevant entries in components[]*/
} TET_color_info;

typedef struct
{
    double	x;		/* x position of the image's reference point */
    double	y;		/* y position of the image's reference point */
    double	width;		/* width and height of the image on the page */
    double	height;		/* in points, measured along the edges       */
    double	alpha;		/* direction of the pixel rows (in degrees)  */
    double	beta;		/* direction of columns, relative to the     */
    				/* perpendicular of alpha                    */
    int		imageid;	/* pCOS image id	                     */
} TET_image_info;

#if _MSC_VER >= 1310  /* VS .NET 2003 and later */
#pragma pack(pop)
#endif /* _MSC_VER >= 1310 */


/*
 * ----------------------------------------------------------------------
 * TET API functions
 * ----------------------------------------------------------------------
 */

/* Release a clone document and all internal resources related to that
   document. */
PDFLIB_API void PDFLIB_CALL
TET_close_clone_document(
    TET *tet,
    int doc);

/* Release a document handle and all internal resources related to that
   document. */
PDFLIB_API void PDFLIB_CALL
TET_close_document(
    TET *tet,
    int doc);

/* Release a page handle and all related resources. */
PDFLIB_API void PDFLIB_CALL
TET_close_page(
    TET *tet,
    int page);

/* Convert a string in an arbitrary encoding to a Unicode string in various
   formats.
   Returns: The converted Unicode string.
*/
PDFLIB_API const char * PDFLIB_CALL
TET_convert_to_unicode(
    TET *tet,
    const char *inputformat,
    const char *inputstring,
    int inputlen,
    int *outputlen,
    const char *optlist);

/* Create a disk-based or virtual PDF document for font reporting
   of the input PDF document
*/
PDFLIB_API int PDFLIB_CALL
TET_create_fontreport_document(
    TET *tet,
    int doc,
    const char *filename,
    int len,
    const char *optlist);

/* Create a named virtual read-only file from data provided in memory. */
PDFLIB_API void PDFLIB_CALL
TET_create_pvf(
    TET *tet,
    const char *filename,
    int len,
    const void *data,
    size_t size,
    const char *optlist);

/* Delete a TET object and release all related internal resources. */
PDFLIB_API void PDFLIB_CALL
TET_delete(TET *tet);

/* Delete a named virtual file and free its data structures (but not the
   contents).
   Returns: -1 if the virtual file exists but is locked, and
             1 otherwise.
 */
PDFLIB_API int PDFLIB_CALL
TET_delete_pvf(
    TET *tet,
    const char *filename,
    int len);

/* Draw a clone of an input document page. */
PDFLIB_API int PDFLIB_CALL
TET_draw_clone_page(
    TET *tet,
    int doc,
    int page,
    const char *optlist);

/*
 * Retrieve a structure with TET API function pointers (mainly for DLLs).
 * Although this function is published here, it is not supposed to be used
 * directly by clients. Use TET_new_dl() in tetlibdl.c instead.
 */
PDFLIB_API const TET_api * PDFLIB_CALL
TET_get_api(void);

/* Get the name of the API function which caused an exception or failed. */
PDFLIB_API const char * PDFLIB_CALL
TET_get_apiname(
    TET *tet);

/* Get detailed information for the next character in the most recent
   text fragment. */
PDFLIB_API const TET_char_info * PDFLIB_CALL
TET_get_char_info(
    TET *tet,
    int page);

/* Get detailed information for a color id which has been retrieved with
   TET_get_char_info. */
PDFLIB_API const TET_color_info * PDFLIB_CALL
TET_get_color_info(
    TET *tet,
    int doc,
    int colorid,
    const char *optlist);

/* Get the text of the last thrown exception or the reason for a failed
   function call. */
PDFLIB_API const char * PDFLIB_CALL
TET_get_errmsg(
    TET *tet);

/* Get the number of the last thrown exception or the reason for a failed
   function call. */
PDFLIB_API int PDFLIB_CALL
TET_get_errnum(
    TET *tet);

/* Write image data to memory. */
PDFLIB_API const char * PDFLIB_CALL
TET_get_image_data(
    TET *tet,
    int doc,
    size_t *length,
    int imageid,
    const char *optlist);

/* Retrieve information about the next image on the page (but not the actual
   pixel data). */
PDFLIB_API const TET_image_info * PDFLIB_CALL
TET_get_image_info(
    TET *tet,
    int page);

/* Fetch the opaque client pointer from with a TET context. Unsupported. */
PDFLIB_API void * PDFLIB_CALL
TET_get_opaque(TET *tet);

/* Get the next text fragment from a page's content. */
PDFLIB_API const char * PDFLIB_CALL
TET_get_text(
    TET *tet,
    int page,
    int *len);

/* Query properties of a virtual file or the PDFlib Virtual Filesystem (PVF)
   Returns: The value of some file parameter as requested by keyword.
*/
PDFLIB_API double PDFLIB_CALL
TET_info_pvf(
    TET *tet,
    const char *filename,
    int len,
    const char *keyword);

/* Create a new TET object. */
PDFLIB_API TET * PDFLIB_CALL
TET_new(void);

/* Create a new TET context with a user-supplied error handler and
** opaque pointer. Unsupported.
*/
typedef void (*tet_error_fp)(TET *tet, int type, const char *msg);

PDFLIB_API TET * PDFLIB_CALL
TET_new2(
    tet_error_fp errorhandler,
    void *opaque);

/* Open a disk-based or virtual PDF document for cloning and marking
   pages of the input PDF document
*/
PDFLIB_API int PDFLIB_CALL
TET_open_clone_document(
    TET *tet,
    int doc,
    const char *filename,
    int len,
    const char *optlist);

/* Open a disk-based or virtual PDF document for content extraction. */
PDFLIB_API int PDFLIB_CALL
TET_open_document(
    TET *tet,
    const char *filename,
    int len,
    const char *optlist);

/* Open a PDF document from a custom data source for content extraction. */
PDFLIB_API int PDFLIB_CALL
TET_open_document_callback(
    TET *tet,
    void *opaque,
    size_t filesize,
    size_t (*readproc)(void *opaque, void *buffer, size_t size),
    int (*seekproc)(void *opaque, long offset),
    const char *optlist);

/* Deprecated; use TET_create_pvf( ) and TET_open_document( ). */
PDFLIB_API int PDFLIB_CALL
TET_open_document_mem(
    TET *tet,
    const void *data,
    size_t size,
    const char *optlist);

/* Open a page for content extraction. */
PDFLIB_API int PDFLIB_CALL
TET_open_page(
    TET *tet,
    int doc,
    int pagenumber,
    const char *optlist);

/* Get the value of a pCOS path with type number or boolean. */
PDFLIB_API double PDFLIB_CALL
TET_pcos_get_number(
    TET *tet,
    int doc,
    const char *path, ...);

/* Get the value of a pCOS path with type name, number, string, or boolean. */
PDFLIB_API const char * PDFLIB_CALL
TET_pcos_get_string(
    TET *tet,
    int doc,
    const char *path, ...);

/* Get the contents of a pCOS path with type stream, fstream, or string. */
PDFLIB_API const unsigned char * PDFLIB_CALL
TET_pcos_get_stream(
    TET *tet,
    int doc,
    int *length,
    const char *optlist,
    const char *path, ...);

/* Set one or more global options for TET. */
PDFLIB_API void PDFLIB_CALL
TET_set_option(
    TET *tet,
    const char *optlist);

/* Deprecated, use TET_convert_to_unicode() */
PDFLIB_API const char * PDFLIB_CALL
TET_utf16_to_utf8(
    TET *tet,
    const char *utf16string,
    int len,
    int *size);

/* Deprecated, use TET_convert_to_unicode() */
PDFLIB_API const char * PDFLIB_CALL
TET_utf8_to_utf16(
   TET *tet,
   const char *utf8string,
   const char *ordering,
   int *size);

/* Deprecated, use TET_convert_to_unicode() */
PDFLIB_API const char * PDFLIB_CALL
TET_utf32_to_utf16(
   TET *tet,
   const char *utf32string,
   int len,
   const char *ordering,
   int *size);

/* Deprecated, use TET_convert_to_unicode() */
PDFLIB_API const char * PDFLIB_CALL
TET_utf16_to_utf32(
    TET *tet,
    const char *utf16string,
    int len,
    const char *ordering,
    int *size);

/* Deprecated, use TET_convert_to_unicode() */
PDFLIB_API const char * PDFLIB_CALL
TET_utf8_to_utf32(
    TET *tet,
    const char *utf8string,
    const char *ordering,
    int *size);

/* Deprecated, use TET_convert_to_unicode() */
PDFLIB_API const char * PDFLIB_CALL
TET_utf32_to_utf8(
    TET *tet,
    const char *utf32string,
    int len,
    int *size);

/* Write image data to disk. */
PDFLIB_API int PDFLIB_CALL
TET_write_image_file(
    TET *tet,
    int doc,
    int imageid,
    const char *optlist);

/* Process a page and create TETML output. */
PDFLIB_API int PDFLIB_CALL
TET_process_page(
    TET *tet,
    int doc,
    int pageno,
    const char *optlist);

/* Retrieve TETML from memory. */
PDFLIB_API const char * PDFLIB_CALL
TET_get_tetml(
    TET *tet,
    int doc,
    size_t *length,
    const char *optlist);

/* Deprecated, use TET_get_tetml(). */
PDFLIB_API const char * PDFLIB_CALL
TET_get_xml_data(
    TET *tet,
    int doc,
    size_t *length,
    const char *optlist);

/* Deflate a Unicode string (UTF-16 or UTF-32) to a byte string (unsupported)
*/
PDFLIB_API const char * PDFLIB_CALL
TET_deflate_unicode(
    TET *tet,
    const char *utfstring,
    int len,
    int charsize,
    int *highchar);


/* Get the type of the Unicode format which belongs to the Unicode string
   returned from the last API function (unsupported)
*/
PDFLIB_API tet_unicode_format PDFLIB_CALL
TET_get_unicode_format(
    TET *tet);


/*
 * ----------------------------------------------------------------------
 * TET API structure with function pointers to all API functions
 * ----------------------------------------------------------------------
 */

typedef struct
{
    jmp_buf     jbuf;
} tet_jmpbuf;

/* The API structure with pointers to all PDFlib API functions */
struct TET_api_s
{
    /* version numbers for checking the DLL against client code */
    size_t sizeof_TET_api; /* size of this structure */

    int major; /* TET major version number */
    int minor; /* TET minor version number */
    int revision; /* TET revision number */

    int reserved; /* reserved */

    void (PDFLIB_CALL * TET_close_clone_document)(TET *tet, int doc);
    void (PDFLIB_CALL * TET_close_document)(TET *tet, int doc);
    void (PDFLIB_CALL * TET_close_page)(TET *tet, int page);
    const char * (PDFLIB_CALL * TET_convert_to_unicode)(TET *tet,
                const char *inputformat, const char *inputstring, int inputlen,
                int *outputlen, const char *optlist);
    int (PDFLIB_CALL * TET_create_fontreport_document)(TET *tet, int doc,
                const char *filename, int len, const char *optlist);
    void (PDFLIB_CALL * TET_create_pvf)(TET *tet, const char *filename,
            int len, const void *data, size_t size, const char *optlist);
    const char * (PDFLIB_CALL * TET_deflate_unicode)(TET *tet,
            const char *utfstring, int len, int charsize, int *highchar);
    void (PDFLIB_CALL * TET_delete)(TET *tet);
    int (PDFLIB_CALL * TET_delete_pvf)(TET *tet, const char *filename, int len);
    int (PDFLIB_CALL * TET_draw_clone_page)(TET *tet, int doc, int page,
            const char *optlist);
    const TET_api * (PDFLIB_CALL * TET_get_api)(void);
    const char * (PDFLIB_CALL * TET_get_apiname)(TET *tet);
    const TET_char_info * (PDFLIB_CALL * TET_get_char_info)(TET *tet, int page);
    const TET_color_info * (PDFLIB_CALL * TET_get_color_info)(TET *tet, int doc,
             int colorid, const char *optlist);
    const char * (PDFLIB_CALL * TET_get_errmsg)(TET *tet);
    int (PDFLIB_CALL * TET_get_errnum)(TET *tet);
    const char * (PDFLIB_CALL * TET_get_image_data)(TET *tet, int doc,
            size_t *length, int imageid, const char *optlist);
    const TET_image_info * (PDFLIB_CALL * TET_get_image_info)(TET *tet,
            int page);
    void * (PDFLIB_CALL * TET_get_opaque)(TET *tet);
    const char * (PDFLIB_CALL * TET_get_text)(TET *tet, int page, int *len);
    tet_unicode_format (PDFLIB_CALL * TET_get_unicode_format)(TET *tet);
    const char * (PDFLIB_CALL * TET_get_tetml)(TET *tet, int doc,
            size_t *length, const char *optlist);
    const char * (PDFLIB_CALL * TET_get_xml_data)(TET *tet, int doc,
            size_t *length, const char *optlist);
    double (PDFLIB_CALL * TET_info_pvf)(TET *tet, const char *filename, int len,
                const char *keyword);
    TET * (PDFLIB_CALL * TET_new)(void);
    TET * (PDFLIB_CALL * TET_new2)(tet_error_fp errorhandler, void *opaque);
    int (PDFLIB_CALL * TET_open_clone_document)(TET *tet, int doc,
            const char *filename, int len, const char *optlist);
    int (PDFLIB_CALL * TET_open_document)(TET *tet, const char *filename,
            int len, const char *optlist);
    int (PDFLIB_CALL * TET_open_document_callback)(TET *tet, void *opaque,
            size_t filesize, size_t(*readproc)(void *opaque, void *buffer,
                    size_t size), int(*seekproc)(void *opaque, long offset),
            const char *optlist);
    int (PDFLIB_CALL * TET_open_document_mem)(TET *tet, const void *data,
            size_t size, const char *optlist);
    int (PDFLIB_CALL * TET_open_page)(TET *tet, int doc, int pagenumber,
            const char *optlist);
    double (PDFLIB_CALL * TET_pcos_get_number)(TET *tet, int doc,
            const char *path, ...);
    const unsigned char * (PDFLIB_CALL * TET_pcos_get_stream)(TET *tet,
            int doc, int *length, const char *optlist, const char *path, ...);
    const char * (PDFLIB_CALL * TET_pcos_get_string)(TET *tet, int doc,
            const char *path, ...);
    int (PDFLIB_CALL * TET_process_page)(TET *tet, int doc, int pageno,
            const char *optlist);
    void (PDFLIB_CALL * TET_set_option)(TET *tet, const char *optlist);
    const char * (PDFLIB_CALL * TET_utf16_to_utf32)(TET *tet,
            const char *utf16string, int len, const char *ordering, int *size);
    const char * (PDFLIB_CALL * TET_utf16_to_utf8)(TET *tet,
            const char *utf16string, int len, int *size);
    const char * (PDFLIB_CALL * TET_utf32_to_utf16)(TET *tet,
            const char *utf32string, int len, const char *ordering, int *size);
    const char * (PDFLIB_CALL * TET_utf32_to_utf8)(TET *tet,
            const char *utf32string, int len, int *size);
    const char * (PDFLIB_CALL * TET_utf8_to_utf16)(TET *tet,
            const char *utf8string, const char *ordering, int *size);
    const char * (PDFLIB_CALL * TET_utf8_to_utf32)(TET *tet,
            const char *utf8string, const char *ordering, int *size);
    int (PDFLIB_CALL * TET_write_image_file)(TET *tet, int doc, int imageid,
            const char *optlist);

    tet_jmpbuf * (PDFLIB_CALL * tet_jbuf)(TET *tet);
    void (PDFLIB_CALL * tet_exit_try)(TET *tet);
    int (PDFLIB_CALL * tet_catch)(TET *tet);
    void (PDFLIB_CALL * tet_rethrow)(TET *tet);
    void (PDFLIB_CALL * tet_throw)(TET *tet, const char *parm1,
            const char *parm2, const char *parm3);
};

/*
 * ----------------------------------------------------------------------
 * Exception handling with try/catch implementation
 * ----------------------------------------------------------------------
 */

/* Set up an exception handling frame; must always be paired with TET_CATCH().
*/
#define TET_TRY(tet)		if (setjmp(tet_jbuf(tet)->jbuf) == 0)

/* Inform the exception machinery that a TET_TRY() will be left without
   entering the corresponding TET_CATCH( ) clause. */

#define TET_EXIT_TRY(tet)	tet_exit_try(tet)

/* Catch an exception; must always be paired with TET_TRY(). */

#define TET_CATCH(tet)		if (tet_catch(tet))

/* Re-throw an exception to another handler. */

#define TET_RETHROW(tet)	tet_rethrow(tet)

#if _MSC_VER >= 1310    /* VS .NET 2003 and later */
#pragma deprecated(TET_get_xml_data)
#pragma deprecated(TET_open_document_mem)
#pragma deprecated(TET_utf16_to_utf8)
#pragma deprecated(TET_utf8_to_utf16)
#pragma deprecated(TET_utf32_to_utf16)
#pragma deprecated(TET_utf16_to_utf32)
#pragma deprecated(TET_utf8_to_utf32)
#pragma deprecated(TET_utf32_to_utf8)
#endif

/*
 * ----------------------------------------------------------------------
 * Private stuff, do not use explicitly but only via the above macros!
 * ----------------------------------------------------------------------
 */

PDFLIB_API tet_jmpbuf * PDFLIB_CALL
tet_jbuf(
    TET *tet);

PDFLIB_API void PDFLIB_CALL
tet_exit_try(
    TET *tet);

PDFLIB_API int PDFLIB_CALL
tet_catch(
    TET *tet);

PDFLIB_API void PDFLIB_CALL
tet_rethrow(
    TET *tet);

PDFLIB_API void PDFLIB_CALL
tet_throw(
    TET *tet,
    const char *parm1,
    const char *parm2,
    const char *parm3);


#ifdef PDF_INTERN_FEATURE_PROPSBUF

pdc_core *tet_get_pdcore(TET *tet);
void tet_new_propsbuf(TET *tet);
void tet_insert_propsbuf(TET *tet, const char *property);
const char *tet_get_propsbuf(TET *tet);
void tet_delete_propsbuf(TET *tet);

#endif /* PDF_INTERN_FEATURE_PROPSBUF */


#ifdef __cplusplus
}	/* extern "C" */
#endif

#endif /* TETLIB_H */

