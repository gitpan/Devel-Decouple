use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Devel::Decouple',
    AUTHOR              => 'Montgomery Conner <dev@namimedia.com>',
    VERSION_FROM        => 'lib/Devel/Decouple.pm',
    ABSTRACT_FROM       => 'lib/Devel/Decouple.pm',
    PL_FILES            => {},
    EXE_FILES		=> [],
    BUILD_REQUIRES 	=> {},
    PREREQ_PM => {
        'Test::More'   		=> 0,
	'Test::Deep'		=> 0,
	'Test::Differences'	=> 0,
        'version'      		=> 0,
	'Class::Inspector'	=> 0,
	'PPI::Document'		=> 0,
	'PPI::Find'		=> 0,
	'Monkey::Patch'		=> 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Devel-Decouple-*' },
);
