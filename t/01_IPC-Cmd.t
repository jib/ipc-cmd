## IPC::Cmd test suite ###

BEGIN { chdir 't' if -d 't' };

use strict;
use lib qw[../lib];
use File::Spec;
use Test::More 'no_plan';

my $Class       = 'IPC::Cmd';
my $AClass      = $Class . '::TimeOut';
my @Funcs       = qw[run can_run];
my @Meths       = qw[can_use_ipc_run can_use_ipc_open3 can_capture_buffer];
my $IsWin32     = $^O eq 'MSWin32';
my $Verbose     = @ARGV ? 1 : 0;

use_ok( $Class,         $_ ) for @Funcs;
can_ok( $Class,         $_ ) for @Funcs, @Meths;
can_ok( __PACKAGE__,    $_ ) for @Funcs;

my $Have_IPC_Run    = $Class->can_use_ipc_run;
my $Have_IPC_Open3  = $Class->can_use_ipc_open3;

diag("Have IPC::Run? $Have_IPC_Run")     if $Verbose;
diag("Have IPC::Open3? $Have_IPC_Open3") if $Verbose;

local $IPC::Cmd::VERBOSE = $Verbose;
local $IPC::Cmd::VERBOSE = $Verbose;
local $IPC::Cmd::DEBUG   = $Verbose;
local $IPC::Cmd::DEBUG   = $Verbose;


### run tests in various configurations, based on what modules we have
my @Prefs = ( 
    [ $Have_IPC_Run, $Have_IPC_Open3 ], 
    [ 0,             $Have_IPC_Open3 ],     # run this config twice to ensure
    [ 0,             $Have_IPC_Open3 ],     # FD restores work properly
    [ 0,             0 ], 
    [ 0,             0 ],     
);


### can_run tests
{
    ok( can_run('perl'),                q[Found 'perl' in your path] );
    ok( !can_run('10283lkjfdalskfjaf'), q[Not found non-existant binary] );
}

