#!/usr/bin/env perl
use strict;
use warnings;
use URI::Escape;
require "common.pl";

sub getargs {
	my %args=();
	foreach (split "&", $ENV{"QUERY_STRING"}) {
		my ($prop, $val)=split "=", $_;
		$args{$prop}=$val;
	}
	return %args;
}

sub dprint {
	my $bmarks=$_[0];	
	foreach (keys %$bmarks) {
		foreach (@{$bmarks->{$_}}) {
			print "$_->[0] $_->[1]<br/>\n";
		}
	}
}
my %args=getargs();

print "Content-type: text/html\n\n";
print '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';

my $bookmarkdb="bookmarks.db"; #Bookmarks file
my $bmarks=parsebmarks($bookmarkdb); #Parse bookmarks, store in hashref
die "Unable to parse $bookmarkdb\n" unless $bmarks;

if ($args{'remove'}) {
	my $remove=uri_unescape($args{'remove'});
	removelink($remove, $bmarks);
	writebmarks($bmarks, $bookmarkdb);
}

elsif ($args{'link'} && $args{'linkname'} && $args{'category'})
{
	my $linkname=uri_unescape($args{'linkname'});
	my $link=uri_unescape($args{'link'});
	my $category=uri_unescape($args{'category'});
	$category=~s/\+/ /g;
	$linkname=~s/\+/ /g;
	removelink($link, $bmarks);
	addlink($category, $linkname, $link, $bmarks);
	writebmarks($bmarks, $bookmarkdb);
}

print <<'EOF';
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
	<script type="text/javascript">
		function validate() {
			var form=document.getElementById("addlinkform");
			var regurl=new RegExp("^((http|ftp|https|javascript)://|www.).*");
			if (!(form.category.value && form.link.value && form.linkname.value)) {
				alert ("Fill in all fields");
			}
			else if (!regurl.test(form.link.value)) {
				alert("Invalid link (must have protocol prepended eg http://, ftp://, etc..)");
			} else {
				form.submit();
			}
	 	}
	function genbookmarklet() {
		var bmarklet='javascript:function f() { var linkname=prompt("Link Name", document.title); if (linkname == null || linkname == "") return; var category=prompt("Category"); if (category == null || category == "") return; var m=new XMLHttpRequest(); m.open("GET", "'+document.location.href.replace(/\/[^\/]*$/,"")+'/addlink.pl?link="+encodeURIComponent(document.location.href)+"&linkname="+encodeURIComponent(linkname)+"&category="+encodeURIComponent(category)); m.send(); }f();';

		document.getElementById("bookmarklettext").style.display="block";
		document.getElementById("bookmarklettext").innerHTML=bmarklet;
	}
	</script>
	<style type="text/css">
		.bmark {
			list-style-type:none;
			overflow:hidden;
		}

		.bmark > div > form {
			display:inline;
			margin-right: 4px;
		}

		.bmark > div {
			float:right;
		}

		#main {
			width:700px;
		}

		#addlink {
			position:fixed;
			bottom:0px;
			right:0px;
			width:280px;
		}

		#addlink span {
			overflow:hidden;
			display:block;
		}

		#addlink input {
			float:right;
		}
		#bookmarklet {
			position:absolute;
			top:0px;
			right:0px;
			width:280px;
		}

		#bookmarklettext {
			display:none;
			width:90%;
		}
	</style>
	<title>Bookmark Manager</title>
</head>

<body>
EOF

print "<div id=\"main\">\n\n";
foreach my $category (sort keys %$bmarks) {
	print "<h1>$category</h1>";
	print "<ul>\n";
	foreach my $bmark (@{$bmarks->{$category}}) {
		my ($linkname, $link)=@$bmark;
		$linkname=~s/\+/ /g;
		print "<li class=\"bmark\">$linkname";
		print "<div class=\"linkmgmt\">";
			print "<form action=\"cp.pl\" method=\"get\">";
				print "<input type=\"hidden\" name=\"link\" value=\"$link\">";
				print "<input type=\"hidden\" name=\"linkname\" value=\"$linkname\">";
				print "<select name=\"category\" onChange=\"this.form.submit()\">";
					foreach (sort keys %$bmarks) {
						print $_ eq $category ? "<option selected=\"selected\">$_</option>" : "<option>$_</option>"; 
					}
				print "</select>";
			print "</form>";

			print "<form>";
				print "<input type=\"hidden\" name=\"remove\" value=\"$link\"/>";
				print "<input type=\"Submit\" value=\"Remove\"/>";
			print "</form>";
		print "</div>";
		print "</li>";
	}
	print "</ul>\n";
}
print "</div>\n";



print <<"EOF";
<div id="bookmarklet">
<button onclick="genbookmarklet()">Generate Bookmarklet</button>
<textarea rows="10" id="bookmarklettext"></textarea>
</div>

<div id="addlink">
<form id="addlinkform" method="get" action="cp.pl">
	<span>Category: <input type="text" name="category"/></span>
	<span>Name: <input type="text" name="linkname"/></span>
	<span>Link: <input type="text" name="link"/></span>
	<input type="button" onclick="validate()" value="Add Link"/>
</form>
</div>
EOF
print "</body>\n</html>\n";
