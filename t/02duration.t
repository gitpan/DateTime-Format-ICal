use strict;

use Test::More tests => 57;

use DateTime::Format::ICal;

my $ical = 'DateTime::Format::ICal';

{
    my $dur = $ical->parse_duration('PT3S');

    ok( $dur->is_positive, 'duration should be positive' );
    is( $dur->weeks, 0, '0 weeks' );
    is( $dur->days, 0, '0 days' );
    is( $dur->hours, 0, '0 hours' );
    is( $dur->minutes, 0, '0 minutes' );
    is( $dur->seconds, 3, '3 seconds' );

    is( $ical->format_duration($dur), '+PT3S', 'output should match input' );
}

{
    my $dur = $ical->parse_duration('PT4H3S');

    ok( $dur->is_positive, 'duration should be positive' );
    is( $dur->weeks, 0, '0 weeks' );
    is( $dur->days, 0, '0 days' );
    is( $dur->hours, 4, '4 hours' );
    is( $dur->minutes, 0, '0 minutes' );
    is( $dur->seconds, 3, '3 seconds' );

    is( $ical->format_duration($dur), '+PT4H3S', 'output should match input' );
}

{
    my $dur = $ical->parse_duration('PT4H25M3S');

    ok( $dur->is_positive, 'duration should be positive' );
    is( $dur->weeks, 0, '0 weeks' );
    is( $dur->days, 0, '0 days' );
    is( $dur->hours, 4, '4 hours' );
    is( $dur->minutes, 25, '25 minutes' );
    is( $dur->seconds, 3, '3 seconds' );

    is( $ical->format_duration($dur), '+PT4H25M3S', 'output should match input' );
}

{
    my $dur = $ical->parse_duration('P22DT4H25M3S');

    ok( $dur->is_positive, 'duration should be positive' );
    is( $dur->weeks, 3, '3 weeks' );
    is( $dur->days, 1, '1 days' );
    is( $dur->hours, 4, '4 hours' );
    is( $dur->minutes, 25, '25 minutes' );
    is( $dur->seconds, 3, '3 seconds' );

    is( $ical->format_duration($dur), '+P3W1DT4H25M3S', 'output should match input' );
}

{
    my $dur = $ical->parse_duration('P4W22DT4H25M3S');

    ok( $dur->is_positive, 'duration should be positive' );
    is( $dur->weeks, 7, '7 weeks' );
    is( $dur->days, 1, '1 days' );
    is( $dur->hours, 4, '4 hours' );
    is( $dur->minutes, 25, '25 minutes' );
    is( $dur->seconds, 3, '3 seconds' );

    is( $ical->format_duration($dur), '+P7W1DT4H25M3S', 'output should match input' );
}

{
    my $dur = $ical->parse_duration('P4W2D');

    ok( $dur->is_positive, 'duration should be positive' );
    is( $dur->weeks, 4, '4 weeks' );
    is( $dur->days, 2, '2 days' );
    is( $dur->hours, 0, '0 hours' );
    is( $dur->minutes, 0, '0 minutes' );
    is( $dur->seconds, 0, '0 seconds' );

    is( $ical->format_duration($dur), '+P4W2D', 'output should match input' );
}

{
    my $dur = $ical->parse_duration('-P4W2D');

    ok( $dur->is_negative, 'duration should be negative' );
    is( $dur->weeks, 4, '4 weeks' );
    is( $dur->days, 2, '2 days' );
    is( $dur->hours, 0, '0 hours' );
    is( $dur->minutes, 0, '0 minutes' );
    is( $dur->seconds, 0, '0 seconds' );

    is( $ical->format_duration($dur), '-P4W2D', 'output should match input' );
}

{
    my $dur = $ical->parse_duration('PT0S');

    ok( $dur->is_positive, 'duration should be positive' );
    is( $dur->weeks, 0, '0 weeks' );
    is( $dur->days, 0, '0 days' );
    is( $dur->hours, 0, '0 hours' );
    is( $dur->minutes, 0, '0 minutes' );
    is( $dur->seconds, 0, '0 seconds' );

    is( $ical->format_duration($dur), '+PT0S', 'output should match input' );
}

{
    eval { $ical->parse_duration('+PT') };

    like( $@, qr/Invalid.+/, "Invalid duration string" );
}
