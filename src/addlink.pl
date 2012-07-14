#!/usr/bin/env perl
require "common.pl";
use URI::Escape;
my $bookmarkdb="bookmarks.db";
my %args;
foreach (split "&", $ENV{"QUERY_STRING"}) {
	my ($prop, $val)=split "=",$_;
	$args{uri_unescape($prop)}=uri_unescape($val);
}
my $category=$args{"category"};
my $link=$args{"link"};
my $linkname=$args{"linkname"};

print "Content-type:text/html\n\n";
if ($category && $link && $linkname) {
	my $bmarks=parsebmarks($bookmarkdb);
	addlink($category, $linkname, $link, $bmarks);
	writebmarks($bmarks, $bookmarkdb);
} else {
	print '<html><head><script type="text/javascript">document.close();alert("Invalid params");</script></head></html>';
}