{   ### list of commands and regexes matching output ###
    my $map = [
        # command                                    # output regex     # buffer

        ### run tests that print only to stdout
        [ "$^X -v",                                  qr/larry\s+wall/i, 3, ],
        [ [$^X, '-v'],                               qr/larry\s+wall/i, 3, ],

        ### pipes
        [ "$^X -eprint+424 | $^X -neprint+split+2",  qr/44/,            3, ],
        [ [$^X,qw[-eprint+424 |], $^X, qw|-neprint+split+2|], 
                                                     qr/44/,            3, ],
        ### whitespace
        [ [$^X, '-eprint+shift', q|a b a|],          qr/a b a/,         3, ],
        [ "$^X -eprint+shift 'a b a'",               qr/a b a/,         3, ],

        ### whitespace + pipe
        [ [$^X, '-eprint+shift', q|a b a|, q[|], $^X, qw[-neprint+split+b] ],
                                                     qr/a  a/,          3, ],
        [ "$^X -eprint+shift 'a b a' | $^X -neprint+split+b",
                                                     qr/a  a/,          3, ],

        ### run tests that print only to stderr
        [ "$^X -ewarn+42",                           qr/^42 /,          4, ],
        [ [$^X, '-ewarn+42'],                        qr/^42 /,          4, ],
    ];

    ### extended test
    ### test if gzip | tar works
    {   my $gzip = can_run('gzip');
        my $tar  = can_run('tar');
        
        if( $gzip and $tar ) {
            push @$map,
                [ [$gzip, qw[-cdf src/x.tgz |], $tar, qw[-tf -]],     
                                                       qr/a/,             3, ];
        }
    }        

    ### for each configuarion
    for my $pref ( @Prefs ) {
        diag( "Running config: IPC::Run: $pref->[0] IPC::Open3: $pref->[1]" )
            if $Verbose;

        local $IPC::Cmd::USE_IPC_RUN    = $pref->[0];
        local $IPC::Cmd::USE_IPC_RUN    = $pref->[0];
        local $IPC::Cmd::USE_IPC_OPEN3  = $pref->[1];
        local $IPC::Cmd::USE_IPC_OPEN3  = $pref->[1];

        ### for each command
        for my $aref ( @$map ) {
            my $cmd    = $aref->[0];
            my $regex  = $aref->[1];
            my $index  = $aref->[2];

            my $pp_cmd = ref $cmd ? "@$cmd" : "$cmd";
            diag( "Running '$pp_cmd' as " . (ref $cmd ? "ARRAY" : "SCALAR") ) 
                if $Verbose;

            ### in scalar mode
            {   diag( "Running scalar mode" ) if $Verbose;
                my $buffer;
                my $ok = run( command => $cmd, buffer => \$buffer );

                ok( $ok,        "Ran '$pp_cmd' command succesfully" );
                
                SKIP: {
                    skip "No buffers available", 1 
                                unless $Class->can_capture_buffer;
                    
                    like( $buffer, $regex,  
                                "   Buffer matches $regex" );
                }
            }
                
            ### in list mode                
            {   diag( "Running list mode" ) if $Verbose;
                my @list = run( command => $cmd );

                ok( $list[0],   "Command ran successfully" );
                ok( !$list[1],  "   No error code set" );

                my $list_length = $Class->can_capture_buffer ? 5 : 2;
                is( scalar(@list), $list_length,
                                "   Output list has $list_length entries" );

                SKIP: {
                    skip "No buffers available", 6 
                                unless $Class->can_capture_buffer;
                    
                    ### the last 3 entries from the RV, are they array refs?
                    isa_ok( $list[$_], 'ARRAY' ) for 2..4;

                    like( "@{$list[2]}", $regex,
                                "   Combined matches $regex" );

                    like( "@{$list[$index]}", qr/$regex/,
                            "   Proper buffer($index) matches $regex" );
                    is( scalar( @{$list[ $index==3 ? 4 : 3 ]} ), 0,
                                    "   Other buffer empty" );
                }
            }
        }
    }
}
__END__
### special call to check that output is interleaved properly
{   my $cmd     = [$^X, File::Spec->catfile( qw[src output.pl] ) ];

    ### for each configuarion
    for my $pref ( @Prefs ) {
        diag( "Running config: IPC::Run: $pref->[0] IPC::Open3: $pref->[1]" )
            if $Verbose;

        local $IPC::Cmd::USE_IPC_RUN    = $pref->[0];
        local $IPC::Cmd::USE_IPC_OPEN3  = $pref->[1];

        my @list    = run( command => $cmd, buffer => \my $buffer );
        ok( $list[0],                   "Ran @{$cmd} successfully" );
        ok( !$list[1],                  "   No errorcode set" );
        SKIP: {
            skip "No buffers available", 3 unless $Class->can_capture_buffer;

            TODO: {
                local $TODO = qq[Can't interleave input/output buffers yet];

                is( "@{$list[2]}",'1 2 3 4',"   Combined output as expected" );
                is( "@{$list[3]}", '1 3',   "   STDOUT as expected" );
                is( "@{$list[4]}", '2 4',   "   STDERR as expected" );
            
            }
        }
    }        
}



### test failures
{   ### for each configuarion
    for my $pref ( @Prefs ) {
        diag( "Running config: IPC::Run: $pref->[0] IPC::Open3: $pref->[1]" )
            if $Verbose;

        local $IPC::Cmd::USE_IPC_RUN    = $pref->[0];
        local $IPC::Cmd::USE_IPC_OPEN3  = $pref->[1];

        my ($ok,$err) = run( command => "$^X -edie" );
        ok( !$ok,               "Non-zero exit caught" );
        ok( $err,               "   Error '$err'" );
    }
}   

### timeout tests
{   my $timeout = 1;
    for my $pref ( @Prefs ) {
        diag( "Running config: IPC::Run: $pref->[0] IPC::Open3: $pref->[1]" )
            if $Verbose;

        local $IPC::Cmd::USE_IPC_RUN    = $pref->[0];
        local $IPC::Cmd::USE_IPC_OPEN3  = $pref->[1];

        ### -X to quiet the 'sleep without parens is ambiguous' warning
        my ($ok,$err) = run( command => "$^X -Xesleep+4", timeout => $timeout );
        ok( !$ok,               "Timeout caught" );
        ok( $err,               "   Error stored" );
        ok( not(ref($err)),     "   Error string is not a reference" );
        like( $err,qr/^$AClass/,"   Error '$err' mentions $AClass" );
    }
}    
    


