package Arsenal;

use strict;
use Data::Dumper;

my %player;

sub new {
    my $this = shift;
    bless {}, ref($this) || $this;
}

my $number   = qr!\d{1,2}!;
my $name     = qr!\w+(?:\s\w{2,}){1,2}!;
my $position = qr!\w!;
my $height   = qr!\d[-]\d{1,2}!;
my $weight   = qr!\d{2,3}!;
my $birthday = qr!\w{3}\s\d{1,2},\s\d{4}!;
my $birthplace= qr!\w+(?:\s\w+)*(?:,\s\S+)*!;

sub load_data {
  my @data;

  while (<DATA>) {
    last if /__END__/;

    @player{qw(number name pos height weight birthday birthplace)}
	= 
	    m!
	      ($number)\s+
              ($name)\s+
              ($position)\s+
	      ($height)\s+
	      ($weight)\s+
	      ($birthday)\s+
	      ($birthplace)
	      !x;

    warn $_;
    warn Dumper \%player;
  }
}

1;
__DATA__
24	 Manuel Almunia	G	6-3	190	May 19, 1977	Pamplona, Spain
 10	 Dennis Bergkamp	F	6-0	172	May 10, 1969	Amsterdam, Netherlands
 23	 Sol Campbell	D	6-2	201	Sep 18, 1974	Newham, England
 22	 Gael Clichy	D	5-11	159	Jul 26, 1985	Clichy, France
 3	 Ashley Cole	D	5-7	148	Dec 20, 1980	Stepney, England
 18	 Pascal Cygan	D	6-4	192	Apr 19, 1974	Lens, France
 27	 Emmanuel Eboue	D	5-10	159	Jun 4, 1983	Abidjan, Cote d'Ivoire
 15	 Francesc Fabregas Soler	M	5-7	152	Apr 4, 1987	Arenys del Mar, Spain
 16	 Mathieu Flamini	M	5-10	148	Mar 7, 1984	Marseille, France
 40	 Ryan Garry	D	6-2	181	Sep 29, 1983	Hornchurch, England
 14	 Thierry Henry	F	6-2	179	Aug 17, 1977	Paris, France
 13	 Aliksandr Hleb	M	6-1	154	May 1, 1981	Minsk, USSR
 12	 Lauren	D	5-11	157	Jan 19, 1977	Londi Kribi, Cameroon
 1	 Jens Lehmann	G	6-3	192	Nov 10, 1969	Essen, West Germany
 8	 Fredrik Ljungberg	M	5-9	165	Apr 16, 1977	Halmstads, Sweden
 26	 Quincy Owusu Abeyie	F	5-11	163	Apr 15, 1986	Amsterdam, Netherlands
 7	 Robert Pires	M	6-1	163	Oct 29, 1973	Reims, France
 21	 Mart Poom	G	6-4	187	Feb 3, 1972	Tallinn, USSR
 9	 Jose Antonio Reyes	F	6-0	181	Sep 1, 1983	Utrera, Spain
 20	 Philippe Senderos	D	6-3	185	Feb 14, 1985	Geneva, Switzerland
 19	 Gilberto Silva	M	6-3	172	Oct 7, 1976	Belo Horizonte, Brazil
 17	 Alexandre Song	M	6-0	168	Apr 9, 1987	Cameroon
 28	 Kolo Toure	D	6-0	168	Mar 19, 1981	Sokoura Bouake, Cote d'Ivoire
 11	 Robin van Persie	F	6-0	157	Aug 6, 1983	Rotterdam, Netherlands
__END__
