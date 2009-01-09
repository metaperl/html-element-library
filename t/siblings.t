# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl HTML-Element-Library.t'




use strict;
use Test::More qw(no_plan);

use HTML::Element::Library;


my $t1;
my $lol;
$t1 = HTML::Element->new_from_lol
  (
   $lol =
   ['html',
    ['head',
     [ 'title', 'I like stuff!' ],
    ],
    ['body',
     {
      'lang', 'en-JP'},
     'stuff',
     ['p', 'um, p < 4!', {'class' => 'par123'}],
     ['div', {foo => 'bar'}, '123'], # at 0.1.2
     ['div', {jack => 'olantern'}, '456'], # at 0.1.2
    ]
   ]
  )
  ;

my $div = $t1->look_down('_tag' => 'body')->look_down(_tag => 'p');
my @sibs = $div->siblings;

is($sibs[0], 'stuff', "first sibling is simple text");
is($sibs[2]->tag, 'div', "3rd tag a div tag");
is(scalar @sibs, 4, "4 siblings total");

