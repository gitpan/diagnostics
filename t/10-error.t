my %script = ('11-divzero' => 'Runtime error, with English text'
	   ,  '12-strict'  => 'Compile-time error, two lines'
	   ,  '13-zero-fr' => 'Runtime error, with French text'
	   ,  '14-filecmp' => 'Error from a module'
	   ,  '15-filecmp-fr' => 'Error from a module, French text'
	   ,  '16-zero-bil'   => 'Runtime error, bilingual text'
	   ,  '17-charnames'  => 'Carp from a module, English text'
	   ,  '18-charnames-fr'  => 'Carp from a module, French text'
	   ,  '19-charnames-bil' => 'Carp from a module, bilingual'
	   ,  '20-coreandmod'    => 'Warn from the core and carp from a module'
	   ,  '21-enable'        => 'Enabling and disabling descriptions (not 560)'
	   ,  '21a-enable'       => 'Enabling and disabling descriptions (560 only)'
	   ,  '22-diagfile'      => 'Specific file (not 560)'
	   ,  '22a-diagfile'     => 'Specific file (560 only)'
	   ,  '23-percent-g'     => 'Error with %g specifier'
	   ,  '24-eval'          => 'die within an eval, no output'
	   );
my @script = sort keys %script;

print "1..", scalar(@script), "\n";
my $i = 0;
foreach (@script)
  {
    ++$i;
    my @tstlines;
    if ($^V eq v5.6.0 && $script{$_} =~ /not 560/)
      {
        print "ok # skipped (explanations have changed since 5.6.0)\n";
        next;
      }
    elsif ($^V ne v5.6.0 && $script{$_} =~ /560 only/)
      {
        print "ok # skipped (explanations were different in 5.6.0)\n";
        next;
      }
    elsif ($^O =~ /Win32/)
      {
        # cmd.exe sucks!
        my @result = capture("perl -Mblib t/$_.pl", "", "");
        @tstlines = grep /^    \S/, split "\n", $result[1];
      }
    else
      {
        # bash and other Bourne family shells rule!
        open T, "perl -Mblib t/$_.pl   2>&1 > /dev/null |" or die "Ouverture (1) : $!";
        @tstlines = grep /^    \S/, <T>;
      }
    open R, "./t/$_.out" or die "Open ./t/$_.out: $!";
    my @reflines = grep /^    \S/, <R>;
    close R or die "Fermeture (2) : $!";

    # to be independant from formatting with newlines
    (my $tstresult = join ' ', @tstlines) =~ s/\s+/ /g;
    (my $refresult = join ' ', @reflines) =~ s/\s+/ /g;
    $tstresult =~ s/\s*$//;
    $refresult =~ s/\s*$//;
    my $prefix = $tstresult eq $refresult ? '' : 'not ';
    print "${prefix}ok $i $script{$_}\n";
  }
exit(0);

sub capture {
    my ( $cmd, $args, $input ) = @_;
    #my $infile  = tmpnam;
    my $errfile = 'tmpnam';
    my ( $out, $err ) = ( "", "" );
    local *F;
    local *OLDERR;

    # concatenate the command-line parameters
    $cmd .= " $args";

    # if there is some input
    #if ($input) {
    #    local *F;
    #    open F, "> $infile"
    #      or die "fatal: could not open temporay input file $infile: $!";
    #    print F $input;
    #    close F;
    #    $cmd .= " < $infile";
    #}

    # swap errputs
    open OLDERR, ">&STDERR"
      or die "fatal: could not duplicate STDERR: $!";
    close STDERR;
    open STDERR, "> $errfile"
      or die "fatal: could not open temporay errput file $errfile: $!";

    # run the command
    $out = `$cmd`;

    # put things back to normal
    close STDERR;
    open STDERR, ">&OLDERR"
      or die "fatal: could not duplicate STDERR: $!";
    close(OLDERR);

    # this is tedious, but...
    local $/;    # slurp
    open F, $errfile
      or die "fatal: could not open temporay errput file $errfile: $!";
    $err = <F>;
    close F;

    # cleanup
    #if ($input) {
    #    unlink $infile
    #      or warn "warning: could not remove temporary input file $errfile: $!";
    #}
    #unlink $errfile
    #  or warn "warning: could not remove temporary errput file $errfile: $!";

    return ( $out, $err, $? >> 8 );
}
