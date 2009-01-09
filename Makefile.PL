use 5.006001;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'HTML::Element::Library',
    VERSION_FROM      => 'lib/HTML/Element/Library.pm', # finds $VERSION
    PREREQ_PM         => {
      Array::Group          => 1.00,

      File::Slurp           => 9999.06,

      HTML::PrettyPrinter   => 0.03,
      HTML::Tree            => 3.19,

      List::Rotation::Cycle => 1.003,
      List::MoreUtils       => 0.09,

      Params::Validate      => 0.80,

      Scalar::Listify       => 0.02,
    }, 
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/HTML/Element/Library.pm', # retrieve abstract from module
       AUTHOR         => 'Terrence Brannon <terry@hcoop.net>') : ()),
);

sub MY::postamble { q{

cleandist: FORCE
	make again; make cleanmanifest; make docs; make dist

again: FORCE
	make clean; perl Makefile.PL; make pm_to_blib

cleanmanifest: realclean FORCE
	rm MANIFEST ; perl Makefile.PL; touch MANIFEST; make manifest

%.t: pm_to_blib FORCE
	make; perl -Iblib/lib $@

docs : README CHANGES

README: lib/HTML/Element/Library.pm
	pod2text lib/HTML/Element/Library.pm > README

CHANGES: lib/HTML/Element/Library/Changes.pod
	pod2text lib/HTML/Element/Library/Changes.pod > CHANGES

}; }
