/*---------------------------------------------------------------------------*
 |          Copyright (c) 2005-2010 PDFlib GmbH. All rights reserved.        |
 +---------------------------------------------------------------------------+
 |    This software may not be copied or distributed except as expressly     |
 |    authorized by PDFlib GmbH's general license agreement or a custom      |
 |    license agreement signed by PDFlib GmbH.                               |
 |    For more information about licensing please refer to www.pdflib.com.   |
 *---------------------------------------------------------------------------*/

// $Id: tet.hpp,v 1.42 2015/07/29 15:40:24 rjs Exp $
//
// C++ wrapper for TET
//
//

#ifndef TETLIB_HPP
#define TETLIB_HPP

#include <string>
#include <sstream>
#include <iostream>
#include <stdexcept>

/* figure out whether or not we're running on an EBCDIC-based machine */
#define	TETCPP_ASCII_A          0x41
#define TETCPP_PLATFORM_A       'A'
#define TETCPP_EBCDIC_A         0xC1

#if (TETCPP_ASCII_A != TETCPP_PLATFORM_A \
        && TETCPP_EBCDIC_A == TETCPP_PLATFORM_A)
#define TETCPP_INTERNAL_OPTFORMAT "ebcdicutf8"
#else
#define TETCPP_INTERNAL_OPTFORMAT "utf8"
#endif

// We use TET as a C++ class name, therefore hide the actual C struct
// name for TET usage with C++.
typedef struct TET_s TET_cpp;
#define TET TET_cpp
#include "tetlib.h"
#undef TET

/*
 * TETCPP_USE_PDFLIB_NAMESPACE
 *
 * If set to a non-zero value, wrap all declarations in the namespace "pdflib".
 * Otherwise no namespace declaration is created. For backward compatibility
 * with the TET 3 C++ wrapper, define this as 0.
 */
#ifndef TETCPP_USE_PDFLIB_NAMESPACE
#define TETCPP_USE_PDFLIB_NAMESPACE 1
#endif

/*
 * TETCPP_PDFLIB_WSTRING
 *
 * The tet.hpp header declares one instantiation of the basic_TET
 * template as type "TET". By default this TET type is std::wstring-based.
 * For backward compatibility with the TET 3 std::string-based C++ wrapper,
 * define this as 0.
 */
#ifndef TETCPP_TET_WSTRING
#define TETCPP_TET_WSTRING 1
#endif

/*
 * TETCPP_DL
 *
 * The tet.hpp header can be used for static linking against the TET library,
 * or it can be configured for loading the TET DLL dynamically at runtime.
 *
 * The default is to compile for static linking against the TET library. For
 * dynamic loading, define TETCPP_DL as 1. In that case the resulting program
 * must not be linked against the TET library. Instead the tetlibdl.c module from
 * the "bind/c" directory must be compiled and linked to the application.
 */
#ifndef TETCPP_DL
#define TETCPP_DL 0
#endif

#if TETCPP_DL
#include "tetlibdl.h"
#endif


#if defined(_MSC_VER) && defined(_MANAGED)
/*
 * Dummy declaration to prevent linker warning for .NET. If it doesn't see
 * a declaration of the structure it will complain. The structure is never
 * used in the .NET wrapper, so it is safe to declare it as an empty structure
 * here.
 */
struct TET_s {};
#endif

#if TETCPP_USE_PDFLIB_NAMESPACE
namespace pdflib {
#endif

// The C++ class wrapper for TET

#if defined(_MSC_VER)
// Suppress Visual C++ warnings about ignored exception specifications.
#pragma warning(disable: 4290)
#endif

template<class pstring, class conv> class basic_TET;

/**
 * The "do-nothing" converter that has the effect that the basic_TET class
 * behaves in the same way as the TET 3.0 wrapper.
 */
template<class pstring>
class TETNoOpConverter
{
public:
    static bool do_conversion()
    {
        return false;
    }

    static void convert_to_pdf_bytes(
        const basic_TET<pstring, TETNoOpConverter<pstring> >&,
        const pstring& in, std::string& out)
    {
        throw std::logic_error(
                "TETNoOpConverter::convert_to_pdf_bytes: internal error: "
                "converter called although do_conversion() returns false");
    }

