package DatabaseManager;
use utf8;
use strict;
use warnings;
use DBI;

use FindBin;
use File::Spec;

my $config_file = File::Spec->catfile( $FindBin::Bin, '../conf', 'mysql_connect.conf' );

my $mysql_conf = do( $config_file );
my $database   = 'mail_logs';

sub connectMySQL {
    my $connection = DBI->connect(
        "DBI:mysql:database=$database;host=" . $mysql_conf->{ host },
        $mysql_conf->{ user },
        $mysql_conf->{ password },
        {
            'RaiseError' => 1,
            'PrintError' => 0
        }
    );

    unless ( $connection ) {
        return undef;
    } # unless ...

    $connection->do( "SET NAMES 'utf8'" );
    $connection->ping();
    return $connection;
} # sub connectMySQL

sub quote {
    my ( $dbh_connection, $logs, $sorted_keys ) = @_;
    my @quoted_logs;
    for my $row ( @{ $logs } ) {
        my @quoted_values = map { $dbh_connection->quote( $row->{ $_ } ) } @{ $sorted_keys };
        push( @quoted_logs, sprintf( "( %s )", join( ",", @quoted_values ) ) );
    } # for ...
    my $result = join( ", ", @quoted_logs );
} # sub quote

sub insertData {
    my ( $dbh_connection, $logs, $table, $keys, $on_duplicate ) = @_;
    my $values = quote( $dbh_connection, $logs, $keys );
    my $query  = "INSERT INTO `$table` (`" . join( "`, `", @$keys ) . "`) VALUES $values";
    $query .= " ON DUPLICATE KEY UPDATE $on_duplicate" if $on_duplicate;
    my $result = $dbh_connection->do( $query ) or die $dbh_connection->errstr;
    return $result;
} # sub insertData

sub saveDataToDB {
    my ( $dbh_connection, $data ) = @_;
    my $log_result =
        insertData( $dbh_connection, $data->{ log }, 'log', [ "created", "int_id", "str", "address" ] )
        if $data->{ log };
    my $message_result = insertData(
        $dbh_connection, $data->{ message },
        'message', [ "created", "id", "int_id", "str" ],
        'id=VALUES(id)'
        )
        if $data->{ message };
} # sub saveDataToDB

sub search {
    my ( $dbh, $address ) = @_;
    my $exact_match = $address;
    my $like_match  = '%' . $address . '%';

    my $result_query = "
        SELECT
            `created`, `str`
        FROM (
            SELECT `created`, `int_id`, `str`
            FROM `log`
            WHERE `address` = ?
            
            UNION
            
            SELECT `created`, `int_id`, `str`
            FROM `message`
            WHERE `str` LIKE ?
        ) AS `a`
        ORDER BY `int_id`, `created`
    ";

    my $result = $dbh->selectall_arrayref( $result_query, { Slice => {} }, $exact_match, $like_match );

    my $result_limited = @$result > 100 ? [ @$result[ 0 .. 99 ] ] : $result;

    return scalar @$result, $result_limited;
} # sub search

1;
