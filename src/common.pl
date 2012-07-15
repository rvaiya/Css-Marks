sub parsebmarks {
	return undef if (@_ != 1);
	my $bmarkfile=$_[0];	
	my $category="Default";
	my %bmarks=();
	return undef unless (-e $bmarkfile);
	open(BMARK, "<", $bmarkfile);
	while(<BMARK>) {
		if ($_ =~ /^\s*{\s*(.*?)\s*}\s*$/) {
			$category = $1;
			$bmarks{$category}=[];
		}
		elsif ($_ =~ /^\s*(.*?)\s*:\s*"(.*)"/) {
			push @{$bmarks{$category}}, [$1, $2];
		}
	
	}
	close(BMARK);
	return \%bmarks;
}

sub writebmarks {
	(my $bmarkarray, my $bmarkfile)=@_;
	open(BMARK, ">", $bmarkfile) || die "Unable to open $bmarkfile for writing\n";
	foreach (keys %$bmarkarray) {
		print BMARK "{ $_ }\n";
		foreach (@{$bmarkarray->{$_}}) {
			my $linkname=$_->[0];
			my $link=$_->[1];
			print BMARK "$linkname: \"$link\"\n";
		}
	}
	close(BMARK);
}

sub removelink { #Removes all instances of $link
	(my $link, my $rbmarks) = @_;
	foreach my $category (keys %$rbmarks)
	{
		my @temp;
		foreach (@{$rbmarks->{$category}}) {
			push @temp, $_ unless ($_->[1] eq $link);
		}
		 $rbmarks->{$category}=\@temp;
		 delete $rbmarks->{$category} if (scalar @{$rbmarks->{$category}} == 0);
	}
}

sub addlink {
	(my $category, my $linkname, my $link, my $rbmarks) = @_;
	$rbmarks->{$category}=[] unless (defined($rbmarks->{$category}));
	push @{$rbmarks->{$category}}, [$linkname, $link];
}

sub linkexists {
	my ($link, $bmarks)=@_;
	foreach (keys %$bmarks) {
		foreach (@{$bmarks->{$_}}) {
			return $_->[0] if ($_->[1] eq $link);
		}
	}
	return 0;
}

sub linknameexists {
	my ($linkname, $bmarks)=@_;
	foreach (keys %$bmarks) {
		foreach (@{$bmarks->{$_}}) {
			return $_->[1] if ($_->[0] eq $link);
		}
	}
	return 0;
}

1
