/* Simple PDF glyph dumper based on PDFlib TET
 *
 * $Id: glyphinfo.c,v 1.17 2015/07/08 17:39:01 kurt Exp $
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "tetlib.h"

/* global option list */
static const char *globaloptlist =
    "searchpath={{../data} "
		"{../../../resource/cmap}}";

/* document-specific option list */
static const char *docoptlist = "";

/* page-specific option list */
static const char *pageoptlist = "granularity=word";

/*
 * Print color space and color value details of a glyph's fill color
 */

static void
print_color_value(FILE *outfp, TET *tet, int doc, int colorid)
{
    const TET_color_info *colorinfo;
    const char *csname;			/* color space name */
    int i;

    /* We handle only the fill color, but ignore the stroke color.
     * The stroke color can be retrieved analogously with the
     * keyword "stroke".
     */
    colorinfo = TET_get_color_info(tet, doc, colorid, "usage=fill");

    if (colorinfo->colorspaceid == -1 && colorinfo->patternid == -1)
    {
	fprintf(outfp, " (not filled)");
	return;
    }

    fprintf(outfp, " (");

    if (colorinfo->patternid != -1)
    {
	int patterntype =
	    (int) TET_pcos_get_number(tet, doc, "patterns[%d]/PatternType",
		    colorinfo->patternid);

	if (patterntype == 1)	/* Tiling pattern */
	{
	    int painttype =
		(int) TET_pcos_get_number(tet, doc, "patterns[%d]/PaintType",
			colorinfo->patternid);
	    if (painttype == 1)
	    {
		fprintf(outfp, "colored Pattern)");
		return;
	    }
	    else if (painttype == 2)
	    {
		fprintf(outfp, "uncolored Pattern, base color: ");
		/* FALLTHROUGH to colorspaceid output */
	    }
	}
	else if (patterntype == 2)	/* Shading pattern */
	{
	    int shadingtype =
		(int) TET_pcos_get_number(tet, doc,
			"patterns[%d]/Shading/ShadingType",
			colorinfo->patternid);

	    fprintf(outfp, "shading Pattern, ShadingType=%d)", shadingtype);
	    return;
	}
    }

    csname = TET_pcos_get_string(tet, doc, "colorspaces[%d]/name",
    	colorinfo->colorspaceid);

    fprintf(outfp, "%s", csname);

    /* Emit more details depending on the colorspace type */
    if (!strcmp(csname, "ICCBased"))
    {
	int iccprofileid;
	const char *profilename;
	const char *profilecs;
	const char *errormessage;

	iccprofileid = (int) TET_pcos_get_number(tet, doc,
				"colorspaces[%d]/iccprofileid",
				colorinfo->colorspaceid);

	errormessage = TET_pcos_get_string(tet, doc,
			"iccprofiles[%d]/errormessage", iccprofileid);

	/* Check whether the embedded profile is damaged */
	if (*errormessage)
	{
	    fprintf(outfp, " (%s)", errormessage);
	}
	else
	{
	    profilename =
		TET_pcos_get_string(tet, doc,
		    "iccprofiles[%d]/profilename", iccprofileid);
	    fprintf(outfp, " '%s'", profilename);

	    profilecs = TET_pcos_get_string(tet, doc,
		    "iccprofiles[%d]/profilecs",
				    iccprofileid);
	    fprintf(outfp, " '%s'", profilecs);
	}
    }
    else if (!strcmp(csname, "Separation"))
    {
	const char *colorantname =
	    TET_pcos_get_string(tet, doc, "colorspaces[%d]/colorantname",
	    	colorinfo->colorspaceid);
	fprintf(outfp, " '%s'", colorantname);
    }
    else if (!strcmp(csname, "DeviceN"))
    {
	fprintf(outfp, " ");

	for (i=0; i < colorinfo->n; i++)
	{
	    const char *colorantname =
		TET_pcos_get_string(tet, doc,
		    "colorspaces[%d]/colorantnames[%d]",
		    	colorinfo->colorspaceid, i);

	    fprintf(outfp, "%s", colorantname);

	    if (i != colorinfo->n-1)
		fprintf(outfp, "/");
	}
    }
    else if (!strcmp(csname, "Indexed"))
    {
        int baseid =
            (int) TET_pcos_get_number(tet, doc, "colorspaces[%d]/baseid",
	    	colorinfo->colorspaceid);

        csname = TET_pcos_get_string(tet, doc, "colorspaces[%d]/name", baseid);

        fprintf(outfp, " %s", csname);

    }

    fprintf(outfp, " ");
    for (i=0; i < colorinfo->n; i++)
    {
	fprintf(outfp, "%g", colorinfo->components[i]);

	if (i != colorinfo->n-1)
	    fprintf(outfp, "/");
    }
    fprintf(outfp, ")");
}

