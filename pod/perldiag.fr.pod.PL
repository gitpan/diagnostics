#
# Split a multu-version perldiag file into a specific version perldiag file
#

use strict;
use warnings;

use File::Copy;

my $lang = 'fr';
my %vers = (v5.6.0 => '560', v5.6.1 => '561'
          , v5.7.0 => '573', v5.7.1 => '573'
          , v5.7.2 => '573', v5.7.3 => '573'
	  , v5.8.0 => '580');
my $vers = $vers{$^V};

my $podfile = "perldiag.$lang.pod";
my $source  = "diagfr.src";

my $ok = 1;
my $go = qr[defined\(perldiag$vers\)];

open S, $source      or die "Opening $source: $!";
open P, "> $podfile" or die "Opening $source: $!";
while (<S>)
  {
    if (/^\#if defined\(perldiag\d{3}/)
      {
        $ok = 0;
        $ok = 1 if $_ =~ $go;
        next;
      }
    if (/^\#endif/)
      {
        $ok = 1;
        next;
      }
    print P $_ if $ok;
  }
close S or die "Closing $source: $!";
close P or die "Closing $podfile: $!";

# For the various t/*.t scripts
copy ("perldiag.fr.pod", "../perldiag.fr.pod")
      or die "copy to .. failed: $!";
# blib has already been filled, but the contents of perldiag.fr.pod
# was not the proper one. We put the proper one
copy ("perldiag.fr.pod", "../blib/lib/perldiag.fr.pod")
      or die "copy to blib failed: $!";
