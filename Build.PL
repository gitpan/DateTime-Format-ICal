use Module::Build;

Module::Build->new
    ( module_name  => 'DateTime::Format::ICal',
      author       => 'Dave Rolsky <autarch@urth.org>',
      license      => 'perl',

      requires     => { 'DateTime' => 0,
                      },
    )->create_build_script;
