use ExtUtils::MakeMaker;

WriteMakefile( NAME         => 'DateTime::Format::ICal',
               VERSION_FROM => 'lib/DateTime/Format/ICal.pm',
               AUTHOR       => 'Dave Rolsky <autarch@urth.org>',
               ABSTRACT     => 'Formatting and Parsing of iCal formats',
               PREREQ_PM    => { 'DateTime' => 0 },
             );
