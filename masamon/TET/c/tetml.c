/* TET sample application for dumping PDF information in the XML language TETML
 *
 * $Id: tetml.c,v 1.26 2010/07/22 18:47:46 tm Exp $
 */

#include <stdio.h>
#include <string.h>

#include "tetlib.h"

/* global option list */
static const char *globaloptlist =
    "searchpath={{../data} "
                "{../../../resource/cmap}}";

/* document-specific option list */
static const char *basedocoptlist = "";

/* page-specific option list */
/* Remove the tetml= option if you don't need font and geometry information */
static const char *pageoptlist = "granularity=word tetml={glyphdetails={all}}";

/* set this to 1 to generate TETML output in memory */
static int inmemory = 0;


int main(int argc, char **argv)
{
    TET *tet;
    const char *tetml;

    if (argc != 3)
    {
        fprintf(stderr, "usage: tetml <pdffilename> <xmlfilename>\n");
        return(2);
    }

    if ((tet = TET_new()) == (TET *) 0)
    {
        fprintf(stderr, "tetml: out of memory\n");
        return(2);
    }

    TET_TRY (tet)
    {
	int pageno;
        int n_pages;
	char docoptlist[1024];
        int doc;
	size_t len;

        TET_set_option(tet, globaloptlist);

	if (inmemory)
	    sprintf(docoptlist, "tetml={} %s", basedocoptlist);
	else
	    sprintf(docoptlist, "tetml={filename={%s}} %s",
		argv[2], basedocoptlist);

        doc = TET_open_document(tet, argv[1], 0, docoptlist);

        if (doc == -1)
        {
            fprintf(stderr, "Error %d in %s(): %s\n",
                TET_get_errnum(tet), TET_get_apiname(tet), TET_get_errmsg(tet));
            TET_EXIT_TRY(tet);
            TET_delete(tet);
            return(2);
        }

        n_pages = (int) TET_pcos_get_number(tet, doc, "length:pages");

	/* loop over pages in the document */
        for (pageno = 1; pageno <= n_pages; ++pageno)
        {
            (void) TET_process_page(tet, doc, pageno, pageoptlist);
        }

	/* This could be combined with the last page-related call */
	(void) TET_process_page(tet, doc, 0, "tetml={trailer}");

	if (inmemory)
        {
            FILE *fp = fopen(argv[2], "wb");

            if (fp == NULL)
	    {
		fprintf(stderr, "tetml: couldn't open output file '%s'\n",
			argv[2]);
		return(3);
	    }

	    /* Retrieve the generated TETML data from memory. Since we have
	     * only a single call the result will contain the full TETML.
	     */

	    tetml = TET_get_tetml(tet, doc, &len, "");
	    if (tetml == NULL)
	    {
		fprintf(stderr, "tetml: couldn't retrieve XML data\n");
		fprintf(stderr, "%s\n", TET_get_errmsg(tet));

		return(4);
	    }

	    fwrite(tetml, 1, len, fp);
	    fclose(fp);
        }

        TET_close_document(tet, doc);
    }

    TET_CATCH (tet)
    {
	fprintf(stderr, "Error %d in %s(): %s\n",
	    TET_get_errnum(tet), TET_get_apiname(tet), TET_get_errmsg(tet));
    }

    TET_delete(tet);

    return 0;
}
