#BEGIN { @diagnostics::MODULES = qw(charnames);
#        @diagnostics::LANG    = qw(fr) }
use diagnostics qw(-m charnames -l fr);
use charnames;
