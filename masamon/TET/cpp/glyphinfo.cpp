/*
 * Simple PDF glyph dumper based on PDFlib TET
 *
 * $Id: glyphinfo.cpp,v 1.12 2012/01/20 09:44:14 stm Exp $
 */

#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>

#include "tet.hpp"

using namespace std;
using namespace pdflib;


#include <locale>

namespace
{

/*
 * Declarations in order to avoid cluttering the code with template-specific
 * syntax.
 */
class UTF8Converter;
typedef basic_TET<string, UTF8Converter> UTF8TET;

/*
 * We want to write a UTF-8 file. For this purpose it is more practical
 * to get the text from TET as UTF-8.
 *
 * This is a very basic demonstration of the concept of converters that can
 * be plugged into the basic_TET class as a template parameter. Here it enables
 * the usage of UTF-8 strings with TET. For this type of strings the
 * converter class almost has nothing to do.
 *
 * In the general case the class could take an arbitrary string encoding and
 * convert it to the required encodings. It could check the input parameters for
 * valid encoding, and it should throw a basic_TET<pstring, conv>::Exception
 * to indicate the failure (see comment in convert_to_pdf_bytes() below).
 */
class UTF8Converter
{
public:
    /*
     * Instruct TET to call the user-specified converter routines
     */
    static bool do_conversion()
    {
        return true;
    }

    /*
     * Perform conversion from UTF-8 string to a sequence of bytes. This will
     * be used on parameters that can contain only 7-bit ASCII, so the
     * conversion can simply pass through the string.
     */
    static void
    convert_to_pdf_bytes(const UTF8TET& tet, const string& in, string& out)
    {
        /*
         * Here we could check the input string for valid encoding. In case
         * of an error we would throw an exception like this:
         *
         * throw UTF8PDFlib::Exception("Invalid UTF-8 string", -1,
         *                "UTF8Converter::convert_to_pdf_bytes", 0);
         */
        out = in;
    }

    /*
     * Perform conversion from user-defined UTF-8 string to a std::string
     * containg UTF-8. We can simply copy the string.
     */
    static void
    convert_to_pdf_utf8(const UTF8TET& tet, const string& in, string& out)
    {
        out = in;
    }

    /*
     * Perform conversion from user-defined UTF-8 string to a std::string
     * containing UTF-16. Here we use the PDFlib-supplied conversion routine.
     */
    static void
    convert_to_pdf_utf16(const UTF8TET& tet, const string& in, string& out)
    {
        out = tet.convert_to_unicode("utf8", in, "outputformat=utf16");
    }

