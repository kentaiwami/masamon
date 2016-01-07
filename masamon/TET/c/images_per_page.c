/* Page-based image extractor based on PDFlib TET
 *
 * $Id: images_per_page.c,v 1.4 2015/07/15 12:46:34 tm Exp $
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "tetlib.h"

/* global option list */
static const char *globaloptlist = "searchpath={{../data}}";

/* document-specific option list */
static const char *docoptlist = "";

/* page-specific option list, e.g.
 * "imageanalysis={merge={gap=1} smallimages={maxwidth=20}}"
 */
static const char *pageoptlist = "";

static void report_image_info(TET *tet, int doc, int imageid);

int main(int argc, char **argv)
{
    TET *tet;
    char *outfilebase;
    size_t len;
    volatile int pageno = 0;

    if (argc != 2)
    {
        fprintf(stderr, "usage: images_per_page <infilename>\n");
        return(2);
    }

    if ((tet = TET_new()) == (TET *) 0)
    {
        fprintf(stderr, "images_per_page: out of memory\n");
        return(2);
    }

    outfilebase = (char *) malloc(strlen(argv[1])+1);
    strcpy(outfilebase, argv[1]);

    /* strip PDF suffix if present */
    len = strlen(outfilebase);
    if (len > 4 &&
        (!strcmp(outfilebase + len - 4, ".pdf") ||
         !strcmp(outfilebase + len - 4, ".PDF")))
        outfilebase[len-4] = 0;

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

        /* Get number of pages in the document */
        n_pages = (int) TET_pcos_get_number(tet, doc, "length:pages");

	/* Loop over all pages and extract images */
        for (pageno = 1; pageno <= n_pages; ++pageno)
        {
	    const TET_image_info *ti;
            int page;
            int imagecount = 0;

            page = TET_open_page(tet, doc, pageno, pageoptlist);

            if (page == -1)
            {
                fprintf(stderr, "Error %d in %s() on page %d: %s\n",
                    TET_get_errnum(tet), TET_get_apiname(tet), pageno,
                    TET_get_errmsg(tet));
                continue;                        /* process next page */
            }

	    /* Retrieve all images on the page */
            while ((ti = TET_get_image_info(tet, page)) != 0)
            {
		char imageoptlist[1024];
		int maskid;

		imagecount++;

		/* Report image details: pixel geometry, color space, etc. */
		report_image_info(tet, doc, ti->imageid);

		/* Report placement geometry */
		printf("  placed on page %d at position (%g, %g): "
		       "%dx%dpt, alpha=%g, beta=%g\n",
		    pageno, ti->x, ti->y,
		    (int) ti->width, (int) ti->height,
		    ti->alpha, ti->beta);

		/* Write image data to file */
		sprintf(imageoptlist, "filename={%s_p%d_%d_I%d}",
		        outfilebase, pageno, imagecount, ti->imageid);

		if (TET_write_image_file(tet, doc, ti->imageid, imageoptlist)
		    == -1)
		{
		    printf("\nError %d in %s(): %s\n",
			TET_get_errnum(tet), TET_get_apiname(tet),
			TET_get_errmsg(tet));
		    continue;                  /* process next image */
		}

		/* Check whether the image has a mask attached... */
		maskid = (int) TET_pcos_get_number(tet, doc,
				    "images[%d]/maskid", ti->imageid);

		/* ...and retrieve it if present */
		if (maskid != -1)
		{
		    printf("  masked with ");

		    report_image_info(tet, doc, maskid);
		    
		    sprintf(imageoptlist, "filename={%s_p%d_%d_I%d_mask_I%d}",
			outfilebase, pageno, imagecount, ti->imageid, maskid);

		    if (TET_write_image_file(tet, doc, maskid,
		    	imageoptlist) == -1)
		    {
			printf("\nError %d in %s() for mask image: %s\n",
			    TET_get_errnum(tet), TET_get_apiname(tet),
			    TET_get_errmsg(tet));
		    }
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

/* Print the following information for each image:
 * - pCOS id (required for indexing the images[] array)
 * - pixel size of the underlying PDF Image XObject
 * - number of components, bits per component, and colorspace
 * - mergetype if different from "normal", i.e. "artificial" (=merged)
 *   or "consumed"
 * - "stencilmask" property, i.e. /ImageMask in PDF
 */
static void
report_image_info(TET *tet, int doc, int imageid)
{
    int width, height, bpc, cs, components, mergetype, stencilmask;
    const char *csname;

    width = (int) TET_pcos_get_number(tet, doc,
			"images[%d]/Width", imageid);
    height = (int) TET_pcos_get_number(tet, doc,
			"images[%d]/Height", imageid);
    bpc = (int) TET_pcos_get_number(tet, doc,
			"images[%d]/bpc", imageid);
    cs = (int) TET_pcos_get_number(tet, doc,
			"images[%d]/colorspaceid", imageid);
    components = (int) TET_pcos_get_number(tet, doc,
			"colorspaces[%d]/components", cs);

    printf("image %d: %dx%d pixel, ", imageid, width, height);

    csname = TET_pcos_get_string(tet, doc, "colorspaces[%d]/name", cs);
    printf("%dx%d bit %s", components, bpc, csname);

    if (!strcmp(csname, "Indexed"))
    {
	int basecs;
	const char *basecsname;

	basecs = (int) TET_pcos_get_number(tet, doc, "colorspaces[%d]/baseid",
				cs);
	basecsname =
		TET_pcos_get_string(tet, doc, "colorspaces[%d]/name", basecs);
	printf(" %s", basecsname);
    }

    /* Check whether the image has been created by merging smaller images */
    mergetype = (int) TET_pcos_get_number(tet, doc,
			"images[%d]/mergetype", imageid);
    if (mergetype == 1)
	printf(", mergetype=artificial");

    stencilmask = (int) TET_pcos_get_number(tet, doc,
			"images[%d]/stencilmask", imageid);
    if (stencilmask != 0)
	printf(", used as stencil mask");

    printf("\n");
}
