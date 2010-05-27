#!\bin\sh

loop_over_overlays() 
{
	local rep
	rep="`portageq portdir_overlay`"
	for i in ${rep}
	do	
		test -r "${i}/profiles/repo_name" && \
		repo_name=`cat -- "${i}"/profiles/repo_name` || \
		repo_name=''
		echo ${repo_name}
		egencache --update --repo=${repo_name}
	done
}

loop_over_overlays
