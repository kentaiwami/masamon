/**
 * Extract text from PDF document as XML. If an output filename is specified,
 * write the XML to the output file. Otherwise fetch the XML in memory and
 * then write it to the output file.
 *
 * Due to the lack of portable conversions in C++ from narrow to wide character
 * the program assumes that the program arguments are encoded as UTF-8.
 * 
 * $Id: tetml.cpp,v 1.11 2012/02/26 01:26:26 rjs Exp $
 */

#include <iostream>
#include <fstream>

#include "tet.hpp"

using namespace std;
using namespace pdflib;

namespace
{

/* Global option list. */
const wstring globaloptlist = L"searchpath={{../data} {../../../resource/cmap}}";

/* Document specific option list. */
const wstring basedocoptlist = L"";

/* Page-specific option list. */
/* Remove the tetml= option if you don't need font and geometry information */
const wstring pageoptlist = L"granularity=word tetml={glyphdetails={all}}";

/* set this to true to generate TETML output in memory */
const bool inmemory = false;

wstring get_wstring(const TET& tet, const string& utf8_string);

} // end of anonymous namespace

int main(int argc, char **argv)
{
    if (argc != 3)
    {
	wcerr << L"usage: tetml <pdffilename> <xmlfilename>" << endl;
	return 2;
    }

    try
    {
        TET tet;

	tet.set_option(globaloptlist);

	wostringstream docoptlist;

	if (inmemory)
	{
	    docoptlist << L"tetml={}";
	}
	else
	{
	    docoptlist << L"tetml={filename={" << argv[2] << L"}}";
	}
	docoptlist << L" " << basedocoptlist;

	if (inmemory)
	{
	    wcout << L"Processing TETML output for document \""
		    << argv[1] << L"\" in memory..." << endl;
	}
	else
	{
	    wcout << L"Extracting TETML for document \""
                << argv[1] << L"\" to file \"" << argv[2] << L"\"..." << endl;
	}
	
	const wstring docname(get_wstring(tet, string(argv[1])));
	const int doc = tet.open_document(docname, docoptlist.str());
	if (doc == -1)
	{
	    wcerr << L"Error " << tet.get_errnum() << L" in "
		    << tet.get_apiname() << L"(): " << tet.get_errmsg() << endl;
	    return 2;
	}

	const int n_pages =
	        static_cast<int>(tet.pcos_get_number(doc, L"length:pages"));

	/*
	 * Loop over pages in the document;
	 */
	for (int pageno = 1; pageno <= n_pages; ++pageno)
	{
	    tet.process_page(doc, pageno, pageoptlist);
	}

	/*
	 * This could be combined with the last page-related call.
	 */
	tet.process_page(doc, 0, L"tetml={trailer}");

	if (inmemory)
	{
	    /*
             * Retrieve the generated TETML data from memory. Since we have
	     * only a single call the result will contain the full TETML.
	     */
	    size_t len;
	    const char * const tetml = tet.get_tetml(doc, &len, L"");

	    if (!tetml)
	    {
		wcerr << L"tetml: couldn't retrieve XML data" << endl;
		return 2;
	    }
	    ofstream ofp(argv[2]);
	    if (!ofp)
	    {
		wcerr << L"tetml: couldn't open output file "
                        << argv[2] << endl;
		return 2;
	    }
	    ofp << tetml;
	    ofp.close();
	}

	tet.close_document(doc);
    }
    catch (TET::Exception &ex)
    {
	wcerr << L"Error " << ex.get_errnum() << L" in "
		<< ex.get_apiname() << L"(): " << ex.get_errmsg() << endl;
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
