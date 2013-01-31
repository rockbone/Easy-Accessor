use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Easy::Accessor',
    VERSION_FROM      => 'lib/Easy/Accessor.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Easy/Accessor.pm', # retrieve abstract from module
       AUTHOR         => 'rockbone') : ()),
);
