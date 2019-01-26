# HDL Autograder for nand2tetris

## Usage
`bin/hdl_autograder --help`

## Grading steps
1. Run autograder

    ```
    bin/hdl_autograder -p $PROJECT_NUMBER -a $CLASS_SUBMISSIONS_ARCHIVE
    ```

1. Find submissions needing manual review

    ```
    grep -ri --include "*feedback.txt" "review_needed" $GRADED_OUTPUT_DIRECTORY
    ```

1. Make any manual adjustments
1. Generate histogram

    ```
    bin/histogram -d $GRADED_OUTPUT_DIRECTORY
    ```

1. Zip up files and histogram

    ```
    find $GRADED_OUTPUT_DIRECTORY -iname "*feedback.txt" | xargs zip -Xj $OUTPUT_ZIP_FILE $HISTOGRAM_FILE
    ```
