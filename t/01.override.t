use Test::More;
use Test::Differences;
use Test::Exception;

use Devel::Decouple;
use lib 't';
use TestMod::Baz;

my $module = 'TestMod::Baz';
my @modules = qw{
        TestMod::Foo
        TestMod::Bar
};
my @functions = qw{
        prohibit
        inhibit
};

DEFAULT_OVERRIDES: {
    #           GOT                     EXPECTED                    MESSAGE
    is( TestMod::Baz::inhibit(),        "I'm inhibited",            "original 'inhibit'"            );
    is( TestMod::Baz::prohibit(),       "I'm prohibited",           "original 'prohibit'"           );
    
    my $DD = Devel::Decouple->new->decouple( $module );
    #note( explain $DD );
    
    is( TestMod::Baz::inhibit(),        undef,                      "default override 'inhibit'"    );
    is( TestMod::Baz::prohibit(),       undef,                      "default override 'prohibit'"   );
    
}

CUSTOM_OVERRIDES: {
    #           GOT                     EXPECTED                    MESSAGE
    is( TestMod::Baz::inhibit(),        "I'm inhibited",            "original 'inhibit'"            );
    is( TestMod::Baz::prohibit(),       "I'm prohibited",           "original 'prohibit'"           );
    
    my $DD1 = Devel::Decouple->new;
    $DD1->decouple( $module, from @modules,
                        function 'prohibit', as { return 2 },
                        function 'inhibit',  as { return 3 }
                        );
    
    is( TestMod::Baz::prohibit(),       2,                          "custom override 'prohibit'"    );
    is( TestMod::Baz::inhibit(),        3,                          "custom override 'inhibit'"     );
    
    my $DD2 = Devel::Decouple->new;
    $DD2->decouple( $module,
                        default_sub,          as { return 'boom!' },
                        functions @functions, as { return "defined by \$DD2" }  # functions takes a literal array
                        );
    
    is( TestMod::Baz::inhibit(),        "defined by \$DD2",         "custom override 'inhibit' with 'functions'" );
    is( TestMod::Baz::prohibit(),       "defined by \$DD2",         "custom override 'prohibit' with 'functions'");
    
    my $DD3 = Devel::Decouple->new;
    $DD3->decouple( $module, from @modules,
                        function 'prohibit', preserved,
                        function 'inhibit',  as { return "defined by \$DD3" }
                        );
    #note( explain $DD2 );
    #note( explain $DD3 );
    
    is( TestMod::Baz::inhibit(),        "defined by \$DD3",         "custom override 'inhibit' with 'preserved'" );
    is( TestMod::Baz::prohibit(),       "defined by \$DD2",         "custom override 'prohibit' with 'preserved'");
    
    my $DD4 = Devel::Decouple->new;
    $DD4->decouple( $module, from @modules,
                        function 'inhibit',  as { return "defined by \$DD4" }
                        );
    #note( explain $DD4 );
    
    is( TestMod::Baz::inhibit(),        "defined by \$DD4",         "custom override 'inhibit' with mixed default" );
    is( TestMod::Baz::prohibit(),       undef,                      "custom override 'prohibit' with mixed default");
    
    
    ### REVERTING: popping function definitions off the stack...
    
    undef $DD4;
    #note( explain $DD4 );
    
    is( TestMod::Baz::inhibit(),        "defined by \$DD3",         "undef latest 'inhibit'" );
    is( TestMod::Baz::prohibit(),       "defined by \$DD2",         "undef latest 'prohibit'");
    
    $DD3->revert( 'inhibit' );
    #note( explain $DD3 );
    
    is( TestMod::Baz::inhibit(),        "defined by \$DD2",         "selectively revert 'inhibit'" );
    is( TestMod::Baz::prohibit(),       "defined by \$DD2",         "selectively keep 'prohibit'");
    
    undef $DD2;
    #$DD2->revert( 'inhibit', 'prohibit' );
    #note( explain $DD2 );
    
    is( TestMod::Baz::inhibit(),        3,                          "undef last 'inhibit'" );
    is( TestMod::Baz::prohibit(),       2,                          "undef last 'prohibit'");
    
    #note( explain $DD1 );
    #$DD1->report;
}

DEFAULT_PRESERVED: {
    my $DD1 = Devel::Decouple->new;
    $DD1->decouple( $module, from @modules,
                        default_sub, preserved
                        );
    
    #           GOT                     EXPECTED                    MESSAGE
    is( TestMod::Baz::inhibit(),        "I'm inhibited",            "default 'inhibit'"     );
    is( TestMod::Baz::prohibit(),       "I'm prohibited",           "default 'prohibit'"    );
    
    #note( explain $DD1 );
}

NON_IMPORT_OVERRIDE: {
    is( TestMod::Baz::exhibit(),        "I'm inhibited",            "original 'exhibit'"            );
    
    my $DD1 = Devel::Decouple->new;
    $DD1->decouple( $module, from @modules,
                        function 'exhibit', as { return "I'm on exhibit" }
                        );
    
    #           GOT                     EXPECTED                    MESSAGE
    is( TestMod::Baz::exhibit(),        "I'm on exhibit",           "original 'exhibit'"            );
    
}

UNINITIALIZED_METHOD_CALLS: {
    my $DD1 = Devel::Decouple->new;
    
    #           GOT                     EXPECTED                    MESSAGE
    throws_ok { $DD1->report }          qr{uninitialized object},   "throws on unitialized obj"        ;
    is( $DD1->modules,                  undef,                      "uninitialized: modules is undef" );
    is( $DD1->called_imports,           undef,                      "uninitialized: imports is undef" );
    is( $DD1->all_functions,            undef,                      "uninitialized: functs is undef"  );
    is( $DD1->module,                   undef,                      "uninitialized: module is undef"  );
    is( $DD1->document,                 undef,                      "uninitialized: document is undef");
    
    isa_ok( $DD1->revert,               'Devel::Decouple',          "uninit revert returns object"  );
    
}


done_testing;