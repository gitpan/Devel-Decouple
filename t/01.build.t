use Test::More;
use Test::Differences;
use Test::Deep;

use Devel::Decouple;
use lib 't';
use TestMod::Baz;

my $class  = 'Devel::Decouple';
my $module = 'TestMod::Baz';
my @modules = qw{
        TestMod::Foo
        TestMod::Bar
};
my @functions = qw{
        prohibit
        inhibit
};
my @methods = qw{
        new
        decouple
        from
        function
        functions
        as
        default_sub
        preserved
        module
        modules
        called_imports
};


BASIC: {
    my $DD = Devel::Decouple->new();
    
    isa_ok( $DD,    $class );
    can_ok( $class, @methods );
}

BASIC_BUILD: {
    my $DD = Devel::Decouple->new->decouple( $module );
    
    #         GOT                     EXPECTED                    MESSAGE
    is(       $DD->module,            $module,                   "returned the correct module name"     );
    cmp_bag( [$DD->called_imports],  [qw{ prohibit inhibit }],   "returned the correct import names"    );
    cmp_bag( [$DD->modules],         [qw{ TestMod::Foo
                                          TestMod::Bar     }],   "returned the correct module names"    );
    cmp_bag( [$DD->all_functions],   [qw{ prohibit inhibit
                                          adhibit  exhibit }],   "returned the correct function names"  );
}

SUGAR_SYNTAX: {
    my $expected = {
        'TestMod::Baz'  =>  [qw{ TestMod::Foo TestMod::Bar }],
        prohibit        =>  sub { return 1 },
        inhibit         =>  sub { return 1 },
        _DEFAULT_       =>  '_PRESERVED_',
    };
    
    my $got1 = {
        $module,             from @modules,
        function 'prohibit', as { return 1 },
        function 'inhibit',  as { return 1 },
        default_sub,         preserved,
    };
    
    my $got2 = {
        $module,             from @modules,
        default_sub,         preserved,
        function 'prohibit', as { return 1 },
        function 'inhibit',  as { return 1 },
    };
    
    my $got3 = {
        $module,              from @modules,
        default_sub,          preserved,
        functions @functions, as { return 1 },
    };
    
    my $got4 = {
        $module,              from @modules,
        functions @functions, as { return 1 },
        default_sub,          preserved,
    };
    
    #           GOT         EXPECTED        MESSAGE
    eq_or_diff( $got1,      $expected,      "sugar syntax using 'default_sub' last"  );
    eq_or_diff( $got2,      $expected,      "sugar syntax using 'default_sub' first" );
    eq_or_diff( $got3,      $expected,      "sugar syntax using 'functions' last"    );
    eq_or_diff( $got4,      $expected,      "sugar syntax using 'functions' first"   );
}

CUSTOM_BUILD: {
    my $DD = Devel::Decouple->new;
    $DD->decouple(  $module,             from @modules,                # 'from' must take a literal array 
                    function 'prohibit', as { return 1 },
                    function 'inhibit',  as { return 1 },
                    );
    
    my $DD2 = Devel::Decouple->new;
    $DD2->decouple( $module,
                    function 'inhibit',  as { return 1 },               # swap the order of args
                    function 'prohibit', as { return 1 },
                    );
    
    my $DD3 = Devel::Decouple->new;
    $DD3->decouple( $module,
                    function 'prohibit', as { return 1 },
                    function 'inhibit',  as { return 1 },
                    default_sub,         as { return undef },
                    );
    
    my $DD4 = Devel::Decouple->new;
    $DD4->decouple( $module,
                    default_sub,         as { return undef },           #swap the order of args again
                    function 'prohibit', as { return 1 },
                    function 'inhibit',  as { return 1 },
                    );
    
    my $DD5 = Devel::Decouple->new;
    $DD5->decouple( $module,
                    default_sub,          as { return undef },
                    functions @functions, as { return 1 },              # 'functions' must take a literal array
                    );
    #note( explain $DD5 );
    
    my $DD6 = Devel::Decouple->new;
    $DD6->decouple( $module,
                    functions @functions, as { return 1 },
                    default_sub,          as { return undef },
                    ); 
    #note( explain $DD6 );
    
    #           GOT         EXPECTED    MESSAGE
    eq_or_diff( $DD,        $DD2,       "returned identical objects"                        );
    eq_or_diff( $DD3,       $DD4,       "returned identical objects with defaults"          );
    eq_or_diff( $DD,        $DD4,       "returned identical objects with mixed"             );
    eq_or_diff( $DD5,       $DD6,       "returned identical objects with multiple"          );
    eq_or_diff( $DD,        $DD6,       "returned identical objects with mixed multiple"    );
    
}

done_testing;
