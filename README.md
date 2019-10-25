# Dillmann lexicon app
This application, built in eXist-db uses basic tecniques to display data from the digitization process of the Lexicon Linguae Aethiopicae of Augustus Dillmann. It is deployed at the moment only for registered users with the relevant data at the University of Hamburg.
The application assumes a collection DillmannData where the files are stored. Data is encoded in TEI using the Dictionary module.

this dataset has the following doi:10.25592/uhhfdm.130
## Features

### preprocessing
Heavy preprocessing of data has been carried out with regex in oxygen to encode the text starting from a txt version provided by Andreas Ellwardt.
The data is being processed within this application to improve the structure and the reusability of the large amount of information provided by this work. all parts of speech, abbreviations, citations, translations, notes, nesting of meaning, column breaks, internal references etc. have been marked up in TEI XML and the app relies on that markup as a structure

### Search
* homophones of the ethiopic language are searched as a standard if not otherways specified. 
* modes as per eXist-db sample app are also provided, with code from the demo application of eXist-db only slightly modified.

### xquery
* the functions allow a group of editors to edit records with a simplified syntax in simple text, with no editor, with two XSLT transformations. The form contains also the guidelines for the editing
* before submitting the new file this is validated against the schema.
* columns are computed from the data and linked to the pdf version available [here](http://www.tau.ac.il/~hacohen/Lexicon.html)

### jquery
* bibliography is pulled from [Zotero EthioStudies group library](https://www.zotero.org/groups/358366/ethiostudies)
* queries to Beta Masaheft for related passages and text citations are also done with jquery. each citation in the format John 1.1 is linked in a popup to the exact passage if this is available in Beta Masaheft, otherwise it is linked to the record of the edition.

### RESTXQ
* api search of text is also set for use
* list from api can be obtained
* records can be called by id

The code is provided without data for documentation purposes and for reuse of parts for other dictionary projects. Where possible documentation has also been provided in the code.
