#!/usr/bin/env perl
use warnings;
use strict; 
require "common.pl";
print "Content-type:text/html\n\n";
my $bookmarksfile="bookmarks.db"; 
my $template="template.css";

my $start=1;
print <<"EOF";
<html>

<head>
	<link rel="stylesheet" type="text/css" href="${template}"/>
	<title>Bookmarks</title>
</head>

<body>
EOF
my $bmarks=parsebmarks($bookmarksfile);
foreach my $category (keys %$bmarks) {
	print "<div class=\"category\">\n";
	print "<h1>${category}</h1>\n";
	print "<ul>\n";
	foreach my $bmark (@{$bmarks->{$category}}) {
		print "\t<li><a href=\"$bmark->[1]\">$bmark->[0]</a></li>\n";
	}
	print "</ul>\n</div>\n\n";
}
print "</body>\n";
print "</html>\n";
