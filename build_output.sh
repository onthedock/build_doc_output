#!/usr/bin/env bash

projectName="${1}"
outputFormat="${2}"
templateFile="${3}"

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

case $outputFormat in
       "pdf")
       outputFormat="pdf"
       pdfOptions="-V colorlinks -V urlcolor=NavyBlue -V toccolor=NavyBlue -f markdown-raw_tex"
       ;;
       "docx" | *)
       outputFormat="docx"
              if [[ -n "${templateFile}" ]]
              then
                     useReferenceDocument="--reference-doc=\"${templateFile}\""
              else
                     useReferenceDocument=""
              fi
       ;;
esac

if [[ -n ${projectName} ]]
then
       logger "INFO" "Building ${projectName}.${outputFormat}..."
else
       logger "ERROR" "ProjectName is required as first parameter to the script or as the env variable \$projectName"
fi



get_source_files "./"
create_changelog "9999-changes.md"

pandoc --from markdown --to ${outputFormat} \
       --number-sections \
       --output $HOME/shared/${projectName}.${outputFormat} \
       ${useReferenceDocument} \
       ${pdfOptions} \
       --table-of-contents \
       $(get_source_files)