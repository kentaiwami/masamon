/* Simple PDF text extractor based on PDFlib TET
 *
 * $Id: extractor.c,v 1.56 2010/07/21 10:37:37 rjs Exp $
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "tetlib.h"

/* global option list */
static const char *globaloptlist =
    "searchpath={{../data} {../../../resource/cmap}}";

/* document-specific option list */
static const char *docoptlist = "";

/* page-specific option list */
static const char *pageoptlist = "granularity=page";

/* separator to emit after each chunk of text. This depends on the
 * application's needs; for granularity=word a space character may be useful.
 */
#define SEPARATOR  "\n"

int main(int argc, char **argv)
{
    TET *tet;
    FILE *outfp;
    volatile int pageno = 0;

    if (argc != 3)
    {
        fprintf(stderr, "usage: extractor <infilename> <outfilename>\n");
        return(2);
    }

    if ((tet = TET_new()) == (TET *) 0)
    {
        fprintf(stderr, "extractor: out of memory\n");
        return(2);
    }

    if ((outfp = fopen(argv[2], "w")) == NULL)
    {
	fprintf(stderr, "Couldn't open output file '%s'\n", argv[2]);
	TET_delete(tet);
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

            /* Retrieve all text fragments; This is actually not required
	     * for granularity=page, but must be used for other granularities.
	     */
            while ((text = TET_get_text(tet, page, &len)) != 0)
            {

		fprintf(outfp, "%s", text);  /* print the retrieved text */

		/* print a separator between chunks of text */
		fprintf(outfp, SEPARATOR);
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
    fclose(outfp);

    return 0;
}
