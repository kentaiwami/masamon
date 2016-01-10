/*
 * PDF text extractor based on PDFlib TET
 *
 * The text is written as UTF-16 or as UTF-32 in native byte order, depending
 * on the size of wchar_t.
 *
 * Due to the lack of portable conversions from narrow to wide character
 * the program assumes that the program arguments are encoded as UTF-8.
 *
 * $Id: extractor.cpp,v 1.39 2012/01/20 09:44:14 stm Exp $
 */

#include <iostream>
#include <iomanip>
#include <fstream>
#include <algorithm>

#include "tet.hpp"

using namespace std;
using namespace pdflib;

namespace
{

/*  global option list */
const wstring globaloptlist =
	    L"searchpath={{../data} {../../../resource/cmap}}";

/* document-specific  option list */
const wstring docoptlist = L"";

/* page-specific option list */
const wstring pageoptlist = L"granularity=page";

/* separator to emit after each chunk of text. This depends on the
 * applications needs; for granularity=word a space character may be useful.
 */
const string utf8_separator = "\n";

wstring get_wstring(const TET& tet, const string& utf8_string);

} // end of anonymous namespace

int main(int argc, char **argv)
{
    ofstream out;
    int pageno = 0;
    
    try
    {
        TET tet;

        if (argc != 3)
        {
            wcerr << L"usage: extractor <infilename> <outfilename>" << endl;
            return(2);
        }

        /* get separator in native byte ordering */
        wstring const separator(get_wstring(tet, utf8_separator));

        out.open(argv[2], ios::binary);
        if (!out.is_open())
        {
            wcerr << L"Couldn't open output file " << argv[2] << endl;
            return(2);
        }
        /* And first write a BOM */
        if (sizeof(wchar_t) == 4)
        {
            unsigned int bom = 0xfeff;
            out.write(reinterpret_cast<char*>(&bom), sizeof(wchar_t));
        }
        else
        {
            unsigned short bom = 0xfeff;
            out.write(reinterpret_cast<char*>(&bom), sizeof(wchar_t));
        }


        tet.set_option(globaloptlist);

        /*
         * Caution: For simplicity we assume that the program arguments are
         * encoded as UTF-8, which might not be true in all cases!
         */
        wstring doc_name(get_wstring(tet, string(argv[1])));
        const int doc = tet.open_document(doc_name, docoptlist);

        if (doc == -1)
        {
            wcerr << L"Error " << tet.get_errnum()
                << L" in " << tet.get_apiname() << L"(): "
                << tet.get_errmsg() << endl;
            return 2;
        }

        /* get number of pages in the document */
        const int n_pages = (int) tet.pcos_get_number(doc, L"length:pages");

        /* loop over pages in the document */
        for (pageno = 1; pageno <= n_pages; ++pageno)
        {
            wstring text;
            const int page = tet.open_page(doc, pageno, pageoptlist);

            if (page == -1)
            {
                wcerr << L"Error " << tet.get_errnum()
                    << L" in " << tet.get_apiname()
                    << L"(): " << tet.get_errmsg() << endl;
                continue;                        /* try next page */
            }

            /* Retrieve all text fragments; This is actually not required
             * for granularity=page, but must be used for other granularities.
             */
            while ((text = tet.get_text(page)) != L"")
            {
                /* print the retrieved text as UTF-16 or UTF-32 encoded in
                 * the native byte order
                 */
                out.write(reinterpret_cast<const char *>(text.c_str()),
                        static_cast<streamsize>(text.size())
                            * sizeof(wstring::value_type));

                /* print a separator between chunks of text */
                out.write(reinterpret_cast<const char *>(separator.c_str()),
                        static_cast<streamsize>(separator.size())
                            * sizeof(wstring::value_type));
            }

            if (tet.get_errnum() != 0)
            {
                wcerr << L"Error " << tet.get_errnum()
                    << L" in " << tet.get_apiname()
                    << L"() on page " << pageno
                    << L": " << tet.get_errmsg() << endl;
            }

            tet.close_page(page);
        }

        tet.close_document(doc);
    }
    catch (TET::Exception &ex) {
        if (pageno == 0)
        {
            wcerr << L"Error " << ex.get_errnum()
                << L" in " << ex.get_apiname()
                << L"(): " << ex.get_errmsg() << endl;
        }
        else
        {
            wcerr << L"Error " << ex.get_errnum()
                << L" in " << ex.get_apiname()
                << L"() on page " << pageno
                << L": " << ex.get_errmsg() << endl;
        }
        return 2;
    }

    out.close();
    return 0;
}

namespace
{

/*
 * Get a wstring for the given string.
 */
wstring get_wstring(const TET& tet, const string& utf8_string)
{
    const size_t size = sizeof(wstring::value_type);
    string wide_string;

    switch (size)
    {
    case 2:
        wide_string = tet.convert_to_unicode(L"auto", utf8_string,
                                                L"outputformat=utf16");
        break;

    case 4:
        wide_string = tet.convert_to_unicode(L"auto", utf8_string,
                                                L"outputformat=utf32");
        break;

    default:
        throw std::logic_error("Unsupported wchar_t size");
    }

    return wstring(reinterpret_cast<const wchar_t *>(wide_string.data()),
            wide_string.length() / size);
}

} // end anonymous namespace