int main(int argc, char **argv)
{
    TET *tet;
    FILE *outfp;
    volatile int pageno = 0;

    if (argc != 3)
    {
        fprintf(stderr, "usage: glyphinfo <infilename> <outfilename>\n");
        return(2);
    }

    if ((tet = TET_new()) == (TET *) 0)
    {
        fprintf(stderr, "glyphinfo: out of memory\n");
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

	/* Write UTF-8 BOM */
	fprintf(outfp, "%c%c%c", 0xef, 0xbb, 0xbf);

	/* loop over pages in the document */
        for (pageno = 1; pageno <= n_pages; ++pageno)
        {
            const char *text;
            int page;
            int len;
	    int previouscolorid = -1;

            page = TET_open_page(tet, doc, pageno, pageoptlist);

            if (page == -1)
            {
                fprintf(stderr, "Error %d in %s() on page %d: %s\n",
                    TET_get_errnum(tet), TET_get_apiname(tet), pageno,
                    TET_get_errmsg(tet));
                continue;                        /* try next page */
            }

	    /* Administrative information */
	    fprintf(outfp, "[ Document: '%s' ]\n",
		TET_pcos_get_string(tet, doc, "filename"));

	    fprintf(outfp, "[ Document options: '%s' ]\n",
		docoptlist);

	    fprintf(outfp, "[ Page options: '%s' ]\n",
		pageoptlist);

	    fprintf(outfp, "[ ----- Page %d ----- ]\n", pageno);


            /* Retrieve all text fragments */
            while ((text = TET_get_text(tet, page, &len)) != 0)
            {
                const TET_char_info *ci;

		fprintf(outfp, "[%s]\n", text);  /* print the retrieved text */

                /* Loop over all glyphs and print their details */
                while ((ci = TET_get_char_info(tet, page)) != NULL)
                {
		    const char *fontname;

		    /* Fetch the font name with pCOS (based on its ID) */
		    fontname = TET_pcos_get_string(tet, doc,
		    		"fonts[%d]/name", ci->fontid);

		    /* Print the character */
		    fprintf(outfp, "U+%04X", ci->uv);

		    /* ...and its ASCII representation if appropriate */
		    if (ci->uv >= 0x20 && ci->uv <= 0x7F)
			fprintf(outfp, " '%c'", (unsigned char) ci->uv);

		    /* Print font name, size, and position */
		    fprintf(outfp, " %s size=%.2f x=%.2f y=%.2f",
			fontname, ci->fontsize, ci->x, ci->y);

		    /* Print the color id */
		    fprintf(outfp, " colorid=%d", ci->colorid);

		    /* Check whether the text color changed */
		    if (ci->colorid != previouscolorid)
		    {
			print_color_value(outfp, tet, doc, ci->colorid);
			previouscolorid = ci->colorid;
		    }

		    /* Examine the "type" member */
		    if (ci->type == TET_CT_SEQ_START)
			fprintf(outfp, " ligature_start");

		    else if (ci->type == TET_CT_SEQ_CONT)
			fprintf(outfp, " ligature_cont");

		    /* Separators are only inserted for granularity > word */
		    else if (ci->type == TET_CT_INSERTED)
			fprintf(outfp, " inserted");

		    /* Examine the bit flags in the "attributes" member */
		    if (ci->attributes != TET_ATTR_NONE)
		    {
			if (ci->attributes & TET_ATTR_SUB)
			    fprintf(outfp, "/sub");
			if (ci->attributes & TET_ATTR_SUP)
			    fprintf(outfp, "/sup");
			if (ci->attributes & TET_ATTR_DROPCAP)
			    fprintf(outfp, "/dropcap");
			if (ci->attributes & TET_ATTR_SHADOW)
			    fprintf(outfp, "/shadow");
			if (ci->attributes & TET_ATTR_DEHYPHENATION_PRE)
			    fprintf(outfp, "/dehyphenation_pre");
			if (ci->attributes & TET_ATTR_DEHYPHENATION_ARTIFACT)
			    fprintf(outfp, "/dehyphenation_artifact");
			if (ci->attributes & TET_ATTR_DEHYPHENATION_POST)
			    fprintf(outfp, "/dehyphenation_post");
		    }

		    fprintf(outfp, "\n");
                }

		fprintf(outfp, "\n");
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
