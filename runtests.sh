#!/bin/bash


# Usage: runtests.sh [names of testcases]
# The name of the testcase is the name of the directory
# If no testcases are given all are run

sugarj="$HOME/scratch/sugjbin/sugarj"
experimentsdir="$HOME/work/soundx/soundx-experiments"

function info_message {
    echo -e "\033[34mINFO:\033[0m $1"
    echo "INFO: $1" >> "$outputdir/log"
}

function abort {
    echo -e "\033[97;41mABORT:\033[0m $1" > /dev/stderr
    echo "ABORT: $1" >> "$outputdir/log"
    exit 1
}

function log_message {
    echo -n "$1"
    echo -n "$1" >> "$outputdir/log"
}

function log_message_ln {
    echo "$1"
    echo "$1" >> "$outputdir/log"
}

function log_success {
    echo -e '[ \033[32mSUCCESS\033[0m ]'
    echo "[ SUCCESS ]" >> "$outputdir/log"
}

function log_failed {
    echo -e '[ \033[31mFAILED\033[0m  ]'
    echo "[ FAILED  ]" >> "$outputdir/log"
}

function check_files {
    difference="no"
    differingFiles=""
    for file in `ls $1/expected/* 2> /dev/null`; do
        filename=`basename $file`
        if diff "$1/bin/$filename" "$1/expected/$filename" >& "$1/$filename.diff"; then
            :
        else
            difference="yes"
            differingFiles="$differingFiles $filename"
        fi
    done
    if [ $difference = "no" ]; then
        log_success
        inc_success_testcases
    else
        log_failed
        inc_failed_testcases
        log_message_ln "    difference in$differingFiles"
    fi
        
    # if diff "$1/bin/$2.sdf" "$1/expected/$2.sdf" >& "$1/sdf.diff"; then
    #     # no difference in SDF
    #     if diff "$1/bin/$2.str" "$1/expected/$2.str" >& "$1/str.diff"; then
    #         # no difference in STR
    #         log_success
    #         inc_success_testcases
    #     else
    #         # difference in STR
    #         log_failed
    #         inc_failed_testcases
    #         log_message_ln "    Stratego files differ"
    #     fi
    # else
    #     # difference in SDF
    #     log_failed
    #     inc_failed_testcases
    #     log_message_ln "    SDF2 files differ"

    #     if diff "$1/bin/$2.str" "$1/expected/$2.str" >& "$1/str.diff"; then
    #         # no difference in STR
    #         :
    #     else
    #         # difference in STR
    #         log_message_ln "    Stratego files differ"
    #     fi
    # fi
}

# function check_error_messages {
#     grep -A 1 "^error:" "$1/sugarj.log" > "$1/error-messages.txt"
#     if diff "$1/error-messages.txt" "$1/expected/error-messages.txt" >& "$1/messages.diff"; then
#         # no difference
#         log_success
#         inc_success_testcases
#     else
#         # some difference
#         log_failed
#         inc_failed_testcases
#         log_message_ln "    error messages differ"
#         log_message_ln "    expected:"
#         while read line; do
#             log_message_ln "        $line"
#         done < "$1/expected/error-messages.txt"
#         log_message_ln "    received:"
#                 while read line; do
#             log_message_ln "        $line"
#         done < "$1/error-messages.txt"
#     fi
# }

