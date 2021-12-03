# Documentation as code (build script)

The `build_ouput.sh` uses `pandoc` to build a MS Word (`docx`) or PDF file using markdown files as input.

## Usage

```bash
build/build_ouput.sh ${projectName} [ ${outputFormat} ]
```

- `${projectName}` is the name of the final document generated
- `${outputFormat}` defaults to `.docx`. If a valid PDF generator is available, the script is able to generate a PDF file.

## Requierements

The script it's developed and tested in Linux (Debian).

To generate PDF output, *pandoc* requires a LaTeX engine; see [Creating a PDF](https://pandoc.org/MANUAL.html#creating-a-pdf).

### Reference document for MS Word output

Pandoc is able to extract style configuration from an existing MS Word file and apply the same styling to the newly created document [^1].

To have the same reference document -and this, styling- for all generated documents, the template has been placed in a *shared* folder: `/home/xavi/Templates/seat_template.docx`.

This location is currently *hardcoded* in the script.

### PDF-specific configuration

By default, links are not highlighted in PDF documents generated using LaTeX. To enable colored links, the `$pdfOptions` variable includes [^2]:

```bash
pdfOptions="-V colorlinks -V urlcolor=NavyBlue -V toccolor=NavyBlue ..."
```

To avoid backlashes to be interpreted as escape characters, `$pdfOptions` also includes the option (this may cause errors when generating the PDF file) [^2]:

```bash
pdfOptions="... -f markdown-raw_tex"
```

## Notable features

### Autoinclusion of markdown files

To avoid having to manually update the source files to be assembled in the final output document, the `get_source_files` function has been developed:

```bash
get_source_files(){
    sourceDir="${1}"
    declare -a arrMarkdownFiles
    for mdFile in ${sourceDir}*.md
    do
        arrMarkdownFiles=("${arrMarkdownFiles[@]}" "$mdFile")
    done

    echo "${arrMarkdownFiles[*]}"
}
```

This function creates a list of all the markdown files present in the current directory. The list is used as an argument to the command that generates the output file.

To include the markdown files in the intended order, it is recommended to name the files using a numeric prefix.

### Changelog from commit messages

Instead of manually updating the change log for the document, the last 10 commits from the repo are listed and included as part of the generated document.

```bash
create_changelog(){
       changeLogFileName="${1}"
       echo "## Changelog (last 10 changes)" > ${changeLogFileName}
       echo "" >> ${changeLogFileName}
       echo "| CommitID | Author | Commit Msg |" >> ${changeLogFileName}
       echo "| --- | --- | --- |" >> ${changeLogFileName}
       git log -10 --pretty=format:'| %h | %an | %s |' >> ${changeLogFileName}
}
```

[^1]: Pandoc manual [`--reference-doc`](https://pandoc.org/MANUAL.html)

[^2]: Jdhao's blog: [Converting Markdown to Beautiful PDF with Pandoc](https://jdhao.github.io/2019/05/30/markdown2pdf_pandoc/)