    static void convert_to_pdf_utf8(
            const basic_TET<pstring, TETNoOpConverter<pstring> >&,
            const pstring&, std::string&)
    {
        throw std::logic_error(
                "TETNoOpConverter::convert_to_pdf_utf8: internal error: "
                "converter called although do_conversion() returns false");
    }

    static void convert_to_pdf_utf16(
            const basic_TET<pstring, TETNoOpConverter<pstring> >&,
            const pstring&, std::string&)
    {
        throw std::logic_error(
                "TETNoOpConverter::convert_to_pdf_utf16: internal error: "
                "converter called although do_conversion() returns false");
    }

    static void convert_to_pstring(
            const basic_TET<pstring, TETNoOpConverter<pstring> >&,
            const char *, pstring&)
    {
        throw std::logic_error(
                "TETNoOpConverter::convert_to_pstring: internal error: "
                "converter called although do_conversion() returns false");
    }
};

#if defined(_MSC_VER) && defined(_MANAGED)
/*
 * Switching to C++ try/catch for exception handling allows .NET compilation
 * of the C++ wrapper with "/clr" and also with "/clr:pure".
 */

#define TETCPP_TRY try {

#define TETCPP_CATCH } catch (Exception &) {\
  throw;\
}

#else /* defined(_MSC_VER) && defined(_MANAGED) */

#if TETCPP_DL

#define TETCPP_TRY      TET_TRY_DL(m_TETlib_api, tet)
#define TETCPP_CATCH  \
TET_CATCH_DL(m_TETlib_api, tet) {\
    const pstring message, apiname; \
    convert_exception_strings(message, apiname); \
    throw Exception(message, m_TETlib_api->TET_get_errnum(tet), apiname, \
                        m_TETlib_api->TET_get_opaque(tet)); \
}

#else

#define TETCPP_TRY      TET_TRY(tet)
#define TETCPP_CATCH  \
TET_CATCH(tet) {\
    pstring message, apiname; \
    convert_exception_strings(message, apiname); \
    throw Exception(message, m_TETlib_api->TET_get_errnum(tet), apiname, \
                        m_TETlib_api->TET_get_opaque(tet)); \
}

#endif

#endif /* !(defined(_MSC_VER) && defined(_MANAGED)) */

template<class pstring, class conv>
class basic_TET
{
    friend class TETNoOpConverter<pstring>;

public:
    class Exception
    {
    public:
	Exception(const pstring& errmsg, int errnum, const pstring& apiname,
                    void *opaque) :
            m_errmsg(errmsg),
              m_errnum(errnum),
              m_apiname(apiname),
              m_opaque(opaque)
        {
        }
        pstring get_errmsg() const { return m_errmsg; }
        int get_errnum() const { return m_errnum; }
        pstring get_apiname() const { return m_apiname; }
        const void *get_opaque() const { return m_opaque; }
    private:
	pstring m_errmsg;
	int m_errnum;
	pstring m_apiname;
	void * m_opaque;
    };

#if defined(_MSC_VER) && defined(_MANAGED)
    struct opaque_wrapper_t
    {
        basic_TET<pstring, conv> *this_ptr;
        void *opaque;
    };

    friend
    void
    errorhandler(TET_cpp *tet, int errortype, const char* msg)
    {
        opaque_wrapper_t *opaque_wrapper =
           static_cast<opaque_wrapper_t *>(TET_get_opaque(tet));

        pstring message, apiname;
        opaque_wrapper->this_ptr->convert_exception_strings(message, apiname);

        throw typename Exception(
                message, TET_get_errnum(tet), apiname, opaque_wrapper->opaque);
    }

    opaque_wrapper_t opaque_wrapper;

public:
    basic_TET(void *opaque = NULL) :
        m_TETlib_api(::TET_get_api())
    {
        check_api(opaque);

        opaque_wrapper.this_ptr = this;
        opaque_wrapper.opaque = opaque;

        tet = m_TETlib_api->TET_new2(errorhandler, &opaque_wrapper);
        if (!tet)
        {
            throw std::bad_alloc();
        }

        set_cpp_binding_options();
    }

    ~basic_TET()
    {
        m_TETlib_api->TET_delete(tet);
    }
#else

#if TETCPP_DL
    class dl_load_error: public std::runtime_error
    {
    public:
        explicit dl_load_error() :
            std::runtime_error("Couldn't load TET DLL")
        {
        }
    };

