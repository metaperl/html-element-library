use strict;
use Test::More qw(no_plan);

use HTML::TreeBuilder;
use HTML::Element::Library;

my $html =<<'EOHTML';
<html>
<head>
</head>
<body>
<table>
<tr>
  <td>a  <td>a  <td>a  <td>a
</tr>
<tr>
  <td>a  <td>a  <td id=findme>a  <td>a
</tr>
</table>
</body>
</html>
EOHTML

my $t1;
my $lol;

$t1 = HTML::TreeBuilder->new_from_content ( $html ) ;

my $found= $t1->look_down(id => 'findme');


my @found = $found->position;
#warn "@found";

is("@found", '-1 1 0 1 2');


