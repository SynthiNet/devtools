#!/usr/bin/env perl
use v5.17.0;
use strict;
use warnings;
use diagnostics;

my @entries;
my $entry = "";

for(<STDIN>) {
    if($_ =~ /^-+$/) {
        push @entries, $entry;
        $entry = "";
    } else {
        $entry .= $_;
    }
}

print <<END;
\\begin{longtabu}{X[1]X[2]X[2]}
  \\cellcolor{black}\\textcolor{white}{\\textbf{Revisie}} & \\cellcolor{black}\\textcolor{white}{\\textbf{Committer}} & \\cellcolor{black}\\textcolor{white}{\\textbf{Datum en Tijd}} \\\\ \\hline
END

my $count = 0;
@entries = reverse @entries;
for(@entries) {
    if($_ ne "") {
        ++$count;
        my @inp = split /\n/, $_;
        $inp[0] =~ /^r(\d+)\s*\|\s*([a-z]+\.[a-z]+)\s*\|\s*(\d{4}-\d{2}-\d{2}) (\d{2}:\d{2}:\d{2})/;
        chomp $inp[2];
        my $message = $inp[2];
        my $revision = $1;
        my $name = join " ", map {ucfirst} split /\./, $2;
        my $date = $3;
        my $time = $4;
        $message =~ s/\&/\\\&/g;
        $message =~ s/_/\\_/g;

        if($count % 2 == 0) {
            say "  \\rowcolor{black!10}";
        }
        say "    $revision \& $name \& $date $time \\\\";
        if($count % 2 == 0) {
            say "  \\multicolumn{3}{l}{\\cellcolor{black!10} $message}\\\\";
        } else {
            say "  \\multicolumn{3}{l}{$message}\\\\";            
        }
    }
}

print <<END;
  \\hline
\\end{longtabu}
END

