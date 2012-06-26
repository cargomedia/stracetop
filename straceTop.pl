#!/usr/bin/perl
#
# A tool to aggregate strace output in real time
#
# Usage:
# straceTop.pl [argument portions]
#
# Argument portions: e.g. "-p <PID>"  or "<program name>"
# i.e. straceTop.pl "-p 432993"  or straceTop.pl "cp -u /foo /bar"
#
#
#

use strict;
use POSIX;
$| = 1;

my %calls;
my %callsDuration;

my $cmd = $ARGV[0];
open(PS,"/usr/bin/strace -t -T -q -f $cmd 2>&1|") || exit "Failed: $!\n";
open(LOG, ">>", "log.txt") || exit "Cannot open log: $!\n";
my $line = '';
my $start = time;
my $i = 0;
while (<PS>) {
        chomp;
        $line .= $_;
        $i++;
        if ($i > 20) {
                exit "More than 20 loops without matching\n";
        }
        if ($line =~ /^.+?([\d:]+) (\w+)\((.+?)\)\s+=\s+.+? <([\d.]+)>$/) {
                print LOG $line . "\n";
                $i = 0;
                $line = '';
                my $time = $1;
                my $call = $2;
                my $args = $3;
                my $duration = $4;
                $calls{$call}++;
                $callsDuration{$call} += $duration;
        }
        if (time > $start + 1) {
                $start = time;
                my $call;
                my $count;
                print "--- " . POSIX::strftime("%H:%M:%S", localtime) . " ";
                print ("-"x30);
                print "\n";
                while (($call, $count) = each(%calls)){
                        my $duration = $callsDuration{$call};
                        print $call . (" "x(20-length($call)));
                        print $count . (" "x(10-length($count)));
                        print sprintf("%.2f", $duration). "\n";
                }
                %calls = %callsDuration = ();
        }
}
# ---------------------------------------
   my $call;
                my $count;
                print "--- " . POSIX::strftime("%H:%M:%S", localtime) . " ";
                print ("-"x30);
                print "\n";
                while (($call, $count) = each(%calls)){
                        my $duration = $callsDuration{$call};
                        print $call . (" "x(20-length($call)));
                        print $count . (" "x(10-length($count)));
                        print sprintf("%.2f", $duration). "\n";
                }
# -------------------------------------------
close(LOG);
print "done.\n";


