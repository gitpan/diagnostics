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
