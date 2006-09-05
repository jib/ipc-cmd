BEGIN { chdir 't' if -d 't' };
BEGIN { use lib '../lib' };

use strict;
use File::Spec;

### only run interactive tests when there's someone that can answer them
use Test::More -t STDOUT 
                    ? 'no_plan' 
                    : ( skip_all => "No interactive tests from harness" );

my $Class   = 'IPC::Cmd';
my $Child   = File::Spec->catfile( qw[src child.pl] );

### configurations to test IPC::Cmd with
my @Conf = (
    # ipc::run? ipc::open3?
    [ 1,        1 ],
    [ 0,        1 ],
    [ 0,        0 ],
);

use_ok( $Class, 'run' );

for my $aref ( @Conf ) {

    ### stupid warnings
    local $IPC::Cmd::USE_IPC_RUN    = $aref->[0];
    local $IPC::Cmd::USE_IPC_RUN    = $aref->[0];

    local $IPC::Cmd::USE_IPC_OPEN3  = $aref->[1];
    local $IPC::Cmd::USE_IPC_OPEN3  = $aref->[1];

    
    diag("Config: IPC::Run = $aref->[0] IPC::Open3 = $aref->[1]");
    diag("Please enter some input. It will be echo'd back to you");
    run( command => qq[$^X $Child], verbose => 1 );

}
