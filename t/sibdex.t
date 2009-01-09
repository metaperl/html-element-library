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

my $p = $t1->look_down('_tag' => 'body')->look_down(_tag => 'p');

is($p->sibdex, 1, "does the p tag have 1 as its index");


