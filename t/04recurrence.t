#!/usr/bin/perl -w

use strict;

use Test::More tests => 2;

use DateTime::Format::ICal;
use DateTime::Span;

my $ical = 'DateTime::Format::ICal';

{
    # this is an example from rfc2445 
    my $recur =
        $ical->parse_recurrence( recurrence => 'freq=monthly;count=10;byday=1fr',
                                 dtstart    => $ical->parse_datetime( '19970905T090000' )
                               );
    my @r;
    while ( my $dt = $recur->next )
    {
        push @r, $ical->format_datetime( $dt );
    }

    my $s1 = join ',', @r;

    my $s2 = join ',', qw( 1997-09-05T09:00:00
                           1997-10-03T09:00:00
                           1997-11-07T09:00:00
                           1997-12-05T09:00:00
                           1998-01-02T09:00:00
                           1998-02-06T09:00:00
                           1998-03-06T09:00:00
                           1998-04-03T09:00:00
                           1998-05-01T09:00:00
                           1998-06-05T09:00:00
                         );

    $s2 =~ s/[-:]//g;

    is( $s1, $s2, "recurrence parser is ok" );
}

{
    # another example from rfc2445
    # DTSTART;TZID=US-Eastern:19980101T090000
    # RECUR:FREQ=YEARLY;UNTIL=2000-01-31T09:00:00;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA
    my $recur =
        $ical->parse_recurrence
            ( recurrence => 'FREQ=YEARLY;UNTIL=20000131T090000Z;BYMONTH=1;BYDAY=SU,MO,TU,WE,TH,FR,SA',
              dtstart    => $ical->parse_datetime( '19980101T090000' )
            );
    my @r;
    for ( 1 .. 2 )
    {
        my $dt = $recur->next;
        push @r, $ical->format_datetime( $dt );
    }

    my $s1 = join ',', @r;

    my $s2 = join ',', ( '1998-01-01T09:00:00',
                         '1998-01-02T09:00:00'
                       );

    $s2 =~ s/[-:]//g;

    is( $s1, $s2, "recurrence parser with 'until' is ok" );
}

