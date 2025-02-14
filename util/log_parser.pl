use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Parser;
use DatabaseManager;
use File::Spec;

sub getFileToParse {
    return File::Spec->catfile( $FindBin::Bin, '../data/raw', 'out' );
} # sub getFileToParse

sub readDataFile {
    my ( $file ) = @_;
    return Parser::readFile( $file );
} # sub readDataFile

sub connectToDatabase {
    return DatabaseManager::connectMySQL();
} # sub connectToDatabase

sub saveDataToDb {
    my ( $dbh, $dataLog ) = @_;
    DatabaseManager::saveDataToDB( $dbh, $dataLog );
} # sub saveDataToDb

sub main {
    my $fileToParse = getFileToParse();
    $DB::single=1;
    my $dataLog     = readDataFile( $fileToParse );

    if ( $dataLog ) {
        my $dbh = connectToDatabase();
        saveDataToDb( $dbh, $dataLog ) if $dbh;
    } # if ...
    else {
        warn "Failed to read data from file: $fileToParse\n";
    } # else [ if ...]
} # sub main

main();