    /*
     * The dynamic loading variant of the constructor accepts the "opaque"
     * parameter, but requires it to be NULL, as the opaque pointer is used
     * internally by TET_new_dl().
     */
    basic_TET(void *opaque = NULL)
    {
        if (opaque)
        {
            throw std::invalid_argument(
                    "In the dynamic loading variant of the TET C++ binding "
                    "the 'opaque' parameter must be NULL");
        }

        m_TETlib_api = TET_new_dl(&tet);

        if (!m_TETlib_api)
        {
            throw dl_load_error();
        }

        check_api(NULL);

        set_cpp_binding_options();
    }
    
    ~basic_TET()
    {
        TET_delete_dl(m_TETlib_api, tet);
    }
#else /* TETCPP_DL */
    basic_TET(void *opaque = NULL) :
        m_TETlib_api(::TET_get_api())
    {
        check_api(opaque);

        tet = m_TETlib_api->TET_new2(NULL, opaque);
        if (!tet)
        {
            throw std::bad_alloc();
        }

        set_cpp_binding_options();
    }

    ~basic_TET()
    {
        m_TETlib_api->TET_delete(tet);
    }
#endif /* TETCPP_DL */

#include "cpp_wrapped.h"

#endif


    const TET_char_info * get_char_info(int page)
    {
        const TET_char_info *retval = 0;

        TETCPP_TRY
        {
            retval = m_TETlib_api->TET_get_char_info(tet, page);
        }
        TETCPP_CATCH;

        return retval;
    }

    const TET_color_info * get_color_info(int doc, int colorid, const pstring& keyword)
    {
        const TET_color_info *retval = 0;
	std::string keyword_param;
	const char *p_keyword_param;
	param_to_utf8(keyword, keyword_param, p_keyword_param);

        TETCPP_TRY
        {
            retval = m_TETlib_api->TET_get_color_info(tet, doc, colorid, p_keyword_param);
        }
        TETCPP_CATCH;

        return retval;
    }

    void * get_opaque()
    {
        void *retval = NULL;

        TETCPP_TRY
        {
#if defined(_MSC_VER) && defined(_MANAGED)
            retval = opaque_wrapper.opaque;
#else
            retval = m_TETlib_api->TET_get_opaque(tet);
#endif
        }
        TETCPP_CATCH;

        return retval;
    }

    const TET_image_info * get_image_info(int page)
    {
        const TET_image_info *retval = 0;

        TETCPP_TRY
        {
            retval = m_TETlib_api->TET_get_image_info(tet, page);
        }
        TETCPP_CATCH;

        return retval;
    }


    int open_document_callback(void *opaque, size_t filesize,
	size_t (*readproc)(void *opaque, void *buffer, size_t size),
	int (*seekproc)(void *opaque, long offset), const pstring& optlist)
    {
        std::string optlist_param;
        const char *p_optlist_param;
        param_to_utf8(optlist, optlist_param, p_optlist_param);

        int retval = 0;

        TETCPP_TRY
        {
            retval = m_TETlib_api->TET_open_document_callback(tet, opaque, filesize,
                    readproc, seekproc, p_optlist_param);
        }
        TETCPP_CATCH;

        return retval;
    }

    std::string utf16_to_utf8(const std::string utf16string) const
    {
        const char *retval = NULL;

        TETCPP_TRY
        {
            retval = m_TETlib_api->TET_utf16_to_utf8(tet, utf16string.c_str(),
                    static_cast<int>(utf16string.length()), NULL);
        }
        TETCPP_CATCH;

        if (retval)
            return retval;
        else
            return "";
    }

    std::string utf8_to_utf16(const std::string& utf8string,
                const std::string& ordering) const
    {
        int size;
        const char *buf;
        std::string retval;

        TETCPP_TRY
        {
            buf = m_TETlib_api->TET_utf8_to_utf16(tet, utf8string.c_str(), ordering.c_str(),
                    &size);
            if (buf)
                retval.assign(buf, static_cast<size_t>(size));
        }
        TETCPP_CATCH;

        return retval;
    }

    std::string utf32_to_utf16(const std::string& utf32string,
            const std::string& ordering) const
    {
        int size;
        const char *buf;
        std::string retval;

        TETCPP_TRY
        {
            buf = m_TETlib_api->TET_utf32_to_utf16(tet, utf32string.data(),
                static_cast<int>(utf32string.length()), ordering.c_str(), &size);
            if (buf)
                retval.assign(buf, static_cast<size_t>(size));
        }
        TETCPP_CATCH;

        return retval;
    }

