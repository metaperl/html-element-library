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
    ['body', {id => 'corpus'},
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


#$t1->look_down('_tag' => 'body')->replace_content('all gone!');
$t1->content_handler(corpus => 'all gone!');
is( $t1->as_HTML, '<html><head><title>I like stuff!</title></head><body id="corpus" lang="en-JP">all gone!</body></html>
', "replaced all of body");


