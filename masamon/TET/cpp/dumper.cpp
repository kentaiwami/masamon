/*
 * TET sample application for dumping PDF information with pCOS
 *
 * Due to the lack of portable conversions in C++ from narrow to wide character
 * the program assumes that the program arguments are encoded as UTF-8.
 *
 * $Id: dumper.cpp,v 1.11 2012/01/20 09:32:56 stm Exp $
 */

#include <iostream>
#include <fstream>
#include <string>

#include "tet.hpp"

using namespace std;
using namespace pdflib;

namespace
{

const wstring docoptlist = L"requiredmode=minimum";
const wstring globaloptlist = L"";

wstring get_wstring(const TET& tet, const string& utf8_string);

} // end of anonymous namespace

int main(int argc, char **argv)
{
    /* This is where input files live. Adjust as necessary. */
    const wstring searchpath(L"{../data}");

    try
    {
	if (argc != 2)
	{
	    wcerr << L"usage: dumper <filename>" << endl;
	    return 2;
	}

        TET tet;

	tet.set_option(globaloptlist);

	wstring optlist = L"searchpath={" + searchpath + L"}";
	tet.set_option(optlist);

	wstring docname(get_wstring(tet, string(argv[1])));
	const int doc = tet.open_document(docname, docoptlist);

	if (doc == -1)
	{
	    wcerr << L"Error " << tet.get_errnum()
		<< L" in " << tet.get_apiname()
		<< L"(): " << tet.get_errmsg() << endl;
	    return 2;
	}

	/* --------- general information (always available) */
	const int pcosmode =
	        static_cast<int>(tet.pcos_get_number(doc, L"pcosmode"));

	wcout << L"   File name: " <<
	    tet.pcos_get_string(doc, L"filename") << endl;

	wcout << L" PDF version: " <<
	    tet.pcos_get_string(doc, L"pdfversionstring") << endl;

	wcout << L"  Encryption: " <<
	    tet.pcos_get_string(doc, L"encrypt/description") << endl;

	wcout << L"   Master pw: " <<
	    (tet.pcos_get_number(doc, L"encrypt/master") != 0
	    ? L"yes" : L"no") << endl;

	wcout << L"     User pw: " <<
	    (tet.pcos_get_number(doc, L"encrypt/user") != 0
	    ? L"yes" : L"no") << endl;

	wcout << L"Text copying: " <<
	    (tet.pcos_get_number(doc, L"encrypt/nocopy") != 0
	    ? L"no" : L"yes") << endl;

	wcout << L"  Linearized: " <<
	    (tet.pcos_get_number(doc, L"linearized") != 0
	    ? L"yes" : L"no") << endl;

	if (pcosmode == 0)
	{
	    wcout << L"Minimum mode: no more information available\n\n" << endl;
	    return 0;
	}

	wcout << L"PDF/X status: " << tet.pcos_get_string(doc, L"pdfx") << endl;

	wcout << L"PDF/A status: " << tet.pcos_get_string(doc, L"pdfa") << endl;

	wcout << L"    XFA data: " <<
            (static_cast<int>(
                    tet.pcos_get_number(doc, L"type:/Root/AcroForm/XFA"))
	                                    != pcos_ot_null
	                            ? L"yes" : L"no") << endl;

	wcout << L"  Tagged PDF: " <<
	    (tet.pcos_get_number(doc, L"tagged") != 0 ? L"yes" : L"no") << endl;

	wcout << L"" << endl;

	wcout << L"No. of pages: "
	        << static_cast<int>(tet.pcos_get_number(doc, L"length:pages"))
		<< endl;

	wcout << L" Page 1 size: width="
		<< tet.pcos_get_number(doc, L"pages[0]/width") << L", height="
		<< tet.pcos_get_number(doc, L"pages[0]/height") << endl;

	int count =
	        static_cast<int>(tet.pcos_get_number(doc, L"length:fonts"));
	wcout << L"No. of fonts: " << count << endl;

	int i;
	for (i = 0; i < count; i++) {
	    wostringstream fonts;

	    fonts << L"fonts[" << i << "]/embedded";
	    if (tet.pcos_get_number(doc, fonts.str()) != 0)
		wcout << L"embedded ";
	    else
		wcout << L"unembedded ";

	    fonts.str(L"");
	    fonts << L"fonts[" << i << "]/type";
	    wcout << tet.pcos_get_string(doc, fonts.str()) << L" font ";

	    fonts.str(L"");
	    fonts << L"fonts[" << i << "]/name";
	    wcout << tet.pcos_get_string(doc, fonts.str()) << endl;
	}

	wcout << endl;

	bool plainmetadata =
	    tet.pcos_get_number(doc, L"encrypt/plainmetadata") != 0;

	if (pcosmode == 1 && !plainmetadata
		&& tet.pcos_get_number(doc, L"encrypt/nocopy") != 0)
	{
	    wcout << L"Restricted mode: no more information available" << endl;
	    return 0;
	}

	wstring objtype;
	count = static_cast<int>(tet.pcos_get_number(doc, L"length:/Info"));

	for (i = 0; i < count; i++)
	{
	    wostringstream info;

            info << L"type:/Info[" << i << L"]";
            objtype = tet.pcos_get_string(doc, info.str());

            info.str(L"");
            info << L"/Info[" << i << L"].key";
            wstring key = tet.pcos_get_string(doc, info.str());
            wcout.width(12);
            wcout << key << L": ";

            /* Info entries can be stored as string or name objects */
            info.str(L"");
            if (objtype == L"name" || objtype == L"string")
            {
                info << L"/Info[" << i << L"]";
                wcout << L"'" << tet.pcos_get_string(doc, info.str())
                        << L"'" << endl;
            }
            else
            {
                info << L"type:/Info[" << i << L"]";
                wcout << L"(" << tet.pcos_get_string(doc,info.str())
                        << L" object)" << endl;
            }
	}

	wcout << endl << L"XMP meta data: ";

	objtype = tet.pcos_get_string(doc, L"type:/Root/Metadata");
	if (objtype == L"stream")
	{
	    int len;

	    const unsigned char *contents =
	            tet.pcos_get_stream(doc, &len, L"", L"/Root/Metadata");
	    wcout << len << L" bytes ";

	    /*
	     * This demonstrates Unicode conversion.
	     */
	    const string utf8(reinterpret_cast<const char *>(contents));
	    const string dummy = tet.convert_to_unicode(L"utf8", utf8,
	                            L"outputformat=utf16");
	    wcout << L"(" << dummy.length() / 2
			<< L" Unicode characters)" << endl << endl;
	}
	else
	{
	    wcout << L"not present" << endl << endl;
	}
	
	tet.close_document(doc);
    }
    catch (TET::Exception &ex)
    {
	wcerr << L"Error " << ex.get_errnum()
	    << L" in " << ex.get_apiname()
	    << L"(): " << ex.get_errmsg() << endl;
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
