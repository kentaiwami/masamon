-------------------------------
CJK CMaps for the PDFlib Family
-------------------------------

PDFlib-CMap-3.0

This package contains CMaps for Chinese (simplified and traditional),
Japanese and Korean. They are required for creating text output with CJK
legacy encodings. The CMaps are not required for creating Unicode CJK output.

The CMaps are also required for extracting Text with PDFlib TET, but
the TET packages already contain all required CMaps.

The CMap files should be installed as follows:

- You can place the CMap files in any convenient directory
  and must manually configure CMap access by setting the searchpath at
  runtime:

  p.set_option("searchpath=/path/to/resource/cmap")

- As an alternative method for configuring access to the CJK CMap files you
  can set the PDFLIBRESOURCEFILE environment variable to point to a UPR
  configuration file which contains a suitable SearchPath definition.

Refer to the PDFlib documentation for more information on CJK text handling.


PDFlib GmbH
Franziska-Bilek-Weg 9
80339 Munich, Germany
phone +49 89 452 33 84-0
info@pdflib.com
www.pdflib.com
