/* TET sample application for dumping PDF information with pCOS
 *
 * $Id: dumper.c,v 1.10 2010/07/15 10:34:11 rjs Exp $
 */

#include <stdio.h>
#include <stdarg.h>

#include "tetlib.h"

int
main(int argc, char **argv)
{
    TET	*tet;

    /* This is where input files live. Adjust as necessary. */
    const char *searchpath = "{../data}";

    if (argc != 2)
    {   
        fprintf(stderr, "usage: dumper <filename>\n");
        return(2);
    }

    if ((tet = TET_new()) == (TET *) 0)         /* out of memory */
    {
	fprintf(stderr, "dumper: out of memory\n");
	return 99;
    }

    TET_TRY(tet)
    {
	int		count, pcosmode, plainmetadata;
	int		objtype, i, doc;
	const char	*docoptlist = "requiredmode=minimum";
	const char	*globaloptlist = "";
	char optlist[1024];

	TET_set_option(tet, globaloptlist);

	sprintf(optlist, "searchpath={%s}", searchpath);
	TET_set_option(tet, optlist);

	if ((doc = TET_open_document(tet, argv[1], 0, docoptlist)) == -1)
	{
	    printf("ERROR: %s\n", TET_get_errmsg(tet));
	    TET_delete(tet);
	    return 98;
	}

	/* --------- general information (always available) */

	pcosmode = (int) TET_pcos_get_number(tet, doc, "pcosmode");

	printf("   File name: %s\n", TET_pcos_get_string(tet, doc, "filename"));

	printf(" PDF version: %s\n",
	    TET_pcos_get_string(tet, doc, "pdfversionstring"));

	printf("  Encryption: %s\n",
	    TET_pcos_get_string(tet, doc, "encrypt/description"));

	printf("   Master pw: %s\n",
	    TET_pcos_get_number(tet, doc, "encrypt/master") ? "yes" : "no");

	printf("     User pw: %s\n",
	    TET_pcos_get_number(tet, doc, "encrypt/user") ? "yes" : "no");

	printf("Text copying: %s\n",
	    TET_pcos_get_number(tet, doc, "encrypt/nocopy") ? "no" : "yes");

	printf("  Linearized: %s\n",
	    TET_pcos_get_number(tet, doc, "linearized") ? "yes" : "no");

	if (pcosmode == 0)
	{
	    printf("Minimum mode: no more information available\n\n");
	    TET_close_document(tet, doc);
	    TET_delete(tet);
	    return 0;
	}

	/* --------- more details (requires at least user password) */

	printf("PDF/X status: %s\n", TET_pcos_get_string(tet, doc, "pdfx"));

	printf("PDF/A status: %s\n", TET_pcos_get_string(tet, doc, "pdfa"));

	printf("    XFA data: %s\n",
            (int) TET_pcos_get_number(tet, doc, "type:/Root/AcroForm/XFA")
                                    != pcos_ot_null
                            ? "yes" : "no");

	printf("  Tagged PDF: %s\n\n",
	    TET_pcos_get_number(tet, doc, "tagged") ? "yes" : "no");

	printf("No. of pages: %d\n",
	    (int) TET_pcos_get_number(tet, doc, "length:pages"));

	printf(" Page 1 size: width=%g, height=%g\n",
	    TET_pcos_get_number(tet, doc, "pages[%d]/width", 0),
	    TET_pcos_get_number(tet, doc, "pages[%d]/height", 0));

	count = (int) TET_pcos_get_number(tet, doc, "length:fonts");
	printf("No. of fonts: %d\n", count);

	for (i=0; i < count; i++)
	{
	    if (TET_pcos_get_number(tet, doc, "fonts[%d]/embedded", i))
		printf("embedded ");
	    else
		printf("unembedded ");

	    printf("%s font ",
		TET_pcos_get_string(tet, doc, "fonts[%d]/type", i));
	    printf("%s\n",
		TET_pcos_get_string(tet, doc, "fonts[%d]/name", i));
	}

	printf("\n");

	plainmetadata = (int)
	    TET_pcos_get_number(tet, doc, "encrypt/plainmetadata");

	if (pcosmode == 1 && !plainmetadata &&
	    ((int) TET_pcos_get_number(tet, doc, "encrypt/nocopy")))
	{
	    printf("Restricted mode: no more information available\n\n");
	    TET_close_document(tet, doc);
	    TET_delete(tet);
	    return 0;
	}

	/* --------- document info keys and XMP metadata (requires master pw
	 * or plaintext metadata)
	 */

	count = (int) TET_pcos_get_number(tet, doc, "length:/Info");

	for (i=0; i < count; i++)
	{
	    objtype = (int) TET_pcos_get_number(tet, doc, "type:/Info[%d]", i);
	    printf("%12s: ", TET_pcos_get_string(tet, doc, "/Info[%d].key", i));

	    /* Info entries can be stored as string or name objects */
	    if (objtype == pcos_ot_string || objtype == pcos_ot_name)
	    {
		printf("'%10s'\n",
		    TET_pcos_get_string(tet, doc, "/Info[%d]", i));
	    }
	    else
	    {
		printf("(%s object)\n",
		    TET_pcos_get_string(tet, doc, "type:/Info[%d]", i));
	    }
	}

	printf("\nXMP meta data: ");

	objtype = (int)TET_pcos_get_number(tet, doc, "type:/Root/Metadata");
	if (objtype == pcos_ot_stream)
	{
	    const char *contents;
	    int len;

	    contents = (const char *)
		TET_pcos_get_stream(tet, doc, &len, "", "/Root/Metadata");
	    printf("%d bytes ", len);
            /* This demonstrates Unicode conversion. The UTF-8 XMP data
	     * is converted to UTF-16.
	     */
				       
	    TET_convert_to_unicode(tet, "utf8", contents, 0, &len, 
		"outputformat=utf16");
	    printf("(%d Unicode characters)\n\n", len/2);
	}
	else
	{
	    printf("not present\n\n");
	}

	TET_close_document(tet, doc);
    }
    TET_CATCH(tet)
    {
        printf("TET exception occurred in dumper:\n");
        printf("[%d] %s: %s\n",
            TET_get_errnum(tet), TET_get_apiname(tet), TET_get_errmsg(tet));
    }
    TET_delete(tet);

    return 0;
}
