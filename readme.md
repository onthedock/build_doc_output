# Documentation as code (build script)

The `build_ouput.sh` uses `pandoc` to build a MS Word (`docx`) or PDF file using markdown files as input.

## Usage

```bash
Basic usage:
    ./build_output.sh -p <project-name>
Options:
    -p | --project-name <project-name>: Name of the generated file (REQUIRED)
    -f | --format [ docx | pdf ]: Format of the generated file
                                  Default: 'docx'
    -t | --template-file <path to reference file>.docx
                         Contains the styles used in the generated file
                         Default: '' (No reference document)
    -o | --output-dir <output-folder>
                      Default: (script folder)
    --no-changelog: Disables creating a changelog from commit messages
```

The only requiered parameter is the *project name*, that is, the name of the file (without extension) to be generated.

## Including the script as a submodule

This script [^note] can be included as a *submodule* in the Git project where you are writing documentation as mardown files; e.g., inside a `build/` folder:

```bash
project-docs/
    .
    ├── build
    │   ├── build_ouput.sh
    │   └── readme.md
    ├── 000-cover.md
    ├── 010-chapter-1.md
    └── 020-chapter-2.md
```

To add it as a submodule, use:

```bash
git submodule add <remote_url> <destination_folder> 
```

E.g:

```bash
git submodule add https://github.com/onthedock/build_doc_output build
```

## Requierements

The script it's developed and tested in Linux (Debian).

To generate PDF output, *pandoc* requires a LaTeX engine; see [Creating a PDF](https://pandoc.org/MANUAL.html#creating-a-pdf).

### Reference document for MS Word output

Pandoc is able to extract style configuration from an existing MS Word file and apply the same styling to the newly created document [^1].

Use `--template-file path/to/reference.docx` to use the styles defined in `refrence.docx` in the generated file.

### PDF-specific configuration

It is possible to pass configuration to the LaTeX engine when generating a PDF file. Those options are included in the `$pdfOptions` variable.

By default, links are not highlighted in PDF documents generated using LaTeX. To enable colored links, the `$pdfOptions` variable includes [^2]:

```bash
pdfOptions="-V colorlinks -V urlcolor=NavyBlue -V toccolor=NavyBlue ..."
```

Backslashes in markdown files can be interpreted as escape characters when creating PDF files by some LaTeX engines. To skip this possibility, `$pdfOptions` also includes the option to pass markdown source as *raw* input to the LaTeX engine (no interpretation) [^2]:

```bash
pdfOptions="... -f markdown-raw_tex"
```

## Features

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

This feature can be disabled by passing the `--no-changelog` flag.

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

[^note]: The script's repository, to be precise.

[^1]: Pandoc manual [`--reference-doc`](https://pandoc.org/MANUAL.html)

[^2]: Jdhao's blog: [Converting Markdown to Beautiful PDF with Pandoc](https://jdhao.github.io/2019/05/30/markdown2pdf_pandoc/)
