use strict;
use warnings;

use CGI;
use HTML::Template;
use FindBin;
use lib "$FindBin::Bin/../lib";
use DatabaseManager;
use File::Spec;

sub prepare {
    my $cgi = CGI->new;
    print $cgi->header( -charset => 'utf8', -Cache_control => 'no-cache, no-store, must-revalidate' );
    my $template_name = File::Spec->catfile( $FindBin::Bin, '../data/templates', 'page.tmpl' );
    my $template      = HTML::Template->new( filename => $template_name );
    my ( $count, $result ) = searchHandler( $cgi, $template );
    render_template( $template, $count, $result );
} # sub prepare

sub searchHandler {
    my ( $cgi, $template ) = @_;
    my $address = scalar $cgi->param( "address" );
    return unless $address;
    my $dbh = DatabaseManager::connectMySQL();
    my ( $count, $result ) = DatabaseManager::search( $dbh, $address );
    if ( $count ) {
        $template->param(
            ROWS => [ map { CREATED => $_->{ 'created' }, STR => $_->{ 'str' } }, @$result ] );
        $template->param( COUNT => $count ) if $count > 10;
    } # if ...
    $template->param( SHOW_ERROR => 1 ) if $count == 0;

    return ( $count, $result );
} # sub searchHandler

sub render_template {
    my ( $template, $count, $result ) = @_;
    print $template->output();
} # sub render_template

prepare( @ARGV );