    std::string utf16_to_utf32(const std::string& utf16string,
            const std::string& ordering)
    {
        int size;
        const char *buf;
        std::string retval;

        TETCPP_TRY
        {
            buf = m_TETlib_api->TET_utf16_to_utf32(tet, utf16string.data(),
                    static_cast<int>(utf16string.length()), ordering.c_str(),
                    &size);
            if (buf)
                retval.assign(buf, static_cast<size_t>(size));
        }
        TETCPP_CATCH;

        return retval;
    }

    std::string utf8_to_utf32(const std::string& utf8string,
            const std::string& ordering) const
    {
        int size;
        const char *buf;
        std::string retval;

        TETCPP_TRY
        {
            buf = m_TETlib_api->TET_utf8_to_utf32(tet, utf8string.c_str(), ordering.c_str(),
                    &size);
            if (buf)
                retval.assign(buf, static_cast<size_t>(size));
        }
        TETCPP_CATCH;

        return retval;
    }

    std::string utf32_to_utf8(const std::string& utf32string) const
    {
        int size;
        const char *buf;
        std::string retval;

        TETCPP_TRY
        {
            buf = m_TETlib_api->TET_utf32_to_utf8(tet, utf32string.data(),
                static_cast<int>(utf32string.length()), &size);
            if (buf)
                retval.assign(buf, static_cast<size_t>(size));
        }
        TETCPP_CATCH;

        return retval;
    }

    /* Convert a string in an arbitrary encoding to a Unicode string in various formats.
     */
    std::string
    convert_to_unicode(const pstring& inputformat, const std::string& inputstring, const pstring& optlist) const
    {
	std::string retval;

	std::string inputformat_param;
	const char *p_inputformat_param;
	param_to_bytes(inputformat, inputformat_param, p_inputformat_param);

	std::string optlist_param;
	const char *p_optlist_param;
	param_to_utf8(optlist, optlist_param, p_optlist_param);

	TETCPP_TRY
	{
	    int outputlen;
	    const char * const buf =
                    m_TETlib_api->TET_convert_to_unicode(tet, p_inputformat_param,
			inputstring.data(), static_cast<int>(inputstring.length()),
			&outputlen, p_optlist_param);
            if (buf)
                retval.assign(buf, static_cast<size_t>(outputlen));
	}
	TETCPP_CATCH;

	return retval;
    }

protected:
    const TET_api *m_TETlib_api;
    TET_cpp *tet;

private:
    void set_cpp_binding_options(void)
    {
        TETCPP_TRY
        {
            m_TETlib_api->TET_set_option(tet, "objorient");
            if (conv::do_conversion())
            {
                m_TETlib_api->TET_set_option(tet,
                        "binding={C++ conv} unicaplang=true outputformat=utf8 "
                            "apitextformat=utf8");
            }
            else
            {
                switch (sizeof(typename pstring::value_type))
                {
                case sizeof(char):
                    m_TETlib_api->TET_set_option(tet,
                            "binding={C++ legacy} outputformat=utf16 "
                            "apitextformat=utf8");
                    break;

                case utf16_wchar_t_size:
                    m_TETlib_api->TET_set_option(tet,
                            "binding={C++} unicaplang=true outputformat=utf16 "
                            "apitextformat=utf16");
                    break;

                case utf32_wchar_t_size:
                    m_TETlib_api->TET_set_option(tet,
                        "binding={C++} unicaplang=true outputformat=utf32 "
                        "apitextformat=utf32");
                    break;

                default:
                    bad_wchar_size("basic_TET<pstring, conv>::set_cpp_binding_options");
                }
            }
        }
        TETCPP_CATCH;
    }

    void check_api(void *opaque)
    {
        if (m_TETlib_api->sizeof_TET_api != sizeof(TET_api) ||
                m_TETlib_api->major != TET_MAJORVERSION ||
                m_TETlib_api->minor != TET_MINORVERSION)
        {
            pstring message;
            pstring apiname; /* stays empty */

            switch (sizeof(typename pstring::value_type))
            {
            case sizeof(char):
                apiretval_to_pstring("loaded wrong version of TET library", message);
                break;

            case utf16_wchar_t_size:
            case utf32_wchar_t_size:
                apiretval_to_pstring(reinterpret_cast<const char *>(L"loaded wrong version of TET library"), message);
                break;

            default:
                bad_wchar_size("basic_TET<pstring, conv>::check_api");
            }

            throw Exception(message, -1, apiname, opaque);
        }
    }

