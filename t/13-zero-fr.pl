#BEGIN { @diagnostics::LANG = qw(fr) }
use diagnostics '-lang=fr';
my $x = 2;
print $x / 0;
