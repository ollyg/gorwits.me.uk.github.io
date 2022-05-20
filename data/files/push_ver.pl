#!/usr/bin/env perl

# use:
# find lib | grep \.pm | ~/bin/push_ver.pl 4.300000

use strict;
use warnings;

my $newv = $ARGV[0];
die unless $newv;

FILE: while (my $fname = <STDIN>) {
  chomp $fname;
  open (my $ifile, '<', $fname) or die $!;
  open (my $ofile, '>', "$fname.bak") or die $!;

  my $pkg = $fname;
  $pkg =~ s!^lib/!!;
  $pkg =~ s!\.pm$!!;
  $pkg =~ s!/!::!g;

  my $vstring = "{ \$${pkg}::VERSION = '$newv' }\n";

  LINE: while (my $line = <$ifile>) {
    if ($line =~ m/package $pkg;/) {
      print $ofile $line;
      print $ofile $vstring;

      my $next = <$ifile>;
      if ($next !~ m/VERSION = '[\d._]+' \}/) {
        print $ofile $next;
      }

      next LINE;
    }

    print $ofile $line;
  }

  close $ifile or die $!;
  close $ofile or die $!;
  unlink $fname or die $!;
  rename "$fname.bak", $fname or die $!;
}