    enum
    {
        utf16_wchar_t_size = 2,
        utf32_wchar_t_size = 4
    };

    void bad_wchar_size(const char *apiname) const
    {
        std::ostringstream exception_text;
        exception_text << apiname << ": unsupported wchar_t size: "
                        << sizeof(typename pstring::value_type);

        throw std::logic_error(exception_text.str());
    }

    void param_to_utf8(const pstring& param, std::string& tet_param,
                        const char *& tet_ptr) const
    {
        if (conv::do_conversion())
        {
            conv::convert_to_pdf_utf8(*this, param, tet_param);
            tet_ptr = tet_param.c_str();
        }
        else
        {
            const char * const s = reinterpret_cast<const char *>(param.c_str());
            int outputlen;

            switch (sizeof(typename pstring::value_type))
            {
            case sizeof(char):
                /*
                 * Legacy case: Pass through user-supplied string.
                 */
                tet_ptr = s;
                break;

            case utf16_wchar_t_size:
                tet_ptr =
                    m_TETlib_api->TET_convert_to_unicode(tet, "utf16",
                        s, static_cast<int>(param.length() * sizeof(wchar_t)),
                        &outputlen,
			"outputformat=" TETCPP_INTERNAL_OPTFORMAT);

                break;

            case utf32_wchar_t_size:
                tet_ptr =
                    m_TETlib_api->TET_convert_to_unicode(tet, "utf32",
                        s, static_cast<int>(param.length() * sizeof(wchar_t)),
                        &outputlen,
			"outputformat=" TETCPP_INTERNAL_OPTFORMAT);
                break;

            default:
                bad_wchar_size("basic_TET<pstring, conv>::param_to_utf8");
            }
        }
    }

    void param_to_0utf16(const pstring& param, std::string& tet_param,
                        const char *& tet_ptr, int& len) const
    {
        if (conv::do_conversion())
        {
            conv::convert_to_pdf_utf16(*this, param, tet_param);
            tet_ptr = tet_param.c_str();
            len = static_cast<int>(tet_param.length());
        }
        else
        {
            const char * const s = reinterpret_cast<const char *>(param.c_str());

            switch (sizeof(typename pstring::value_type))
            {
            case sizeof(char):
                /*
                 * Legacy case: Pass through user-supplied string with length 0,
                 * string must not contain 0 bytes.
                 */
                tet_ptr = s;
                len = 0;
                break;

            case utf16_wchar_t_size:
                /*
                 * UTF-16 can also be passed through directly
                 */
                tet_ptr = s;
                len = static_cast<int>(param.length() * utf16_wchar_t_size);
                break;

            case utf32_wchar_t_size:
                tet_ptr =
                    m_TETlib_api->TET_convert_to_unicode(tet, "utf32",
                        s, static_cast<int>(param.length() * utf32_wchar_t_size),
                        &len, "outputformat=utf16");

                break;

            default:
                bad_wchar_size("basic_TET<pstring, conv>::param_to_0utf16");
            }
        }
    }

    void param_to_utf16(const pstring& param, std::string& tet_param,
                        const char *& tet_ptr, int& len) const
    {
        if (conv::do_conversion())
        {
            conv::convert_to_pdf_utf16(*this, param, tet_param);
            tet_ptr = tet_param.c_str();
            len = static_cast<int>(tet_param.length());
        }
        else
        {
            const char * const s = reinterpret_cast<const char *>(param.c_str());

            switch (sizeof(typename pstring::value_type))
            {
            case sizeof(char):
                /*
                 * Legacy case: Pass through user-supplied string including
                 * explicit length, string may contain 0 bytes.
                 */
                tet_ptr = s;
                len = static_cast<int>(param.length());
                break;

            case utf16_wchar_t_size:
                /*
                 * UTF-16 can also be passed through directly
                 */
                tet_ptr = s;
                len = static_cast<int>(param.length() * utf16_wchar_t_size);
                break;

            case utf32_wchar_t_size:
                tet_ptr =
                    m_TETlib_api->TET_convert_to_unicode(tet, "utf32",
                        s, static_cast<int>(param.length() * utf32_wchar_t_size),
                        &len, "outputformat=utf16");
                break;

            default:
                bad_wchar_size("basic_TET<pstring, conv>::param_to_utf16");
            }
        }
    }

