package diagnostics;

=head1 NAME

diagnostics - Perl compiler pragma to force verbose warning diagnostics

splain - standalone program to do the same thing

=head1 SYNOPSIS

As a pragma:

    use diagnostics;
    use diagnostics -verbose;
    use diagnostics qw(-verbose -pretty -lang=fr -module=File::Compare -debug=63);

    enable  diagnostics;
    disable diagnostics;

As a program:

    perl program 2>diag.out
    splain [-v] [-p] [-l=fr] [-m=File::Compare] diag.out

=head1 DESCRIPTION

=head2 The C<diagnostics> Pragma

This module extends the terse diagnostics normally emitted by both the
perl compiler and the perl interpreter, augmenting them with the more
explicative and endearing descriptions found in F<perldiag>.  Like the
other pragmata, it affects the compilation phase of your program rather
than merely the execution phase.

To use in your program as a pragma, merely invoke

    use diagnostics;

at the start (or near the start) of your program.  (Note 
that this I<does> enable perl's B<-w> flag.)  Your whole
compilation will then be subject(ed :-) to the enhanced diagnostics.
These still go out B<STDERR>.

Due to the interaction between runtime and compiletime issues,
and because it's probably not a very good idea anyway,
you may not use C<no diagnostics> to turn them off at compiletime.
However, you may control their behaviour at runtime using the 
disable() and enable() methods to turn them off and on respectively.

Warnings dispatched from perl itself (or more accurately, those that match
descriptions found in F<perldiag>) are only displayed once (no duplicate
descriptions).  Module generated warnings follow the same rules if
the user asked for this module with the B<-module> option.
User code generated warnings ala warn() are unaffected,
allowing duplicate user messages to be displayed.

=head2 The I<splain> Program

While apparently a whole nuther program, I<splain> is actually nothing
more than a link to the (executable) F<diagnostics.pm> module, as well
as a link to the F<diagnostics.pod> documentation.  Since you're
post-processing with I<splain>, there's no sense in being able to
enable() or disable() processing.

Output from I<splain> is directed to B<STDOUT>, unlike the pragma.

=head2 Flags and options

=over 4

=item -verbose

The B<-verbose> flag first prints out the F<perldiag> introduction before
any other diagnostics.  It can be abbreviated to B<-v>.

=item -pretty

The B<-pretty> or B<-p> flag can generate nicer escape sequences for pagers.

=item -lang

The B<-lang> or B<-l> option looks for a translation of F<perldiag> instead of
the English version.

=item -module

The B<-module> option looks for a module-specific F<perldiag> file.
It can be abbreviated to B<-m>.

If a module is specified, the errors and warnings from the Perl
compiler / interpreter are not longer splained. Yet, if you specify
the pseudo-module B<perl> together with the module you requested, the
standard errors and warnings will be splained, as wll as the module's.

=item -file

The B<-file> option allows you to specify a file to read instead of,
or in addition to, F<perldiag> files. The value is the absolute
or relative pathname to the file.

As with the B<-module> option, using this option disables the splanations
for standard errors. And as the B<-module> option, the standard errors'
explanations are reenabled by adding the B<-module=perl> option.

=back

=head1 EXAMPLES

The following file is certain to trigger a few errors at both
runtime and compiletime:

    use diagnostics;
    print NOWHERE "nothing\n";
    print STDERR "\n\tThis message should be unadorned.\n";
    warn "\tThis is a user warning";
    print "\nDIAGNOSTIC TESTER: Please enter a <CR> here: ";
    my $a, $b = scalar <STDIN>;
    print "\n";
    print $x/$y;

If you prefer to run your program first and look at its problem
afterwards, do this:

    perl -w test.pl 2>test.out
    ./splain < test.out

Note that this is not in general possible in shells of more dubious heritage, 
as the theoretical 

    (perl -w test.pl >/dev/tty) >& test.out
    ./splain < test.out

Because you just moved the existing B<stdout> to somewhere else.

If you don't want to modify your source code, but still have on-the-fly
warnings, do this:

    exec 3>&1; perl -w test.pl 2>&1 1>&3 3>&- | splain 1>&2 3>&- 

Nifty, eh?

Or else, you can type:

  perl -M'diagnostics qw(-pretty -lang=fr -module=File::Compare)' test.pl

If you want to control warnings on the fly, do something like this.
Make sure you do the C<use> first, or you won't be able to get
at the enable() or disable() methods.

    use diagnostics; # checks entire compilation phase 
	print "\ntime for 1st bogus diags: SQUAWKINGS\n";
	print BOGUS1 'nada';
	print "done with 1st bogus\n";

    disable diagnostics; # only turns off runtime warnings
	print "\ntime for 2nd bogus: (squelched)\n";
	print BOGUS2 'nada';
	print "done with 2nd bogus\n";

    enable diagnostics; # turns back on runtime warnings
	print "\ntime for 3rd bogus: SQUAWKINGS\n";
	print BOGUS3 'nada';
	print "done with 3rd bogus\n";

    disable diagnostics;
	print "\ntime for 4th bogus: (squelched)\n";
	print BOGUS4 'nada';
	print "done with 4th bogus\n";

=head2 I18N

A French (for example) coder can use:

    use diagnostics '-lang=fr';
    print 2 / $x;

But you can specify several languages. A coder in a Swiss team
would write:

    use diagnostics qw(-lang=de -lang=it -lang=fr);
    print 2 / $x;

When the coder specifies one or more languages, English is not longer
used, unless explicitely requested. E.g. a Canadian team would write:

    use diagnostics qw(-l=en -l=fr);
    print 2 / $x;

Note however there is a significant performance penalty when 
the pragmatic module loads a C<perldiag> file, and this penalty
is multiplied when using several languages.

=head2 MODULES

If a coder types:

    use diagnostics '-module=Foo::Bar';
    use Foo::Bar;

the C<diagnostics> module will search each directory in C<@INC>,
looking for F<Foo/Bar/perldiag.pod> or F<Foo/Bar.pm>. And if 
F<Foo/Bar.pm> has been written with C<diagnostics> in mind, the
inline doc will contain the list of error messages with the proper
explanations.

The C<use diagnostics> statement should be executed before the
C<use Foo::Bar> statement, because the module may emit errors
or warnings at C<require> time or C<import> time.

To get explanations for both the module's errors and Perl's errors,
type:

    use diagnostics qw(-module=Foo::Bar -module=perl);
    use Foo::Bar;

Yet, there is a catch. When comparing the actual errors to the errors
contained in the F<perldiag.pod> files, the comparison ends with
the first match, which is not always the right match. For example,
compare the result of the following two programs:

    use diagnostics qw(-module=lib -module=perl);
    use lib '';

    use diagnostics qw(-module=perl -module=lib);
    use lib '';

In the first case, you obtain the proper explanation, while in the second
case you obtain the wrong one.

The B<-module> and B-<lang> options may be combined. In this case,
by typing

    use diagnostics qw(-module=Foo::Bar -lang=fr);
    use Foo::Bar;

the C<diagnostics> module will look only for F<Foo/Bar/perldiag.fr.pod> 
in the various C<@INC> directories.

=head1 INTERNALS

Diagnostic messages derive from the F<perldiag.pod> file when available at
runtime.  Otherwise, they may be embedded in the file itself when the
splain package is built.   See the F<Makefile> for details.

If an extant $SIG{__WARN__} handler is discovered, it will continue
to be honored, but only after the diagnostics::splainthese() function 
(the module's $SIG{__WARN__} interceptor) has had its way with your
warnings.

For backward compatibility, you can activate the various options
by initializing the variables C<$diagnostics::PRETTY> or
C<$diagnostics::DEBUG> and other instead of using dash options.

There is a B<-debug> option and a C<$diagnostics::DEBUG> variable you
may set if you're desperately curious what sorts of things are being
intercepted.

    use diagnostics -debug=63;

This option contains powers of 2 OR'ed together. Each power of two prints
some piece of debugging. For more information, RTFS (you were going to debug
the module, so you would have Read The Famous Source anyhow, wouldn't ya?).

=head1 KNOWN BUGS

Not being able to say "no diagnostics" is annoying, but may not be
insurmountable.

I could start up faster by delaying compilation until it should be
needed, but this gets a "panic: top_level" when using the pragma form
in Perl 5.001e.

Since delayed compilation is not possible, there is a systematic
performance penalty. Therefore, unlike C<use strict> and C<use warnings>,
you should I<not> use this module in production programs.

While it's true that this documentation is somewhat subserious, if you use
a program named I<splain>, you should expect a bit of whimsy.

=head1 UNKNOWN BUGS

If you find what you believe is a bug, check your version of
C<diagnostics.pm>.  If it is 1.1 or less, report it at
L<http://bugs.perl.org/>, as for any bug from the core or from a
standard module. Be sure to include C<diagnostics.pm> in the
subject, I check this regularly, so I can test this bug on the
alpha version, and possibly fix it.

If it is 1.2-alpha, report it to me C<JFORGET@cpan.org>. As long
as the 5.8.1 version is not released I will support this
version. After that, it will be a Perl-5 Porters' module
(although I will still be interested in it).

=head1 AUTHORS

The stable 1.1 version is maintained by the Perl-5 Porters
(C<http://www.xray.mpe.mpg.de/mailing-lists/perl5-porters/>)

The initial version was written by Tom Christiansen
<C<tchrist@mox.perl.com>>, 25 June 1995.

The new 1.2 version was written by Jean Forget (C<JFORGET@cpan.org>),
with some help from Gérald, Philippe, Rafael and O'Reilly France,
2 July 2002.

=cut

use strict;
use 5.006;
use Carp;

our $VERSION = "1.2-alpha";
our $DEBUG; #   1 for the search for POD files
            #   2 for the parsing of POD files
            #   4 for the final transmo subroutine
            #   8 for transmo's regular spressions
            #  16 for the step-by-step building of transmo's regular spressions
	    #  32 for transmo's results
            #  64 dumps the %msg hash
            # 128 warning about unknown %-sequences
our $VERBOSE;
our $PRETTY;
our @LANG;
our @MODULES;
our @FILES;
our $PODFILE;

use Config;
my ($privlib, $archlib, $sitelib) = @Config{qw(privlibexp archlibexp sitelibexp)};
if ($^O eq 'VMS') {
    require VMS::Filespec;
    $privlib = VMS::Filespec::unixify($privlib);
    $archlib = VMS::Filespec::unixify($archlib);
    $sitelib = VMS::Filespec::unixify($sitelib);
}
$sitelib =~ s(\\)(/)g;
my %podfiles = ();
my $first_time = 1;

$DEBUG ||= 0;
my $WHOAMI = ref bless [];  # nobody's business, prolly not even mine

local $| = 1;
local $_;

my $standalone;
my(%HTML_2_Troff, %HTML_2_Latin_1, %HTML_2_ASCII_7);

CONFIG: {
    our $opt_p = our $opt_d = our $opt_v = our $opt_f = our $opt_l = '';

    unless (caller) {
	$standalone++;
	parse_options(@ARGV);
	first_time();
    }
}


%HTML_2_Troff = (
    'amp'	=>	'&',	#   ampersand
    'lt'	=>	'<',	#   left chevron, less-than
    'gt'	=>	'>',	#   right chevron, greater-than
    'quot'	=>	'"',	#   double quote

    "Aacute"	=>	"A\\*'",	#   capital A, acute accent
    # etc

);

%HTML_2_Latin_1 = (
    'amp'	=>	'&',	#   ampersand
    'lt'	=>	'<',	#   left chevron, less-than
    'gt'	=>	'>',	#   right chevron, greater-than
    'quot'	=>	'"',	#   double quote

    "Aacute"	=>	"\xC1"	#   capital A, acute accent

    # etc
);

%HTML_2_ASCII_7 = (
    'amp'	=>	'&',	#   ampersand
    'lt'	=>	'<',	#   left chevron, less-than
    'gt'	=>	'>',	#   right chevron, greater-than
    'quot'	=>	'"',	#   double quote

    "Aacute"	=>	"A"	#   capital A, acute accent
    # etc
);

our %HTML_Escapes;

*THITHER = $standalone ? *STDOUT : *STDERR;

my $transmo;

my %msg;        # splanations for each message
my %seen;       # true if error message already seen in any language
my %translated; # true if error message already seen in current language

if ($standalone) {
    if (!@ARGV and -t STDIN) { print STDERR "$0: Reading from STDIN\n" } 
    while (defined (my $error = <>)) {
	splainthis($error) || print THITHER $error;
    } 
    exit;
} 

my $olddie; # Old programmers never die. They just branch to another address.
my $oldwarn;

sub parse_options {
    @ARGV = @_;
    require Getopt::Long;
    my %opts;
    if ($first_time) {
        %opts = ("pretty!"    => \$PRETTY
              ,  "verbose+"   => \$VERBOSE
              ,  "debug:i"    => \$DEBUG
              ,  "lang=s@"    => \@LANG
              ,  "module=s@"  => \@MODULES
              ,  "file=s@"    => \@FILES
	      )
    }
    else {
        %opts = ("verbose+"   => \$VERBOSE
              ,  "debug:i"    => \$DEBUG
	      )
    }
    Getopt::Long::GetOptions(%opts);
}

sub first_time {

    @LANG = qw(en) unless @LANG;
    @MODULES = qw(perl) unless @MODULES || @FILES;
    print STDERR @LANG, "\n" if $DEBUG & 1;
    my @podfiles = map { diagnostics::findpods($_, @LANG) } @MODULES;
    # handy for development testing of new warnings etc
    unshift @podfiles, [ "./pod/perldiag.pod", "en", '*new*', 1] if -e "pod/perldiag.pod";
    # user-specified files
    unshift @podfiles, map { [ $_, ".", $_, 1] } @FILES;
    if ($DEBUG & 1) {
        local $_;
        print STDERR "Found podfiles\n";
        print join(' ', @$_, "\n") foreach @podfiles;
    }
    *HTML_Escapes = do {
        if ($standalone) {
    	$PRETTY ? \%HTML_2_Latin_1 : \%HTML_2_ASCII_7; 
        } else {
    	\%HTML_2_Latin_1; 
        }
    }; 
    $transmo = <<EOFUNC;
sub transmo {
    #local \$^W = 0;  # recursive warnings we do NOT need!
    study;
EOFUNC
    {
        print STDERR "FINISHING COMPILATION for $_\n" if $DEBUG & 2;
        local $/ = ''; # paragraph mode
        local $_;
        %seen = %translated = %msg = ();
    
    foreach my $pod_lng (@podfiles) # trying all perldiag.pod files and translations
    {
      my ($PODFILE, $lang, $module, $startstop) = @$pod_lng ;
      print STDERR "Reading $PODFILE for $lang $module\n" if $DEBUG & 2;
      if (open(POD_DIAG, $PODFILE)) {
    	warn "Happy happy podfile from real $PODFILE\n" if $DEBUG & 2;
        } 
      readpod($lang, $module, $startstop);
    }
    unless (%msg) # trying current .pm file, because all perldiag.pod's failed
    {
        if (caller) {
    	INCPATH: {
    	    for my $file ( (map { "$_/$WHOAMI.pm" } @INC), $0) {
    		warn "Checking $file\n" if $DEBUG & 2;
    		if (open(POD_DIAG, $file)) {
    		    while (<POD_DIAG>) {
    			next unless /^__END__\s*# wish diag dbase were more accessible/;
    			print STDERR "podfile is $file\n" if $DEBUG & 2;
    			last INCPATH;
    		    }
    		}
    	    } 
    	}
        } else { 
    	print STDERR "podfile is <DATA>\n" if $DEBUG & 2;
    	*POD_DIAG = *main::DATA;
        }
        readpod('en', '', 1);
        die "No diagnostics?" unless %msg;
    }
        $transmo .= "    return 0;\n}\n";
        print STDERR $transmo if $DEBUG & 4;
        eval $transmo;
        die $@ if $@;
        if ($DEBUG & 64) {
          print STDERR "$_\n$msg{$_}\n----\n" foreach sort keys %msg;
        }
    
    }
}

sub import {
    shift;
    $^W = 1; # yup, clobbered the global variable; 
	     # though, if you want diags, you want diags.
    return if defined $SIG{__WARN__} && ($SIG{__WARN__} eq \&warn_trap);
    local @ARGV = @_;
    parse_options(@ARGV);

    if ($first_time) {
        first_time();
        $first_time = 0;
    }
    $oldwarn = $SIG{__WARN__};
    $olddie  = $SIG{__DIE__};
    $SIG{__WARN__} = \&warn_trap;
    $SIG{__DIE__}  = \&death_trap;
} 

sub enable { &import }

sub disable {
    shift;
    return unless $SIG{__WARN__} eq \&warn_trap;
    $SIG{__WARN__} = $oldwarn || '';
    $SIG{__DIE__}  = $olddie || '';
} 
sub findpods {
  my ($module, @lang) = @_;
  print STDERR "findpods $module @lang\n" if $DEBUG & 1;
  my @pods = map { diagnostics::findpod ($module, $_) } @lang;
  if ($DEBUG & 1) {
      print STDERR "findpods ", join(' ', @$_, "\n") foreach @pods;
  }
  push @pods, diagnostics::findpod $module, 'en' unless @pods;
  @pods;
}
sub findpod {
  my ($module, $lang) = @_;
  my $startstop = 1; # need start and stop tags, (0 -> automatic start and stop)
  $module =~ s(::)(/)g; ####### NOT PORTABLE! UNIX AND WIN ONLY!
  my @trypod;
  if ($lang eq 'en' && $module eq 'perl') {
      $startstop = 0; # automatic start / stop for backward compatibility
      @trypod = (
	   "$archlib/pod/perldiag.pod",
	   "$privlib/pod/perldiag-$Config{version}.pod",
	   "$privlib/pod/perldiag.pod",
	   "$archlib/pods/perldiag.pod",
	   "$privlib/pods/perldiag-$Config{version}.pod",
	   "$privlib/pods/perldiag.pod",
	  );
    }
  elsif ($module eq 'perl') {
      @trypod = (
	   "$sitelib/pod/perldiag.$lang.pod",
	   "$sitelib/pod/perldiag-$Config{version}.$lang.pod",
	   "$archlib/pod/perldiag.$lang.pod",
	   "$archlib/pod/perldiag-$Config{version}.$lang.pod",
	   "$privlib/pod/perldiag.$lang.pod",
	   "$privlib/pod/perldiag-$Config{version}.$lang.pod",
	   "$sitelib/perldiag.$lang.pod",
	   "$sitelib/perldiag-$Config{version}.$lang.pod",
	   "$archlib/perldiag.$lang.pod",
	   "$archlib/perldiag-$Config{version}.$lang.pod",
	   "$privlib/perldiag.$lang.pod",
	   "$privlib/perldiag-$Config{version}.$lang.pod",
	   "./pod/perldiag.$lang.pod",
	   "./pod/perldiag-$Config{version}.$lang.pod",
	   "./perldiag.$lang.pod",
	   "./perldiag-$Config{version}.$lang.pod",
	  );
    }
  elsif ($lang eq 'en') 
    { @trypod = map { ("$_/$module/perldiag.pod", "$_/$module.pm") } ( $sitelib, ".", @INC ) }
  else
    { @trypod = map { "$_/$module/perldiag.$lang.pod" } ( $sitelib, ".", @INC ) }
  print STDERR join ' ', "$lang: trypod is", @trypod, "\n" if $DEBUG & 1;
  my $PODFILE = ((grep { -e } @trypod))[0];
  if ($^O eq 'MacOS') {
    # just updir one from each lib dir, we'll find it ...
    ($PODFILE) = grep { -e } map { "$_:pod:perldiag.pod" } @INC;
  }
  print STDERR "podfile is ", $PODFILE, "\n" if $DEBUG & 1;
  [ $PODFILE, $lang, $module, $startstop ]
}


my $spec = qr(%[cdsg%]|%l?x|%\#?o|%\d*\.?\d*f);
#
# Warning about unknown printf specifiers
#
sub checkprt {
  my ($line) = @_;
  my $l = $line;
  $l =~ s/$spec//g;  # Specifiers that we know about
  $l =~ s/%ENV/ /g;  # Harmless string within the message
  $l =~ s/%hash/ /g; # Harmless string within the message
  $l =~ s/% may only be used//; # ditto
  $l =~ s/missing the % in//;   # the same
  $l =~ s/instead of %?//;      # ...
  $l =~ s/access key '%_'//;    # ...
  $l =~ s/Can't use %!//;       # ...

  print STDERR "Unknown %-sequence in $line\n" if $l =~ /%/;
}
#
# Converts a printf specifier ("%s", "%d" and the like) into a regexp
# partly inspired from the Ram book, recipe 2.1
#
sub prt2re {
  my ($spec) = @_;
  $spec eq '%s'   and return '.*?';
  $spec eq '%d'   and return '-?\\d+';
  $spec eq '%c'   and return '.';
  $spec eq '%g'   and return '(?:[+-]?)(?=\\d|\\.\\d)\\d*(?:\\.\\d*)?(?:[Ee][+-]?\\d+)?';
  $spec =~ /%l?x/ and return '[[:xdigit:]]*?';
  $spec =~ /%\#?o/ and return '\d*?';          # KISS principle: 8 and 9 are allowed, so what?
  $spec =~ /%\d*\.?\d*f/ and return '(?=\\d|\\.\\d)\\d*(?:\\.\\d*)?';
  return "\Q$spec\E";
}

sub readpod {
    my ($lang, $module, $startstop) = @_;
    my $header;
    my $for_item;
    my $prevent_confusion;
    my $go = ! $startstop;
    while (<POD_DIAG>) {

	unescape();
	if ($PRETTY) {
	    sub noop   { return $_[0] }  # spensive for a noop
	    sub bold   { my $str =$_[0];  $str =~ s/(.)/$1\b$1/g; return $str; } 
	    sub italic { my $str = $_[0]; $str =~ s/(.)/_\b$1/g;  return $str; } 
	    s/[BC]<(.*?)>/bold($1)/ges;
	    s/[LIF]<(.*?)>/italic($1)/ges;
	} else {
	    s/[BC]<(.*?)>/$1/gs;
	    s/[LIF]<(.*?)>/$1/gs;
	} 
        # plain text
	unless (/^=/) {
	    if ($go and defined $header) { 
                # Discard useless sentences
		if ( $header eq 'DESCRIPTION' && 
		    (   /Optional warnings are enabled/ 
		     || /Some of these messages are generic./
		    ) )
		{
		    next;
		}
		# Add module name to prevent confusion
		$msg{$header} .= "    [$module]\n" if $prevent_confusion;
		$prevent_confusion = 0;

		# Add description
		s/^/    /gm;
		$msg{$header} .= $_;
	 	undef $for_item;	
	    }
	    next;
	}

        # start tag
        if (/^=for\s+diagnostics\s*\nstart\s+description\s*$/) {
	    $msg{$header = 'DESCRIPTION'} = '';
	    $go = 1;
	    undef $for_item;
	    next;
	    }
        if (/^=for\s+diagnostics\s*\nstart\s+items\s*$/) {
	    $header = '';
	    $go = 1;
	    undef $for_item;
	    next;
	    }

        # stop tag
        if (/^=for\s+diagnostics\s*\nstop\s*$/) {
	    $go = 1 - $startstop;
	    }

	# extraction is stopped (just above or long ago)
	next unless $go;

        # other POD directive (neither start, nor stop, nor item)
	unless ( s/=item (.*?)\s*\z//) {
            # intro for English core diag file
	    if ( !$startstop and $_ =~ s/=head1\sDESCRIPTION//) {
		$msg{$header = 'DESCRIPTION'} = &{$PRETTY ? \&bold : \&noop}("DESCRIPTION OF DIAGNOSTICS\n");
		undef $for_item;
	    }
            # intro for module diagfile or foreign diagfile
	    elsif( s/^=head1\s(.*?)\s*\z// ) {
		$msg{$header = 'DESCRIPTION'} = &{$PRETTY ? \&bold : \&noop}("$1\n");
		undef $for_item;
	    } 
	    elsif( s/^=for\s+diagnostics\s*\n(.*?)\s*\z// ) {
		$for_item = $1;
	    } 
	    next;
	}

	if( $for_item ) { $header = $for_item; undef $for_item } 
	else {
	    $header = $1;
	    # multiline message (usually "marked by <--HERE")
	    while( $header =~ /[;,]\z/ ) {
		<POD_DIAG> =~ /^\s*(.*?)\s*\z/;
		$header .= ' '.$1;
	    }
	}

	# strip formatting directives in =item line
	$header =~ s/[A-Z]<(.*?)>/$1/g;

	print STDERR "$WHOAMI: Duplicate entry: \"$header\"\n"
	    if $translated{$lang}{$header};
        $translated{$lang}{$header} = 1;
        $prevent_confusion = 1 if @FILES + @MODULES >= 2;
        next if $seen{$header}; # do not duplicate regexps in transmo
        $seen{$header} = 1;

	if ($header =~ /%/) {
	    my $rhs = my $lhs = $header;
            checkprt($lhs) if $DEBUG & 128;
            $lhs =~ s/(.*?)($spec)/"\Q$1\E" . prt2re($2) . "\377"/eg;
	    print STDERR $lhs, "\n" if $DEBUG & 16;
	    $lhs =~ s/\377([^\377]*)$/\Q$1\E/;
	    print STDERR $lhs, "\n" if $DEBUG & 16;
	    $lhs =~ s/\377//g;
	    print STDERR $lhs, "\n" if $DEBUG & 16;
	    $lhs =~ s/\.\*\?$/.*/; # Allow %s at the end to eat it all
	    print STDERR $lhs, "\n" if $DEBUG & 8;
	    $transmo .= "    s{^$lhs}\n     {\Q$rhs\E}s\n\t&& return 1;\n";
	} else {
	    $transmo .= "    m{^\Q$header\E} && return 1;\n";
	} 

	print STDERR "$WHOAMI: Duplicate entry: \"$header\"\n"
	    if $msg{$header};

	$msg{$header} = '';
    } 


    close POD_DIAG unless *main::DATA eq *POD_DIAG;
}

sub warn_trap {
    my $warning = $_[0];
    if (caller eq $WHOAMI or !splainthese($warning)) {
	print STDERR $warning;
    } 
    &$oldwarn if defined $oldwarn and $oldwarn and $oldwarn ne \&warn_trap;
};

sub death_trap {
    my $exception = $_[0];

    # See if we are coming from anywhere within an eval. If so we don't
    # want to explain the exception because it's going to get caught.
    my $in_eval = 0;
    my $i = 0;
    while (1) {
      my $caller = (caller($i++))[3] or last;
      if ($caller eq '(eval)') {
	$in_eval = 1;
	last;
      }
    }

    splainthese($exception) unless $in_eval;
    if (caller eq $WHOAMI) { print STDERR "INTERNAL EXCEPTION: $exception"; } 
    &$olddie if defined $olddie and $olddie and $olddie ne \&death_trap;

    return if $in_eval;

    # We don't want to unset these if we're coming from an eval because
    # then we've turned off diagnostics.

    # Switch off our die/warn handlers so we don't wind up in our own
    # traps.
    $SIG{__DIE__} = $SIG{__WARN__} = '';

    # Have carp skip over death_trap() when showing the stack trace.
    local($Carp::CarpLevel) = 1;

    confess "Uncaught exception from user code:\n\t$exception";
	# up we go; where we stop, nobody knows, but i think we die now
	# but i'm deeply afraid of the &$olddie guy reraising and us getting
	# into an indirect recursion loop
};

my %exact_duplicate;
my %old_diag;
my $count;
my $wantspace;
sub splainthese {
    my $ret = 0;
    foreach  my $line (split /\n+/, $_[0]) {
        # Do not use logical or, because of short-circuit. Bitwise is OK
        $ret |= splainthis("$line\n");
    }
    $ret;
}
sub splainthis {
    local $_ = shift;
    local $\;
    print STDERR "splainthis:\n$_\n" if $DEBUG & 32;
    ### &finish_compilation unless %msg;
    s/\.?\n+$//;
    my $orig = $_;
    # return unless defined;
    s/, <.*?> (?:line|chunk).*$//;
    if ($DEBUG & 32)  {
        print STDERR "\$_\n$_\n";
        print STDERR "\$orig\n$orig\n";
    }
    my $real = s/(.*?)\s+at .*? (?:line|chunk) \d+.*/$1/;
    s/^\((.*)\)$/$1/;
    if ($DEBUG & 32)  {
        print STDERR "\$_\n$_\n";
        print STDERR "\$orig\n$orig\n";
        print STDERR "\$real\n$real\n";
	print STDERR "\$msg{$_}\n";
	print STDERR "$msg{$_}\n";
    }
    if ($exact_duplicate{$orig}++) {
        print STDERR "Duplicate $orig\n" if $DEBUG & 32;
	return &transmo;
    }
    else {
	return 0 unless &transmo;
    }
    $orig = shorten($orig);
    if ($DEBUG & 32)  {
        print STDERR "\$_\n$_\n";
        print STDERR "\$orig\n$orig\n";
        print STDERR "\$real\n$real\n";
	print STDERR "\$msg{$_}\n";
	print STDERR "$msg{$_}\n";
    }
    if ($old_diag{$_}) {
	autodescribe();
	print THITHER "$orig (#$old_diag{$_})\n";
	$wantspace = 1;
    } else {
	autodescribe();
	$old_diag{$_} = ++$count;
	print THITHER "\n" if $wantspace;
	$wantspace = 0;
	print THITHER "$orig (#$old_diag{$_})\n";
	if ($msg{$_}) {
	    print THITHER $msg{$_};
	} else {
	    if (0 and $standalone) { 
		print THITHER "    **** Error #$old_diag{$_} ",
			($real ? "is" : "appears to be"),
			" an unknown diagnostic message.\n\n";
	    }
	    return 0;
	} 
    }
    return 1;
} 

sub autodescribe {
    if ($VERBOSE and not $count) {
	print THITHER 
		"\n$msg{DESCRIPTION}\n";
    } 
} 

sub unescape { 
    s {
            E<  
            ( [A-Za-z]+ )       
            >   
    } { 
         do {   
             exists $HTML_Escapes{$1}
                ? do { $HTML_Escapes{$1} }
                : do {
                    warn "Unknown escape: E<$1> in $_";
                    "E<$1>";
                } 
         } 
    }egx;
}

sub shorten {
    my $line = $_[0];
    if (length($line) > 79 and index($line, "\n") == -1) {
	my $space_place = rindex($line, ' ', 79);
	if ($space_place != -1) {
	    substr($line, $space_place, 1) = "\n\t";
	} 
    } 
    return $line;
} 


33 unless $standalone;  # or it'll complain about itself

__END__ # wish diag dbase were more accessible

=for the most curious

Why 33?  The first answer is, the value 1 is only a Perl tradition,
not a requirement. Any true value will do (Cf. the Ram Book, introduction
to chapter 12).

The second answer is, 33 is the traditional value in France when
a physician examines a patient. The physician applies his stethoscope
to the patient's chest, and orders
- Breathe through your mouth.
- Cough.
- Dites trente-trois.

By the way, this reminds me of a gag in the movie La Grande Vadrouille, 
which applies both to I18N and diagnostics. The film takes place
in Nazi-occupied France, in 1941 or 1942. A British pilot has been 
shot down over France, but he has been fetched by an escape organization,
which leads Jews and RAF airmen through the demarcation line to
the unoccupied half of France. He is accompanied by a young
nurse, member of the underground. Because of some delay,
she places him in a hospital where he will stay for the night.

Morning comes, and before the pilot can leave, the head nurse
comes to visit all her patients. The head nurse is not a member 
of the underground, but she has more sympathies to them than
to the German occupiers. She arrives at the pilot's bed, 
takes her stethoscope and starts the examination.

Head nurse:
- Respirez par la bouche      - Breathe through your mouth.
- Toussez.                    - Cough.
- Dites trente-trois          - Say 33.

The pilot cast an interrogative look at the young nurse,
who answers with a nod and a reassuring smile.

Pilot:
- Thirty-three.

Heavy silence, and puzzled look on the head nurse's face.
And then,

Head nurse (to the young nurse):
- Je vois. Il doit aller      - I see. He must go to the
à la campagne prendre l'air.  countryside to get fresh air.

And the pilot and the nurse left... for the unoccupied
half of France.

