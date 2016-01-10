/* Resource-based image extractor based on PDFlib TET
 *
 * $Id: image_resources.c,v 1.9 2015/07/15 12:46:20 tm Exp $
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "tetlib.h"

/* global option list */
static const char *globaloptlist =
    "searchpath={{../data}}";

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

    if (argc != 2)
    {
        fprintf(stderr, "usage: image_resources <filename>\n");
        return(2);
    }

    if ((tet = TET_new()) == (TET *) 0)
    {
        fprintf(stderr, "image_resources: out of memory\n");
        return(2);
    }

    outfilebase = (char *) malloc(strlen(argv[1])+1);
    strcpy(outfilebase, argv[1]);

    /* strip .pdf suffix if present */
    len = strlen(outfilebase);
    if (len > 4 &&
        (!strcmp(outfilebase + len - 4, ".pdf") ||
         !strcmp(outfilebase + len - 4, ".PDF")))
        outfilebase[len-4] = 0;

    TET_TRY (tet)
    {
        int pageno, n_pages;
	int imageid, n_images;
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

	/* Loop over all pages to trigger image merging */
        for (pageno = 1; pageno <= n_pages; ++pageno)
        {
            int page;

            page = TET_open_page(tet, doc, pageno, pageoptlist);

            if (page == -1)
            {
                fprintf(stderr, "Error %d in %s() on page %d: %s\n",
                    TET_get_errnum(tet), TET_get_apiname(tet), pageno,
                    TET_get_errmsg(tet));
                continue;                        /* process next page */
            }

	    if (TET_get_errnum(tet) != 0)
	    {
		fprintf(stderr, "Error %d in %s() on page %d: %s\n",
		    TET_get_errnum(tet), TET_get_apiname(tet), pageno,
		    TET_get_errmsg(tet));
	    }

            TET_close_page(tet, page);
	}

	/* Get the number of images in the document  */
	n_images = (int) TET_pcos_get_number(tet, doc, "length:images");

	/* Loop over all image resources */
	for (imageid = 0; imageid < n_images; imageid++)
	{
	    char imageoptlist[1024];

	    /* Skip images which have been consumed by merging */
	    int mergetype = (int) TET_pcos_get_number(tet, doc, 
			"images[%d]/mergetype", imageid);
	    if (mergetype == 2)
		continue;

	    /* Skip small images (see "smallimages" option) */
	    if (TET_pcos_get_number(tet, doc, "images[%d]/small", imageid))
	        continue;

	    /* Report image details: pixel geometry, color space, etc. */
	    report_image_info(tet, doc, imageid);

	    /* Write image data to file */
	    sprintf(imageoptlist, "filename={%s_I%d}", outfilebase, imageid);

	    if (TET_write_image_file(tet, doc, imageid, imageoptlist) == -1)
	    {
		printf("\nError %d in %s(): %s\n",
		    TET_get_errnum(tet), TET_get_apiname(tet),
		    TET_get_errmsg(tet));
	    }
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

/* Print the following information for each image:
 * - pCOS id (required for indexing the images[] array)
 * - pixel size of the underlying PDF Image XObject
 * - number of components, bits per component, and colorspace
 * - mergetype if different from "normal", i.e. "artificial" (=merged)
 *   or "consumed"
 * - "stencilmask" property, i.e. /ImageMask in PDF
 * - pCOS id of mask image, i.e. /Mask or /SMask in PDF
 */
static void
report_image_info(TET *tet, int doc, int imageid)
{
    int width, height, bpc, cs, components, mergetype, stencilmask, maskid;
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

    /* Check whether the image has an attached mask */
    maskid = (int) TET_pcos_get_number(tet, doc, "images[%d]/maskid", imageid);

    if (maskid != -1)
        printf(", masked with image %d", maskid);

    printf("\n");
}
