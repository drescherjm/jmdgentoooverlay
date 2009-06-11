#!/bin/sh
# mvcase --- rename files to all upper or lower case
# Author: Noah Friedman <friedman@prep.ai.mit.edu>
# Created: 1993-11-10
# Last modified: 1994-03-13
# Public domain

# Commentary:
# Code:

# Name by which this script was invoked.
progname=`echo "$0" | sed -e 's/[^\/]*\///g'`

# To prevent hairy quoting and escaping later.
bq='`'
eq="'"

usage="Usage: $progname {options}

Options are:
-D, --debug                  Turn on shell debugging ($bq${bq}set -x$eq$eq).
-h, --help                   You're looking at it.
-l, --lower-case             Rename upper-case files to lower case.
-m, --mv-options   MVOPTS    Options to ${bq}mv$eq program.
-R, --recur                  Rename all subdirectories and files
-u, --upper-case             Rename lower-case files to upper case.
"

# Usage: eval "$getopt"; value=$optarg
# or     optarg_optional=t; eval "$getopt"; value=$optarg
#
# This function automatically shifts the positional args as appropriate.
# The argument to an option is optional if the variable `optarg_optional'
# is non-empty.  Otherwise, the argument is required and getopt will cause
# the program to exit on an error.  optarg_optional is reset to be empty
# after every call to getopt.  The argument (if any) is stored in the
# variable `optarg'.
#
# Long option syntax is `--foo=bar' or `--foo bar'.  2nd argument
# won't get used if first long option syntax was used.
#
# Note: because of broken bourne shells, using --foo=bar syntax can
# actually screw the quoting of args that end with trailing newlines.
# Specifically, most shells strip trailing newlines from substituted
# output, regardless of quoting.
getopt='
  {
    optarg=
    case "$1" in
      --*=* )
        optarg=`echo "$1" | sed -e "1s/^[^=]*=//"`
        shift
       ;;
      * )
        case ${2+set} in
          set )
            optarg="$2"
            shift
            shift
           ;;
          * )
            case "$optarg_optional" in
              "" )
                case "$1" in
                  --*=* ) option=`echo "$1" | sed -e "1s/=.*//;q"` ;;
                  * ) option="$1" ;;
                esac
                exec 1>&2
                echo "$progname: option $bq$option$eq requires argument."
                echo "$progname: use $bq--help$eq to list option syntax."
                exit 1
               ;;
           esac
         ;;
        esac
     ;;
    esac
    optarg_optional=
  }'

# Initialize variables.
# Don't use `unset' since old bourne shells don't have this command.
# Instead, assign them an empty value.
debug=
case=lower
recur=

# Parse command line arguments.
# Make sure that all wildcarded options are long enough to be unambiguous.
# It's a good idea to document the full long option name in each case.
# Long options which take arguments will need a `*' appended to the
# canonical name to match the value appended after the `=' character.
while test $# != 0; do
  case "$1" in
    -D | --debug | --d* )
      debug=t
      shift
     ;;
    -h | --help | --h )
      echo "$usage" 1>&2
      exit 1
     ;;
    -l | --lower-case | --l* )
      case=lower
      shift
     ;;
    -u | --upper-case | --u* )
      case=upper
      shift
     ;;
    -m | --mv-options* | --m* )
      eval "$getopt"
      mv_switches="$optarg"
     ;;
    -R | --recur | --r* )
      recur=t
      shift
     ;;
    -- )     # Stop option processing
      shift
      break
     ;;
    -? | --* )
      case "$1" in
        --*=* ) arg=`echo "$1" | sed -e 's/=.*//'` ;;
        * )     arg="$1" ;;
      esac
      exec 1>&2
      echo "$progname: unknown or ambiguous option $bq$arg$eq"
      echo "$progname: Use $bq--help$eq for a list of options."
      exit 1
     ;;
    -??* )
      # Split grouped single options into separate args and try again
      optarg="$1"
      shift
      set fnord `echo "x$optarg" | sed -e 's/^x-//;s/\(.\)/-\1 /g'` ${1+"$@"}
      shift
     ;;
    * )
      break
     ;;
  esac
done

case "$debug" in t ) set -x ;; esac

case "$case" in
  lower ) conv='y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/' ;;
  upper ) conv='y/abcdefghijklmnopqrstuvwxyz/ABCDEFGHIJKLMNOPQRSTUVWXYZ/' ;;
esac

case "$recur" in
  t )
    find ${1+"$@"} -print | sort -r
   ;;
  * )
    for i in ${1+"$@"} ; do
      echo "$i"
    done
   ;;
esac \
 | while read file ; do
     dir=`echo "$file" \
          | sed -e 's/\/*$//
                    s/\/[^\/]*$//'`
     base=`echo "$file" \
           | sed -e 's/\/*$//
                     s/.*\///'`
     convbase=`echo "$base" | sed -e "$conv" | sed 's/ /_/g' | sed "s/'//g" | sed 's/_-_/_/g' | sed 's/(//g' | sed 's/)//g' | sed 's/-/_/g' | sed 's/,//g'`

     case "$base" in "$convbase" )
       echo "$progname: $file not renamed" 1>&2
       continue
      ;;
     esac

     case "$base" in "$file" )
       dir=. ;;
     esac

     ${MV-mv} $mv_switches "$file" "$dir/$convbase"
   done

# mvcase ends here


