package DateTime::Format::ICal;

use strict;

use vars qw ($VERSION);

$VERSION = '0.03';

use DateTime;

sub new
{
    my $class = shift;

    return bless {}, $class;
}

# key is string length
my %valid_formats =
    ( 15 =>
      { params => [ qw( year month day hour minute second ) ],
        regex  => qr/^(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)$/,
        zero   => {},
      },
      13 =>
      { params => [ qw( year month day hour minute ) ],
        regex  => qr/^(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)$/,
        zero   => { second => 0 },
      },
      11 =>
      { params => [ qw( year month day hour ) ],
        regex  => qr/^(\d\d\d\d)(\d\d)(\d\d)T(\d\d)$/,
        zero   => { minute => 0, second => 0 },
      },
      8 =>
      { params => [ qw( year month day ) ],
        regex  => qr/^(\d\d\d\d)(\d\d)(\d\d)$/,
        zero   => { hour => 0, minute => 0, second => 0 },
      },
    );

sub parse_datetime
{
    my ( $self, $date ) = @_;

    # save for error messages
    my $original = $date;

    my %p;
    if ( $date =~ s/^TZID=([^:]+):// )
    {
        $p{time_zone} = $1;
    }
    # Z at end means UTC
    elsif ( $date =~ s/Z$// )
    {
        $p{time_zone} = 'UTC';
    }
    else
    {
        $p{time_zone} = 'floating';
    }

    my $format = $valid_formats{ length $date }
        or die "Invalid ICal datetime string ($original)";

    @p{ @{ $format->{params} } } = $date =~ /$format->{regex}/;

    return DateTime->new( %p, %{ $format->{zero} } );
}

sub parse_duration
{
    my ( $self, $dur ) = @_;

    my @units = qw( weeks days hours minutes seconds );

    $dur =~ m{ ([\+\-])?         # Sign
               P                 # 'P' for period? This is our magic character)
               (?:
                   (?:(\d+)W)?   # Weeks
                   (?:(\d+)D)?   # Days
               )?
               (?: T             # Time prefix
                   (?:(\d+)H)?   # Hours
                   (?:(\d+)M)?   # Minutes
                   (?:(\d+)S)?   # Seconds
               )?
             }x;

    my $sign = $1;

    my %units;
    $units{weeks}   = $2 if defined $2;
    $units{days}    = $3 if defined $3;
    $units{hours}   = $4 if defined $4;
    $units{minutes} = $5 if defined $5;
    $units{seconds} = $6 if defined $6;

    die "Invalid ICal duration string ($dur)"
        unless %units;

    if ( $sign eq '-' )
    {
        $_ *= -1 foreach values %units;
    }

    return DateTime::Duration->new(%units);
}

sub format_datetime
{
    my ( $self, $dt ) = @_;

    my $tz = $dt->time_zone;

    unless ( $tz->is_floating || $tz->is_utc || $tz->name )
    {
        $dt = $dt->clone->set_time_zone('UTC');
        $tz = $dt->time_zone;
    }

    my $base =
        ( $dt->hour || $dt->min || $dt->sec ?
          sprintf( '%04d%02d%02dT%02d%02d%02d',
                   $dt->year, $dt->month, $dt->day,
                   $dt->hour, $dt->minute, $dt->second ) :
          sprintf( '%04d%02d%02d', $dt->year, $dt->month, $dt->day )
        );


    return $base if $tz->is_floating;

    return $base . 'Z' if $tz->is_utc;

    return 'TZID=' . $tz->name . ':' . $base;
}

sub format_duration
{
    my ( $self, $duration ) = @_;

    die "Cannot represent years or months in an iCal duration\n"
        if $duration->delta_months;

    # simple string for 0-length durations
    return '+PT0S'
        unless $duration->delta_days || $duration->delta_seconds;

    my $ical = $duration->is_positive ? '+' : '-';
    $ical .= 'P';

    if ( $duration->delta_days )
    {
        $ical .= $duration->weeks . 'W' if $duration->weeks;
        $ical .= $duration->days  . 'D' if $duration->days;
    }

    if ( $duration->delta_seconds )
    {
        $ical .= 'T';

        $ical .= $duration->hours   . 'H' if $duration->hours;
        $ical .= $duration->minutes . 'M' if $duration->minutes;
        $ical .= $duration->seconds . 'S' if $duration->seconds;
    }

    return $ical;
}


1;

__END__

=head1 NAME

DateTime::Format::ICal - Parse and format iCal datetime and duration strings

=head1 SYNOPSIS

  use DateTime::Format::ICal;

  my $dt = DateTime::Format::ICal->parse_datetime( '20030117T032900Z' );

  my $dur = DateTime::Format::ICal->parse_duration( '+P3WT4H55S' );

  # 20030117T032900Z
  DateTime::Format::ICal->format_datetime($dt);

  # +P3WT4H55S
  DateTime::Format::ICal->format_duration($dur);

=head1 DESCRIPTION

This module understands the ICal date/time and duration formats, as
defined in RFC 2445.  It can be used to parse these formats in order
to create the appropriate objects.

=head1 METHODS

This class offers the following methods.

=over 4

=item * parse_datetime($string)

Given an iCal datetime string, this method will return a new
C<DateTime> object.

If given an improperly formatted string, this method may die.

=item * parse_duration($string)

Given an iCal duration string, this method will return a new
C<DateTime::Duration> object.

If given an improperly formatted string, this method may die.

=item * format_datetime($datetime)

Given a C<DateTime> object, this methods returns an iCal datetime
string.

The iCal spec requires that datetimes be formatted either as floating
times (no time zone), UTC (with a 'Z' suffix) or with a time zone id
at the beginning ('TZID=America/Chicago;...').  If this method is
asked to format a C<DateTime> object that has an offset-only time
zone, then the object will be converted to the UTC time zone
internally before formatting.

For example, this code:

    my $dt = DateTime->new( year => 1900, hour => 15, time_zone => '-0100' );

    print $ical->format_datetime($dt);

will print the string "19000101T160000Z".

=item * format_duration($duration)

Given a C<DateTime::Duration> object, this methods returns an iCal
duration string.

The iCal standard does not allow for months or years in a duration, so
if a duration for which C<delta_months()> is not zero is given, then
this method will die.

=head1 SUPPORT

Support for this module is provided via the datetime@perl.org email
list.  See http://lists.perl.org/ for more details.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

Some of the code in this module comes from Rich Bowen's C<Date::ICal>
module.

=head1 COPYRIGHT

Copyright (c) 2003 David Rolsky.  All rights reserved.  This program
is free software; you can redistribute it and/or modify it under the
same terms as Perl itself.

The full text of the license can be found in the LICENSE file included
with this module.

=head1 SEE ALSO

datetime@perl.org mailing list

http://datetime.perl.org/

=cut