    /*
     * Perform conversion from UTF-8 to a user-defined UTF-8 string. We
     * can simply copy the string.
     */
    static void
    convert_to_pstring(const UTF8TET& tet, const char *utf8_in, string& out)
    {
        out.assign(utf8_in);
    }
};

/* global option list */
const string globaloptlist = "searchpath={{../data} "
        "{../../../resource/cmap}}";

/* document-specific option list */
const string docoptlist = "";

/* page-specific option list */
const string pageoptlist = "granularity=word";

/*
 * Print color space and color value details of a glyph's fill color
 */
void
print_color_value(ostream& os, UTF8TET& tet, int doc, int colorid)
{
    ostringstream pcos_path;
    int i;

    /* We handle only the fill color, but ignore the stroke color.
     * The stroke color can be retrieved analogously with the
     * keyword "stroke".
     */
    const TET_color_info *colorinfo =
            tet.get_color_info(doc, colorid, "usage=fill");

    if (colorinfo->colorspaceid == -1 && colorinfo->patternid == -1)
    {
        os << " (not filled)";
        return;
    }

    os << " (";

    if (colorinfo->patternid != -1)
    {
        pcos_path.str("");
        pcos_path << "patterns[" << colorinfo->patternid << "]/PatternType";
        int const patterntype = (int) tet.pcos_get_number(doc, pcos_path.str());

        if (patterntype == 1)   /* Tiling pattern */
        {
            pcos_path.str("");
            pcos_path << "patterns[" << colorinfo->patternid << "]/PaintType";
            int const painttype =
                (int) tet.pcos_get_number(doc, pcos_path.str());
            if (painttype == 1)
            {
                os << "colored Pattern)";
                return;
            }
            else if (painttype == 2)
            {
                os << "uncolored Pattern, base color: ";
                /* FALLTHROUGH to colorspaceid output */
            }
        }
        else if (patterntype == 2)      /* Shading pattern */
        {
            pcos_path.str("");
            pcos_path << "patterns[" << colorinfo->patternid
                   << "]/Shading/ShadingType";
            int const shadingtype =
                (int) tet.pcos_get_number(doc, pcos_path.str());

            os << "shading Pattern, ShadingType=" << shadingtype << ")";
            return;
        }
    }

    pcos_path.str("");
    pcos_path << "colorspaces[" << colorinfo->colorspaceid << "]/name";
    string csname = tet.pcos_get_string(doc, pcos_path.str());

    os << csname;

    /* Emit more details depending on the colorspace type */
    if (csname ==  "ICCBased")
    {
        pcos_path.str("");
        pcos_path << "colorspaces[" << colorinfo->colorspaceid
                    << "]/iccprofileid";
        int const iccprofileid =
                (int) tet.pcos_get_number(doc, pcos_path.str());

        pcos_path.str("");
        pcos_path << "iccprofiles[" << iccprofileid << "]/errormessage";
        string const errormessage = tet.pcos_get_string(doc, pcos_path.str());

        /* Check whether the embedded profile is damaged */
        if (errormessage.length() > 0)
        {
            os << " (" << errormessage << ")";
        }
        else
        {
            pcos_path.str("");
            pcos_path << "iccprofiles[" << iccprofileid << "]/profilename";
            string const profilename =
                        tet.pcos_get_string(doc, pcos_path.str());
            os << " '" << profilename << "'";

            pcos_path.str("");
            pcos_path << "iccprofiles[" << iccprofileid << "]/profilecs";
            string const profilecs =
                    tet.pcos_get_string(doc, pcos_path.str());
            os << " '" << profilecs << "'";
        }
    }
    else if (csname == "Separation")
    {
        pcos_path.str("");
        pcos_path << "colorspaces[" << colorinfo->colorspaceid
                << "]/colorantname";
        string const colorantname = tet.pcos_get_string(doc, pcos_path.str());
        os << " '" << colorantname << "'";
    }
    else if (csname == "DeviceN")
    {
        os << " ";

        for (i = 0; i < colorinfo->n; i++)
        {
            pcos_path.str("");
            pcos_path << "colorspaces[" << colorinfo->colorspaceid
                    << "]/colorantnames[" << i;
            string const colorantname =
                    tet.pcos_get_string(doc, pcos_path.str());

            os << colorantname;

            if (i != colorinfo->n - 1)
                os << "/";
        }
    }
    else if (csname == "Indexed")
    {
        pcos_path.str("");
        pcos_path << "colorspaces[" << colorinfo->colorspaceid
                << "]/baseid";
        int const baseid = (int) tet.pcos_get_number(doc, pcos_path.str());

        pcos_path.str("");
        pcos_path << "colorspaces[" << baseid << "]/name";
        csname = tet.pcos_get_string(doc, pcos_path.str());

        os << " " << csname;
    }

    os << " ";
    for (i = 0; i < colorinfo->n; i++)
    {
        os << colorinfo->components[i];

        if (i != colorinfo->n - 1)
            os << "/";
    }
    os << ")";
}

} // end of anonymous namespace

