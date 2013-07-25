devtools
========

A few tools for repo and project management

svnsync
-------

Sync a git repo with an svn repo (mirroring commits and users correctly)

Usage:

    ./svnsync.pl --git=my-git-repo --svn=my-svn-repo

parselog
--------

Read an SVN log and output a nice LaTeX table

Usage:

    svn log | ./parselog.pl > log.tex