    void param_to_bytes(const pstring& param, std::string& tet_param,
                        const char *& tet_ptr) const
    {
        if (conv::do_conversion())
        {
            conv::convert_to_pdf_bytes(*this, param, tet_param);
            tet_ptr = tet_param.c_str();
        }
        else
        {
            const size_t size = sizeof(typename pstring::value_type);
            const char *s = reinterpret_cast<const char *>(param.c_str());

            switch (size)
            {
            case sizeof(char):
                tet_ptr = s;
                break;

            case utf16_wchar_t_size:
            case utf32_wchar_t_size:
                {
                    int highchar;

                    const char *deflated =
                            m_TETlib_api->TET_deflate_unicode(tet, s,
                                    static_cast<int>(param.length() * size),
                                    size, &highchar);

                    if (!deflated)
                    {
                        std::ostringstream exception_text;

                        exception_text
                            << "basic_TET::param_to_bytes: high "
                                "Unicode character '0x"
                            << std::hex << highchar
                            << "' is not supported in this character string";

                        throw std::runtime_error(exception_text.str().c_str());
                    }

                    tet_ptr = deflated;
                }
                break;

            default:
                bad_wchar_size("basic_TET<pstring, conv>::param_to_bytes");
            }
        }
    }

    void apiretval_to_pstring(const char * const tet_retval,
                        pstring& cpp_retval) const
    {
        if (conv::do_conversion())
        {
            if (tet_retval)
            {
                conv::convert_to_pstring(*this, tet_retval, cpp_retval);
            }
            else
            {
                cpp_retval.erase();
            }
        }
        else
        {
            if (tet_retval)
            {
                cpp_retval.assign(reinterpret_cast
                                    <const typename pstring::value_type *>
                                        (tet_retval));
            }
            else
            {
                cpp_retval.erase();
            }
        }
    }

    /**
     * Separate routine for converting output strings to pstrings. This is used
     * for the return value of get_text(), where the length is needed because
     * the wchar_t strings are not 0-terminated.
     */
    void outputstring_to_pstring(const char * const tet_retval,
                        pstring& cpp_retval, const int length) const
    {
        if (conv::do_conversion())
        {
            if (tet_retval)
            {
                conv::convert_to_pstring(*this, tet_retval, cpp_retval);
            }
            else
            {
                cpp_retval.erase();
            }
        }
        else
        {
            if (tet_retval)
            {
                cpp_retval.assign(reinterpret_cast
                                    <const typename pstring::value_type *>
                                        (tet_retval),
                                    length);
            }
            else
            {
                cpp_retval.erase();
            }
        }
    }
    
    void
    convert_exception_strings(pstring& message, pstring& apiname) const
    {
        if (conv::do_conversion())
        {
            conv::convert_to_pstring(*this, m_TETlib_api->TET_get_errmsg(tet),
                                        message);
            conv::convert_to_pstring(*this, m_TETlib_api->TET_get_apiname(tet),
                                        apiname);
        }
        else
        {
            /*
             * Without custom converter the TET API returns the error message
             * and the API name in the expected encoding, so just put this
             * string into the output string.
             */
            message = reinterpret_cast<const typename pstring::value_type *>
                                        (m_TETlib_api->TET_get_errmsg(tet));
            apiname = reinterpret_cast<const typename pstring::value_type *>
                                        (m_TETlib_api->TET_get_apiname(tet));
        }
    }

    // Prevent use of copy constructor and assignment operator, as it is
    // fatal to copy the TET_cpp pointer to another object.
    basic_TET(const basic_TET&);
    basic_TET& operator=(const basic_TET&);
};

#if TETCPP_TET_WSTRING
typedef basic_TET<std::wstring, TETNoOpConverter<std::wstring> > TET;
#else
typedef basic_TET<std::string, TETNoOpConverter<std::string> > TET;
#endif

#if TETCPP_USE_PDFLIB_NAMESPACE
} // end of PDFlib namespace
#endif

#endif	// TETLIB_HPP
