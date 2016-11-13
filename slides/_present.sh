#!/usr/bin/env bash

revealgo --theme moon presentation.md 

open http://localhost:3000/slides.html

# to export as PDF, run this file to launch the web ui.
# then add `?print-pdf` to the query string and then use Print menu to Save as PDF.