package Parser;

use strict;
use warnings;
use Data::Dumper;

sub readFile {
    my ( $file ) = @_;
    my $data = {};

    open my $fh, '<', $file or die qq{Can't open "$file" for input: $!};

    while ( my $line = <$fh> ) {
        my ( $log_type, $log_data ) = parseLine( $line );
        if ( $log_type ) {
            push @{ $data->{ $log_type } }, $log_data;
        } # if ...
    } # while ...

    close $fh;
    return $data;
} # sub readFile

sub parseLine {
    my ( $line ) = @_;
    chomp( $line );

    my ( $date, $time, $int_id, $flag, $other ) = $line =~
    /(\d{4}-\d{2}-\d{1,2}) (\d{1,2}:\d{2}:\d{2}) ([[:alnum:]\$\*]{6}-[[:alnum:]\$\*]{6}-[[:alnum:]\$\*]{2}) (<=|=>|->|\*\*|==)?\s?(.*$)/;

    return unless $date && $time && $int_id;

    my %log;
    my $created = "$date $time";

    if ( defined $flag ) {
        my ( $address ) = $other =~ /([a-zA-Z0-9._-]+@[a-zA-Z0-9._-]+\.[a-zA-Z0-9_-]+)/;
        if ( $flag eq "<=" ) {
            my ( $id ) = $other =~ /(?:.*)\sS=(\d{4})\s/;
            return unless $id;

            $log{ 'message' } = {
                created => $created,
                int_id  => $int_id,
                id      => $id,
                str     => "$int_id $flag $other",
            };
        } # if ...
        else {
            $log{ 'log' } = {
                created => $created,
                int_id  => $int_id,
                address => $address,
                str     => "$int_id $other",
            };
        } # else [ if ...]
    } # if ...
    else {
        $log{ 'log' } = {
            created => $created,
            int_id  => $int_id,
            address => undef,
            str     => "$int_id $other",
        };
    } # else [ if ...]

    return %log;
} # sub parseLine
1;
