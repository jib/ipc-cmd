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
ok($r->{'exit_code'} eq 0, "$true returns 0");
$r = run_forked($false);
ok($r->{'exit_code'} eq 1, "$false returns 1");

$r = run_forked([$echo, "test"]);
ok($r->{'stdout'} =~ /test/, "arrayref cmd: https://rt.cpan.org/Ticket/Display.html?id=70530");

$r = run_forked("$sleep 5", {'timeout' => 2});
ok($r->{'timeout'}, "[sleep 5] runs longer than 2 seconds");
