use Module::Build;

Module::Build->new
    ( module_name  => 'DateTime::Format::ICal',
      author       => 'Dave Rolsky <autarch@urth.org>',
      license      => 'perl',

      requires     => { 'DateTime' => 0.13,
                        'DateTime::Event::ICal' => 0,
                        'DateTime::Span' => 0,
                        'DateTime::TimeZone' => 0.22,
                        'Params::Validate' => 0.59,
                      },
    )->create_build_script;
