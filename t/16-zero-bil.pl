#BEGIN { @diagnostics::LANG = qw(fr en) }
use diagnostics qw(-l=fr -l=en);
my $x = 2;
print $x / 0;
