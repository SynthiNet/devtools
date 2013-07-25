#!/usr/bin/env perl
use 5.17.0;
use utf8;
use strict;
use warnings;
use diagnostics;
use Getopt::Long;

my $svn_repo = "PSOPV";
my $git_repo = "PSOPV-GIT";
my $pwd = `pwd`;
chomp $pwd;

GetOptions(
    'svn=s' => \$svn_repo,
    'git=s' => \$git_repo,
) or die "WE REQUIRE MORE OPTIONS";

chdir "$pwd/$svn_repo";
print "Updating SVN repo...\n";
do_command("svn up");
print "\n";

my $svn_gitcommit;
open my $svn_gitcommit_file, '<', "$pwd/$svn_repo/.gitcommit";
while (<$svn_gitcommit_file>) {
    chomp $_;
    $svn_gitcommit = $_;
}

my @git_log = `cd $pwd/$git_repo; git log --pretty=format:"%H\t%s\t%an" --reverse $svn_gitcommit..HEAD`;
for (@git_log) {
    chomp $_;
    my @fields = split /\t/, $_;

    my $user;
    if ($fields[2] eq "Randy Thiemann") {
        $user = "randy.thiemann";
    } elsif ($fields[2] eq "Frank Erens") {
        $user = "frank.erens";
    } else {
        print "Unknown user, aborting";
        die "FAIL";
    }
    
    my @git_diff = `cd $pwd/$git_repo; git diff "$fields[0]^" $fields[0] --name-status`;
    print "Playing back commit $fields[0] as $user\n";
    chdir "$pwd/$git_repo";
    do_command("git checkout -q \"$fields[0]\"");
    chdir "$pwd/$svn_repo";

    for (@git_diff) {
        my @files = split /\t/, $_;
        chomp $files[1];

        #check for type of modification
        if($files[0] eq "D") {
            do_command("svn rm \"$files[1]@\" --force");
        } else {
            my @dirs = split /\//, $files[1];
            if(scalar(@dirs) == 1) {
                do_command("cp \"$pwd/$git_repo/$files[1]\" \"$pwd/$svn_repo/$files[1]\"");
            } else {
                $files[1] =~ /^(.*)\/.*$/;
                unless (-d "$pwd/$svn_repo/$1") {
                    do_command("mkdir -p \"$pwd/$svn_repo/$1\"");
                }
                do_command("cp \"$pwd/$git_repo/$files[1]\" \"$pwd/$svn_repo/$files[1]\"");
            }
        }
    }

    do_command("echo \"$fields[0]\" > \"$pwd/$svn_repo/.gitcommit\"");

    my $count = 1;
    while ($count != 0) {
        my @svn_status = `svn status`;
        $count = 0;
        for (@svn_status) {
            $_ =~ /^(.)\s+(.*)$/;
            if ($1 eq "I" ||
                $1 eq "?") {
                do_command("svn add \"$2@\"");
                $count++;
            }
        }
    }

    $fields[1] =~ s/\"/\\\"/g;
    do_command("svn ci --force-log -m \"$fields[1]\" --username \"$user\"");
    do_command("svn up");
    chdir "$pwd/$git_repo";
    do_command("git checkout \"master\"");
    print "\n";
}

sub do_command {
    my ($command) = @_;
    print "+ $command\n";
    system($command); #and die "SVN SHAT ITSELF";
}
