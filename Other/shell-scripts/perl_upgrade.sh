#!/bin/bash 

# unmerge perl virtuals 
emerge --unmerge $(qlist --installed virtual/perl) 

# print perl blockers and quit 
if emerge -pq dev-lang/perl:0 2>/dev/null | grep blocks 
then 
        echo 
        echo "unmerge packages blocking perl upgrade" 

        exit 1 
else 
        # upgrade perl 
        perl-cleaner --reallyall -- dev-lang/perl:0 
fi 

exit 0
