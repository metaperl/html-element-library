#!/usr/bin/perl -T


use warnings;
use strict;

use Test::More;
use Test::XML;

BEGIN {
    use_ok('HTML::TreeBuilder');
    use_ok('HTML::Element::Prune');
}



my $root = HTML::TreeBuilder->new();
my $html =<<'EOHTML';
<html>    
<head>
  <title></title>
</head>
<body>
  <div>There was man named Jed</div>
<div>He did not have a head</div>
<div>He lived beneath a sled</div>
<div>Now he's afraid of Fred...</div>
<div>
</div>
    </body>
</html>
EOHTML

$root->parse($html);
$root->delete_ignorable_whitespace;
$root->prune;

my $expected = '
<html>
<body>
<div>There was man named Jed</div><div>He did not have a head</div><div>He lived beneath a sled</div><div>Now he&#39;s afraid of Fred...</div> </body>   
</html>
';

#warn sprintf 'HTML:%s:HTML', $root->as_HTML;

is_xml($root->as_HTML, $expected, 'test pruning');



done_testing;
