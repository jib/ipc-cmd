#!/usr/bin/perl

BEGIN { chdir 't' if -d 't' };

use strict;
use warnings;
use lib qw[../lib];
use Test::More 'no_plan';
use Data::Dumper;

use_ok("IPC::Cmd", "run_forked");

unless ( IPC::Cmd->can_use_run_forked ) {
  ok(1, "run_forked not available on this platform");
  exit;
}
else {
  ok(1, "run_forked available on this platform");
}

my $true = IPC::Cmd::can_run('true');
my $false = IPC::Cmd::can_run('false');
my $echo = IPC::Cmd::can_run('echo');
my $sleep = IPC::Cmd::can_run('sleep');

unless ( $true and $false and $echo and $sleep ) {
  ok(1, 'Either "true" or "false" "echo" or "sleep" is missing on this platform');
  exit;
}

my $r;

$r = run_forked($true);
ok($r->{'exit_code'} eq '0', "$true returns 0");
$r = run_forked($false);
ok($r->{'exit_code'} ne '0', "$false returns not 0");

$r = run_forked([$echo, "test"]);
ok($r->{'stdout'} =~ /test/, "arrayref cmd: https://rt.cpan.org/Ticket/Display.html?id=70530");

$r = run_forked("$sleep 5", {'timeout' => 2});
ok($r->{'timeout'}, "[$sleep 5] runs longer than 2 seconds");


# https://rt.cpan.org/Ticket/Display.html?id=85912
sub runSub {
       my $blah = "blahblah";
       my $out= $_[0];
       my $err= $_[1];

       my $s = sub {
          print "$blah\n";
          print "$$: Hello $out\n";
          warn "Boo!\n$err\n";
       };

       return run_forked($s);
}

my $retval= runSub("sailor", "eek!");
ok($retval->{"stdout"} =~ /blahblah/, "https://rt.cpan.org/Ticket/Display.html?id=85912 stdout 1");
ok($retval->{"stdout"} =~ /Hello sailor/, "https://rt.cpan.org/Ticket/Display.html?id=85912 stdout 2");
ok($retval->{"stderr"} =~ /Boo/, "https://rt.cpan.org/Ticket/Display.html?id=85912 stderr 1");
ok($retval->{"stderr"} =~ /eek/, "https://rt.cpan.org/Ticket/Display.html?id=85912 stderr 2");

$r = run_forked("$echo yes i know this is the way", {'discard_output' => 1});
ok($r->{'stdout'} eq '', "discard_output stdout");
ok($r->{'stderr'} eq '', "discard_output stderr");
ok($r->{'merged'} eq '', "discard_output merged");
ok($r->{'err_msg'} eq '', "discard_output err_msg");