# 1st arg: testcase dir
# 2nd arg: input file name
function run_sugarj {
    rm -rf $cachedir/*
    $sugarj -d "$1/bin" \
            --cache "$cachedir" \
            --gen-files \
            -l $language \
            --sourcepath "$experimentsdir/$srcdir/src" \
            "$2" >& "$1/sugarj.log"
}

function inc_failed_testcases {
    testcases_total=$((testcases_total + 1))
    testcases_failure=$((testcases_failure + 1))
}

function inc_success_testcases {
    testcases_total=$((testcases_total + 1))
    testcases_success=$((testcases_success + 1))
}

# Set per testcase variables to empty string
function reset_testcase_description {
    language=""
    extendedExt=""
    baseExt=""
    input=""
    exitcode=""
    success=""
    srcdir=""
}

# Check testcase description
function check_testcase_description {
    if [ "$language" = "" ]; then
        abort "$testcasedir: language must be set in description"
    fi
    if [ "$extendedExt" = "" ]; then
        abort "$testcasedir: extendedExt must be set in description"
    fi
    if [ "$baseExt" = "" ]; then
        abort "$testcasedir: baseExt must be set in description"
    fi
    if [ "$exitcode" = "" ]; then
        abort "$testcasedir: exitcode must be set in description"
    fi
    if [ "$success" != "yes" ]; then
        abort "$testcasedir: success must be yes in description (no not yet implemented)"
    fi
    if [ "$srcdir" = "" ]; then
        abort "$testcasedir: srcdir must be set"
    fi
    if [ ! -d $experimentsdir/$srcdir/src ]; then
        abort "$testcasedir: the srcdir $srcdir/src does not exist"
    fi
    if [ "$input" = "" ]; then
        abort "$testcasedir: input must be set in description"
    fi
    if [ ! -f $experimentsdir/$srcdir/src/$input ]; then
        abort "$testcasedir: the input file $input does not exist"
    fi
}

function maketempdir {
    time=`date "+%Y-%m-%d-%H-%M-%S"`
    if which gmktemp; then
        outputdir="`gmktemp -d --tmpdir sx-testsuite-$time.XXXXXXX`"
    else
        outputdir="`mktemp -d --tmpdir sx-testsuite-$time.XXXXXXX`"
    fi
}

testcases_total=0
testcases_failure=0
testcases_success=0

case $0 in
    /*) testsuitedir=`dirname $0`
        ;;
    *) testsuitedir="`pwd`/${0%/*}"
        ;;
esac

maketempdir
info_message "Output directory $outputdir"
info_message "Testsuite dir $testsuitedir"

cachedir="$outputdir/sugarjcache"

info_message "Copy testcases to output directory"
cp -r "$testsuitedir/testcases"/* "$outputdir"

cd "$outputdir"

if [ $# -ne 0 ]; then
    testcases="$@"
else
    testcases=`ls -d [0-9][0-9][0-9][0-9]_*`
fi

for testcasedir in $testcases; do
    reset_testcase_description

    if [ ! -d "$testcasedir" ]; then
        abort "$testcasedir: not found (name misspelled?)"
    fi

    # Load test description
    if [ ! -f $testcasedir/description ]; then
        abort "$testcasedir: there must be a description file"
    fi
    . $testcasedir/description
    check_testcase_description
    
    # Find input file
    inputfile=$input
    inputfilemodule=`basename "$inputfile" .$extendedExt`

    # Find expected exit code
    expected_exitcode=$exitcode

    # Find expected outcome
    if [ "$success" = "no" ]; then
        outcome="fail"
    else
        outcome="success"
    fi

    # Start logging
    namelen=`echo -n $testcasedir | wc -c`
    if [ $namelen -gt 40 ]; then
        padded="${testcasedir:0:37}..."
    else
        padlen=$((40-namelen))
        # from http://stackoverflow.com/questions/5349718/how-can-i-repeat-a-character-in-bash
        padding=`head -c $padlen < /dev/zero | tr '\0' ' '`
        padded="$testcasedir$padding"
    fi
    log_message "TEST CASE: $padded "
    
    run_sugarj "$testcasedir" "$inputfile"
    exitcode=$?

    if [ $exitcode -ne $expected_exitcode ]; then
        log_failed
        log_message_ln "    exit code failure"
        log_message_ln "    expected: $expected_exitcode"
        log_message_ln "    received: $exitcode"
        inc_failed_testcases
        continue
    fi

    if [ "$outcome" = "success" ]; then
        check_files "$testcasedir" "$inputfilemodule"
    # elif [ "$outcome" = "fail" ]; then
    #     check_error_messages "$testcasedir"
    fi
done

info_message "Summary:"
info_message "    testcases total:     $testcases_total"
info_message "    testcases failed:    $testcases_failure"
info_message "    testcases succeeded: $testcases_success"

if [ $testcases_failure -gt 0 ]; then
    info_message "Keep temporary directory for inspection of failure"
    info_message "  $outputdir"
    exit 2
else
    #info_message "Deleting temporary directory"
    #rm -rf $outputdir
    exit 0
fi
