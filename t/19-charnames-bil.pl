#BEGIN { @diagnostics::MODULES = qw(charnames);
#        @diagnostics::LANG    = qw(fr en) }
use diagnostics qw(-m charnames -l fr -l en);
use charnames;
