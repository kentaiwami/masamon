/* $Id: get_attachments.c,v 1.13 2015/07/20 10:35:53 tm Exp $
 *
 * PDFlib TET sample application.
 *
 * PDF text extractor which also searches PDF file attachments.
 * The file attachments may be attached to the document or
 * to page-level annotations of type FileAttachment. The former construct
 * also covers PDF 1.7 packages (a.k.a. PDF collections).
 *
 * Nested attachments (file attachments within file attachments,
 * or nested PDF packages) all embedded files are processed recursively.
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
static const char *pageoptlist = "granularity=page";

/* separator to emit after each chunk of text. This depends on the
 * application's needs; for granularity=word a space character may be useful.
 */
#define SEPARATOR  "\n"

/* Extract text from a document for which a TET handle is already available */
static void
extract_text(TET *tet, int doc, FILE *outfp)
{
    int n_pages;
    volatile int pageno = 0;

    /* get number of pages in the document */
    n_pages = (int) TET_pcos_get_number(tet, doc, "length:pages");

    /* loop over all pages */
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

	/* Retrieve all text fragments; This loop is actually not required
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
}

/* Open a named physical or virtual file, extract the text from it,
   search for document or page attachments, and process these recursively.
   Either filename must be supplied for physical files, or data+length
   from which a virtual file will be created.
   The caller cannot create the PVF file since we create a new TET object
   here in case an exception happens with the embedded document - the
   caller can happily continue with his TET object even in case of an
   exception here.
*/
static int
process_document(FILE *outfp, const char *filename, const char *realname,
	const unsigned char *data, int length)
{
    TET *tet;

    if ((tet = TET_new()) == (TET *) 0)
    {
        fprintf(stderr, "extractor: out of memory\n");
        return(4);
    }

    TET_TRY (tet)
    {
	const char *pvfname = "/pvf/attachment";
        int doc;
	int file, filecount;
	int page, pagecount;
	const unsigned char *attdata;
	int attlength;
	int objtype;

	/* Construct a PVF file if data instead of a filename was provided */
	if (!filename)
	{
	    TET_create_pvf(tet, pvfname, 0, data, length, "");
	    filename = pvfname;
	}

        TET_set_option(tet, globaloptlist);

        doc = TET_open_document(tet, filename, 0, docoptlist);

        if (doc == -1)
        {
	    fprintf(stderr,
		"Error %d in %s() (source: attachment '%s'): %s\n",
		TET_get_errnum(tet), TET_get_apiname(tet),
		realname, TET_get_errmsg(tet));
            TET_EXIT_TRY(tet);
            TET_delete(tet);
            return(5);
        }

	/* -------------------- Extract the document's own page contents */
	extract_text(tet, doc, outfp);

	/* -------------------- Process all document-level file attachments */

	/* Get the number of document-level file attachments.  */
	filecount = (int) TET_pcos_get_number(tet, doc,
		"length:names/EmbeddedFiles");

	for (file = 0; file < filecount; file++)
	{
	    const char *attname;

	    /* fetch the name of the file attachment; check for Unicode file
             * name (a PDF 1.7 feature)
             */
            objtype = (int) TET_pcos_get_number(tet, doc,
                    "type:names/EmbeddedFiles[%d]/UF", file);

            if (objtype == pcos_ot_string)
            {
                attname = TET_pcos_get_string(tet, doc,
                    "names/EmbeddedFiles[%d]/UF", file);
            }
            else {
                /* fetch the name of the file attachment */
                objtype = (int) TET_pcos_get_number(tet, doc,
                        "type:names/EmbeddedFiles[%d]/F", file);

                if (objtype == pcos_ot_string)
                {
                    attname = TET_pcos_get_string(tet, doc,
                                "names/EmbeddedFiles[%d]/F", file);
                }
                else
                {
                    attname = "(unnamed)";
                }
            }

	    fprintf(outfp, "\n----- File attachment '%s':\n", attname);

	    /* fetch the contents of the file attachment and process it */
	    objtype = (int) TET_pcos_get_number(tet, doc,
		    "type:names/EmbeddedFiles[%d]/EF/F", file);

	    if (objtype == pcos_ot_stream)
	    {
		attdata = TET_pcos_get_stream(tet, doc, &attlength, "",
			"names/EmbeddedFiles[%d]/EF/F", file);

		(void) process_document(outfp, 0, attname, attdata, attlength);
	    }
	}

	/* -------------------- Process all page-level file attachments */

	pagecount = (int) TET_pcos_get_number(tet, doc, "length:pages");

	/* Check all pages for annotations of type FileAttachment */
	for (page = 0; page < pagecount; page++)
	{
	    int annot, annotcount;

	    annotcount = (int) TET_pcos_get_number(tet, doc,
	                    "length:pages[%d]/Annots", page);

	    for (annot = 0; annot < annotcount; annot++)
	    {
		const char *val;
		char attname[128];

                val = TET_pcos_get_string(tet, doc,
			"pages[%d]/Annots[%d]/Subtype", page, annot);

		sprintf(attname, "page %d, annotation %d", page+1, annot+1);

                if (!strcmp(val, "FileAttachment"))
		{
		    /* fetch the contents of the attachment and process it */
		    objtype = (int) TET_pcos_get_number(tet, doc,
			"type:pages[%d]/Annots[%d]/FS/EF/F", page, annot);

		    if (objtype == pcos_ot_stream)
		    {
			attdata = TET_pcos_get_stream(tet, doc, &attlength, "",
			    "pages[%d]/Annots[%d]/FS/EF/F", page, annot);

			(void) process_document(outfp, 0,
				attname, attdata, attlength);
		    }
                }
            }
	}

	TET_close_document(tet, doc);

	/* If there was no PVF file deleting it won't do any harm */
	TET_delete_pvf(tet, pvfname, 0);
    }

    TET_CATCH (tet)
    {
	fprintf(stderr,
	    "Error %d in %s() (source: attachment '%s'): %s\n",
	    TET_get_errnum(tet), TET_get_apiname(tet),
	    realname, TET_get_errmsg(tet));
    }

    TET_delete(tet);

    return(0);
}

int main(int argc, char **argv)
{
    FILE *outfp;
    int ret = 0;

    if (argc != 3)
    {
        fprintf(stderr, "usage: %s <infilename> <outfilename>\n", argv[0]);
        return(2);
    }

    if ((outfp = fopen(argv[2], "w")) == NULL)
    {
	fprintf(stderr, "Error: couldn't open output file '%s'\n", argv[2]);
	return(3);
    }

    ret = process_document(outfp, argv[1], argv[1], 0, 0);

    fclose(outfp);
    return ret;
}