int main(int argc, char **argv)
{
    int pageno = 0;
    try
    {
        UTF8TET tet;

        if (argc != 3)
        {
            cerr << "usage: glyphinfo <infilename> <outfilename>" << endl;
            return(2);
        }

        /*
         * Create an outputstream that is written as UTF-8.
         */
        ofstream ofp(argv[2], ios_base::binary);

        if (!ofp)
        {
            cerr << "Couldn't open output file " << argv[2] << endl;
            return 2;
        }

        /* And first write a BOM */
        ofp << "\xef\xbb\xbf";

        /* Hex values in uppercase */
        ofp << std::uppercase;

        tet.set_option(globaloptlist);

        const int doc = tet.open_document(argv[1], docoptlist);

        if (doc == -1)
        {
            cerr << "Error " << tet.get_errnum()
                << " in " << tet.get_apiname() << "(): "
                << tet.get_errmsg() << endl;
            return 2;
        }

        /* get number of pages in the document */
        const int n_pages = (int) tet.pcos_get_number(doc, "length:pages");

        /* loop over pages in the document */
        for (pageno = 1; pageno <= n_pages; ++pageno)
        {
            string text;
            const int page = tet.open_page(doc, pageno, pageoptlist);
            int previouscolorid = -1;

            if (page == -1)
            {
                cerr << "Error " << tet.get_errnum()
                    << " in " << tet.get_apiname()
                    << "(): " << tet.get_errmsg() << endl;
                continue;                        // try next page
            }

            // Administrative information
            ofp << endl;
            ofp << "[ Document: '"
                        << tet.pcos_get_string(doc, "filename")
                        << "' ]" << endl;

            ofp << "[ Document options: '" << docoptlist
                        << "' ]" << endl;

            ofp << "[ Page options: '" << pageoptlist
                        << "' ]" << endl;

            ofp << "[ ----- Page " << pageno
                        << "----- ]" << endl;

            // Retrieve all text fragments
            while ((text = tet.get_text(page)) != "")
            {
                const TET_char_info *ci;

                ofp << "[" << text << "]";
		ofp << endl;

                // Loop over all glyphs and print their details
                while ((ci = tet.get_char_info(page)) != NULL)
                {
                    ostringstream path;

                    // Fetch the font name with pCOS (based on its ID)
                    path << "fonts[" << ci->fontid << "]/name";
                    string fontname = tet.pcos_get_string(doc, path.str());

                    // Print the character
                    ofp << "U+";
                    ofp.setf(ios_base::hex, ios_base::basefield);
                    ofp.fill('0');
                    ofp.width(4);
                    ofp << ci->uv;
                    ofp.setf(ios_base::dec, ios_base::basefield);

                    // ...and its ASCII representation if appropriate
                    if (ci->uv >= 0x20 && ci->uv <= 0x7F)
                        ofp << " '" << (char) ci->uv << "'";

                    // Print font name, size, and position
                    ofp.setf(ios_base::fixed, ios_base::floatfield);
                    ofp.precision(2);
                    ofp << " " << fontname
                        << " size=" << ci->fontsize
                        << " x=" << ci->x
                        << " y=" << ci->y;

                    /* Print the color id */
                    ofp << " colorid=" << ci->colorid;

                    /* Check whether the text color changed */
                    if (ci->colorid != previouscolorid)
                    {
                        print_color_value(ofp, tet, doc, ci->colorid);
                        previouscolorid = ci->colorid;
                    }

                    // Examine the "type" member
                    if (ci->type == TET_CT_SEQ_START)
                        ofp << " ligature_start";

                    else if (ci->type == TET_CT_SEQ_CONT)
                        ofp << " ligature_cont";

                    // Separators are only inserted for granularity > word
                    else if (ci->type == TET_CT_INSERTED)
                        ofp << " inserted";

                    /* Examine the bit flags in the "attributes" member */
                    if (ci->attributes != TET_ATTR_NONE)
                    {
                        if (ci->attributes & TET_ATTR_SUB)
                            ofp << "/sub";
                        if (ci->attributes & TET_ATTR_SUP)
                            ofp << "/sup";
                        if (ci->attributes & TET_ATTR_DROPCAP)
                            ofp << "/dropcap";
                        if (ci->attributes & TET_ATTR_SHADOW)
                            ofp << "/shadow";
                        if (ci->attributes & TET_ATTR_DEHYPHENATION_PRE)
                            ofp << "/dehyphenation_pre";
                        if (ci->attributes & TET_ATTR_DEHYPHENATION_ARTIFACT)
                            ofp << "/dehyphenation_artifact";
                        if (ci->attributes & TET_ATTR_DEHYPHENATION_POST)
                            ofp << "/dehyphenation_post";
                    }
                    ofp << endl;
                }
                ofp << endl;
            }

            if (tet.get_errnum() != 0)
            {
                ofp << "Error " << tet.get_errnum() << " in "
                    << tet.get_apiname() << "(): " << tet.get_errmsg() << endl;
            }

            tet.close_page(page);
        }

        tet.close_document(doc);

        ofp.close();
    }

    catch (UTF8TET::Exception &ex) {
        if (pageno == 0)
        {
            cerr << "Error " << ex.get_errnum()
                << " in " << ex.get_apiname()
                << "(): " << ex.get_errmsg() << endl;
        }
        else
        {
            cerr << "Error " << ex.get_errnum()
                << " in " << ex.get_apiname()
                << "() on page " << pageno
                << ": " << ex.get_errmsg() << endl;
        }
        return 2;
    }

    return 0;
}
