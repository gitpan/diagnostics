#BEGIN { @diagnostics::MODULES = qw(File::Compare) }
use File::Compare;
use diagnostics ('-m=File::Compare');
compare(undef, 'titi');
