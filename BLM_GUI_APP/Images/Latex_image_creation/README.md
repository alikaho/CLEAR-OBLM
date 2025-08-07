Layout of CLEAR beamlines
===
> Original code and layout: K. Sjobak, 2018
> Minor modifications:      D. Gamba,  2020
> Multiple versions:        K. Sjobak, 2020
> Removed CLIC CBPMs,
  in-air iBPM, cleanup:     L.A. Dyks, 2021

## Content

- layout.tex:            Main LaTeX file for figure compilation (split beamline)
- layout_unbroken.tex:   Main LaTeX file for figure compilation (continious beamline)
- inputLayout:           Folder with `tikzpicture` figures and macros to generate layouts.
- outputLayout:          Folder with compiled version of layout figures.
- outputLayout_unbroken: Folder with compiled version of long layout figures.

## Figure/layout generation

Generation of the output files should be possible simply by:
```
pdflatex -shell-escape layout.tex  && pdflatex -shell-escape layout_unbroken.tex
```
which will populate the `outputLayout` and `outputLayout_unbroken`folders with `.pdf` files of each single layout part (+many other intermediate/log files).
The generated `layout.pdf` and `layout_unbroken.pdf` files are normnally not of interesting use.
If modifying the figures and having problems with the modifications not "sticking", try deleting the files in the two output folders.

For developing the figures it is reccomended to disable tikzexternalize.
Please remember to re-enable before committing.
