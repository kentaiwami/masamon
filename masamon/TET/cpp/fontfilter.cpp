/*
 * Extract text from PDF and filter according to font name and size. This can be
 * used to identify headings in the document and create a table of contents.
 *
 * Due to the lack of portable conversions in C++ from narrow to wide character
 * the program assumes that the program arguments are encoded as UTF-8.
 *
 * $Id: fontfilter.cpp,v 1.6 2010/07/15 10:34:11 rjs Exp $
 */

#include <iostream>
#include <iomanip>
#include <fstream>


#include "tet.hpp"

using namespace std;
using namespace pdflib;

namespace
{

/* Global option list. */
const wstring globaloptlist = L"searchpath={{../data} "
		 L"{../../../resource/cmap}}";

/* Document specific option list. */
const wstring docoptlist = L"";

/* Page-specific option list. */
const wstring pageoptlist = L"granularity=line";

/* Search text with at least this size (use 0 to catch all sizes). */
const double fontsizetrigger = 10;

/* Catch text where the font name contains this string (use empty string to
 * catch all font names).
 */
const wstring fontnametrigger = L"Bold";

wstring get_wstring(const TET& tet, const string& utf8_string);

} // end of anonymous namespace

int main(int argc, char **argv)
{
    int pageno = 0;

    if (argc != 2)
    {
	wcerr << L"usage: fontfilter <infilename>" << endl;
	return 2;
    }

    try
    {
        TET tet;

	tet.set_option(globaloptlist);

	const wstring docname(get_wstring(tet, string(argv[1])));
	const int doc = tet.open_document(docname, docoptlist);
	if (doc == -1)
	{
	    wcerr << L"Error " << tet.get_errnum() << L" in "
		    << tet.get_apiname() << L"(): " << tet.get_errmsg() << endl;
	    return 2;
	}

	/*
	 * Loop over pages in the document
	 */
	const int n_pages =
	        static_cast<int>(tet.pcos_get_number(doc, L"length:pages"));
	for (pageno = 1; pageno <= n_pages; ++pageno)
	{
	    wstring text;
	    const int page = tet.open_page(doc, pageno, pageoptlist);

	    if (page == -1)
	    {
		wcerr << L"Error " << tet.get_errnum() << L" in "
		    << tet.get_apiname() << L"(): " << tet.get_errmsg() << endl;
		continue; /* try next page */
	    }

	    /* Retrieve all text fragments for the page */
	    while ((text = tet.get_text(page)) != L"")
	    {
		const TET_char_info *ci;

		/* Loop over all characters */
		while ((ci = tet.get_char_info(page)) != NULL)
		{
                    wostringstream path;

		    /* We need only the font name and size; the text
		     * position could be fetched from ci->x and ci->y.
		     */
                    path << L"fonts[" << ci->fontid << "]/name";
                    wstring fontname = tet.pcos_get_string(doc, path.str());

		    /* Check whether we found a match */
		    if (ci->fontsize >= fontsizetrigger
			    && fontname.find(fontnametrigger) != string::npos)
		    {
			wcout << L"[" << fontname << L" "
			    << fixed << setprecision(2) << ci->fontsize << L"] "
			    << text << endl;
		    }

		    /*
		     * In this sample we check only the first character of
		     * each fragment.
		     */
		    break;
		}
	    }

	    if (tet.get_errnum() != 0)
	    {
		wcerr << L"Error " << tet.get_errnum() << L" in "
		    << tet.get_apiname() << L"(): " << tet.get_errmsg() << endl;
	    }

	    tet.close_page(page);
	}

	tet.close_document(doc);
    }
    catch (TET::Exception &ex)
    {
	if (pageno == 0)
	{
	    wcerr << L"Error " << ex.get_errnum() << L" in "
		    << ex.get_apiname() << L"(): " << ex.get_errmsg() << endl;
	}
	else
	{
	    wcerr << L"Error " << ex.get_errnum() << L" in "
		    << ex.get_apiname() << L"() on page " << pageno << L": "
		    << ex.get_errmsg() << endl;
	}

	return 2;
    }

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
