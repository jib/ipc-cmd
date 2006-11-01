use ExtUtils::MakeMaker;
use strict;

for ( qw[IPC::Run IPC::Open3] ) {
    eval "use $_";
    if( $@ ) {
        warn qq[You do not have "$_" installed - please consider installing it\n].
             qq[It's not required, but trust me, you'll thank me later ;)\n];   
    }
}    

WriteMakefile (
    NAME            => 'IPC::Cmd',
    VERSION_FROM    => 'lib/IPC/Cmd.pm', # finds $VERSION
    dist            => { COMPRESS => 'gzip -9f', SUFFIX => 'gz' },
    PREREQ_PM       => {    'Test::More'                => 0, 
                            'Params::Check'             => 0,
                            'Module::Load::Conditional' => 0,
                            'Locale::Maketext::Simple'  => 0,
                    },
    AUTHOR          => 'Jos Boumans <kane[at]cpan.org>',
	ABSTRACT        => 'A cross platform way of running (interactive) commandline programs.'
); 
