use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	   => 'diagnostics',
    'VERSION_FROM' => 'diagnostics.pm', # finds $VERSION
    'DIR'	   => [ qw(pod utils lib charnames File-Compare) ],
    'INSTALLDIRS'  => 'perl',
    'PREREQ_PM'    => { 'Getopt::Long' => 0 }
);
