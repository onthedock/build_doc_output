#!/usr/bin/env bash

usage() {
       echo "Basic usage:"
       echo "./build_output.sh -p <project-name>"
       echo "Options:"
       echo " -p | --project-name <project-name>: Name of the generated file (REQUIRED)"
       echo " -f | --format [ docx | pdf ]: Format of the generated file"
       echo "                               Default: 'docx'"
       echo " -t | --template-file <path to reference file>.docx"
       echo "                      Contains the styles used in the generated file"
       echo "                      Default: '' (No reference document)"
       echo " -o | --output-dir <output-folder>"
       echo "                   Default: (script folder)"
       echo " --no-changelog: Disables creating a changelog from commit messages"
}

parse_cli_args () {
       while (( "$#" ))
       do
              case "$1" in
                     --no-changelog)
                            includeChangeLog="false"
                            shift
                     ;;
                     -p|--project-name)
                            if [ -n "$2" ] && [ ${2:0:1} != "-" ]
                            then
                                   projectName="${2}"
                                   shift 2
                            else
                                   echo "Error: Argument for $1 is missing" >&2
                                   exit 1
                            fi
                     ;;
                     -f|--format)
                            if [ -n "$2" ] && [ ${2:0:1} != "-" ]
                            then
                                   outputFormat="${2}"
                                   shift 2
                            else
                                   echo "Error: Argument for $1 is missing" >&2
                                   exit 1
                            fi
                     ;;
                     -t|--template-file)
                            if [ -n "$2" ] && [ ${2:0:1} != "-" ]
                            then
                                   templateFile="${2}"
                                   shift 2
                            else
                                   echo "Error: Argument for $1 is missing" >&2
                                   exit 1
                            fi
                     ;;
                     -o|--output-dir)
                            if [ -n "$2" ] && [ ${2:0:1} != "-" ]
                            then
                                   outputDir="${2}"
                                   shift 2
                            else
                                   echo "Error: Argument for $1 is missing" >&2
                                   exit 1
                            fi
                     ;;
                     -t|--template-file)
                            if [ -n "$2" ] && [ ${2:0:1} != "-" ]
                            then
                                   templateFile="${2}"
                                   shift 2
                            else
                                   echo "Error: Argument for $1 is missing" >&2
                                   exit 1
                            fi
                     ;;
                     *|-*|--*=) # Unsupported flags
                            echo "Error: Unsupported flag $1" >&2
                            usage
                            exit 1
                     ;;
              esac
       done

       # Set positional arguments in their proper place
       eval set -- "$PARAMS"
}

logger() {
       logLevel=${1}
       logMsg=${2}
       echo "[${logLevel}] ${logMsg}"

       if [[ ${logLevel} == "ERROR" ]]
       then
              exit 1
       fi
}

create_changelog(){
       changeLogFileName="${1}"
       echo "## Changelog (last 10 changes)" > ${changeLogFileName}
       echo "" >> ${changeLogFileName}
       echo "| CommitID | Author | Commit Msg |" >> ${changeLogFileName}
       echo "| --- | --- | --- |" >> ${changeLogFileName}
       git log -10 --pretty=format:'| %h | %an | %s |' >> ${changeLogFileName}
}

get_source_files(){
       sourceDir="${1}"
       declare -a arrMarkdownFiles
       for mdFile in ${sourceDir}*.md
       do
              arrMarkdownFiles=("${arrMarkdownFiles[@]}" "$mdFile")
       done

       echo "${arrMarkdownFiles[*]}"
}

parse_cli_args "$@"

case $outputFormat in
       "pdf")
              outputFormat="pdf"
              pdfOptions="-V colorlinks -V urlcolor=NavyBlue -V toccolor=NavyBlue -f markdown-raw_tex"
              
              logger "INFO" "Using PDF options ${pdfOptions}"
       ;;
       "docx" | *)
              outputFormat="docx"
              if [[ -n "${templateFile}" ]]
              then
                     useReferenceDocument="--reference-doc=${templateFile}"
                     logger "INFO" "Using reference document ${templateFile}"
              else
                     useReferenceDocument=""
                     logger "WARN" "Not using a reference document"
              fi

              
       ;;
esac

if [[ -n ${projectName} ]]
then
       logger "INFO" "Building ${projectName}.${outputFormat}..."
else
       usage
       logger "ERROR" "ProjectName is required"
fi

get_source_files "./"

if [[ ${includeChangeLog} == "false" ]]
then
       logger "WARN" "Changelog from commit messages is not generated..."
       logger "WARN" "  (but may be included if it is present)"
else
       create_changelog "9999-changes.md"
fi

if [[ -n ${outputDir} ]]
then
       logger "INFO" "Output ${outputDir}"
else
       logger "WARN" "Using local folder `PWD`"
       outputDir="./"
fi

pandoc --from markdown --to ${outputFormat} \
       --number-sections \
       --output ${outputDir}${projectName}.${outputFormat} \
       ${useReferenceDocument} \
       ${pdfOptions} \
       --table-of-contents \
       $(get_source_files)

if [[ $? == 0 ]]
then
       logger "INFO" "Generated file ${outputDir}${projectName}.${outputFormat}"
else
       logger "ERROR" "Error creating ${outputDir}${projectName}.${outputFormat}"
fi