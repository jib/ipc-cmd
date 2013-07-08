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

my $r;

$r = run_forked("/bin/true");
ok($r->{'exit_code'} eq 0, "/bin/true returns 0");
$r = run_forked("/bin/false");
ok($r->{'exit_code'} eq 1, "/bin/false returns 1");

$r = run_forked(["echo", "test"]);
ok($r->{'stdout'} =~ /test/, "arrayref cmd: https://rt.cpan.org/Ticket/Display.html?id=70530");

$r = run_forked("sleep 5", {'timeout' => 2});
ok($r->{'timeout'}, "[sleep 5] runs longer than 2 seconds");
