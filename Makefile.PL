use ExtUtils::MakeMaker;
use strict;
use Getopt::Std;

my $opts = {};
getopts( 'b', $opts );

### promote IPC::Run on windows
if ( $^O eq 'MSWin32' and !(eval{require IPC::Run}) and !$opts->{'b'} ) {
    warn "IPC::Run is an optional requirement for Win32 systems to ".
         "capture buffers.\n" .
         "If you would like to install IPC::Cmd with buffer support ".
         "on Win32, please rerun this Makefile.PL with the '-b' option\n";
}    

my $prereqs = {
    'Test::More'                => 0, 
    'Params::Check'             => '0.20',
    'Module::Load::Conditional' => 0,
    'Locale::Maketext::Simple'  => 0,
    'IPC::Run'                  => '0.55',
};
delete $prereqs->{'IPC::Run'} unless $opts->{'b'};

WriteMakefile (
    NAME            => 'IPC::Cmd',
    VERSION_FROM    => 'lib/IPC/Cmd.pm', # finds $VERSION
    dist            => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    PREREQ_PM       => $prereqs,
    AUTHOR          => 'Jos Boumans <kane[at]cpan.org>',
	ABSTRACT        => 'A cross platform way of running (interactive) commandline programs.'
); 
