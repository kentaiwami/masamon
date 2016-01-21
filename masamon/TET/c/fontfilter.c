/* Extract text from PDF and filter according to font name and size.
 * This can be used to identify headings in the document and create a
 * table of contents.
 *
 * $Id: fontfilter.c,v 1.5 2008/12/23 17:31:08 rjs Exp $
 */

#include <stdio.h>
#include <string.h>

#include "tetlib.h"

/* global option list */
static const char *globaloptlist =
    "searchpath={{../data} "
                "{../../../resource/cmap}}";

/* document-specific option list */
static const char *docoptlist = "";

/* page-specific option list */
static const char *pageoptlist = "granularity=line";

/* Search text with at least this size (use 0 to catch all sizes) */
double fontsizetrigger = 10;

/* Catch text where the font name contains this string
 * (use empty string to catch all font names)
 */
const char *fontnametrigger = "Bold";

int main(int argc, char **argv)
{
    TET *tet;
    volatile int pageno = 0;

    if (argc != 2)
    {
        fprintf(stderr, "usage: fontfilter <infilename>\n");
        return(2);
    }

    if ((tet = TET_new()) == (TET *) 0)
    {
        fprintf(stderr, "fontfilter: out of memory\n");
        return(2);
    }

    TET_TRY (tet)
    {
        int n_pages;
        int doc;

        TET_set_option(tet, globaloptlist);

        doc = TET_open_document(tet, argv[1], 0, docoptlist);

        if (doc == -1)
        {
            fprintf(stderr, "Error %d in %s(): %s\n",
                TET_get_errnum(tet), TET_get_apiname(tet), TET_get_errmsg(tet));
            TET_EXIT_TRY(tet);
            TET_delete(tet);
            return(2);
        }

        /* get number of pages in the document */
        n_pages = (int) TET_pcos_get_number(tet, doc, "length:pages");

	/* loop over pages in the document */
        for (pageno = 1; pageno <= n_pages; ++pageno)
        {
            const char *text;
            int page;
            int len;

            page = TET_open_page(tet, doc, pageno, pageoptlist);

            if (page == -1)
            {
                fprintf(stderr, "Error %d in %s() on page %d: %s\n",
                    TET_get_errnum(tet), TET_get_apiname(tet), pageno,
                    TET_get_errmsg(tet));
                continue;                        /* try next page */
            }

            /* Retrieve all text fragments for the page */
            while ((text = TET_get_text(tet, page, &len)) != 0)
            {
                const TET_char_info *ci;
		const char *fontname;


                /* Loop over all characters */
                while ((ci = TET_get_char_info(tet, page)) != NULL)
                {
		    /* We need only the font name and size; the text 
                     * position could be fetched from ci->x and ci->y.
		     */
		    fontname = TET_pcos_get_string(tet, doc,
		    		"fonts[%d]/name", ci->fontid);

		    /* Check whether we found a match */
		    /* C only: some versions of strstr don't allow empty
		       strings, so we better check */
		    if (ci->fontsize >= fontsizetrigger &&
			(!*fontnametrigger||strstr(fontname, fontnametrigger)))
		    {
			/* print the retrieved font name, size, and text */
			printf("[%s %.2f] %s\n",
			    fontname, ci->fontsize, text);
		    }

		    /* In this sample we check only the first character of
		     * each fragment.
		     */
		    break;
                }
            }

            if (TET_get_errnum(tet) != 0)
            {
                fprintf(stderr, "Error %d in %s() on page %d: %s\n",
                    TET_get_errnum(tet), TET_get_apiname(tet), pageno,
                    TET_get_errmsg(tet));
            }

            TET_close_page(tet, page);
        }

        TET_close_document(tet, doc);
    }

    TET_CATCH (tet)
    {
        if (pageno == 0)
            fprintf(stderr, "Error %d in %s(): %s\n",
                TET_get_errnum(tet), TET_get_apiname(tet), TET_get_errmsg(tet));
        else
            fprintf(stderr, "Error %d in %s() on page %d: %s\n",
                TET_get_errnum(tet), TET_get_apiname(tet), pageno,
                TET_get_errmsg(tet));
    }

    TET_delete(tet);

    return 0;
}
