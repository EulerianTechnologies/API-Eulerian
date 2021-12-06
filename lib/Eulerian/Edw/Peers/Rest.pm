#/usr/bin/env perl
###############################################################################
#
# @file Rest.pm
#
# @brief Eulerian Data Warehouse REST Peer Module definition.
#
#  This module is aimed to provide access to Eulerian Data Warehouse
#  Analytics Analysis Through REST Protocol.
#
# @author Thorillon Xavier:x.thorillon@eulerian.com
#
# @date 26/11/2021
#
# @version 1.0
#
###############################################################################
#
# Setup module name
#
package Eulerian::Edw::Peers::Rest;
#
# Enforce compilor rules
#
use strict; use warnings;
#
# Inherited interface from Eulerian::Edw::Peer
#
use parent 'Eulerian::Edw::Peer';
#
# Import Eulerian::Authority
#
use Eulerian::Authority;
#
# Import Eulerian::File
#
use Eulerian::File;
#
# Import Eulerian::Edw::Parsers::Json
#
use Eulerian::Edw::Parsers::Json;
#
# Import Eulerian::Edw::Parsers::Csv
#
use Eulerian::Edw::Parsers::Csv;
#
# Import Hostname
#
use Sys::Hostname;
#
# Import strftime()
#
use POSIX 'strftime';
#
# Import encode_json()
#
use JSON 'encode_json';
#
# Defines Parser class name matching format.
#
my %PARSERS = (
  'json' => 'Eulerian::Edw::Parsers::Json',
  'csv'  => 'Eulerian::Edw::Parsers::Csv',
);
#
# @brief Allocate and initialize a new Eulerian Data Warehouse Rest Peer.
#
# @param $class - Eulerian Data Warehouse Rest Peer class.
# @param $setup - Setup attributes.
#
# @return Eulerian Data Warehouse Peer.
#
sub new
{
  my ( $class, $setup ) = @_;
  my $self;

  # Call base instance constructor
  $self = $class->SUPER::create( 'Eulerian::Edw::Peers::Rest' );

  # Setup Rest Peer Default attributes values
  $self->{ _ACCEPT } = 'application/json';
  $self->{ _ENCODING } = 'gzip';
  $self->{ _WDIR } = '.';
  $self->{ _UUID } = 0;

  # Setup Rest Peer Attributes
  $self->setup( $setup );

  return $self;
}
#
# @brief UUID attribute accessors.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $uuid - Request UUID.
#
# @return UUID.
#
sub uuid
{
  my ( $self, $uuid ) = @_;
  $self->{ _UUID } = $uuid if defined( $uuid );
  return $self->{ _UUID };
}
#
# @brief Encoding attribute accessors.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $encoding - Encoding.
#
# @return Encoding.
#
sub encoding
{
  my ( $self, $encoding ) = @_;
  $self->{ _ENCODING } = $encoding if defined( $encoding );
  return $self->{ _ENCODING };
}
#
# @brief Accept attribute accessors.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $accept - Accept.
#
# @return Accept.
#
sub accept
{
  my ( $self, $accept ) = @_;
  $self->{ _ACCEPT } = $accept if defined( $accept );
  return $self->{ _ACCEPT };
}
#
# @brief Working directory attribute accessors.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $wdir - Working directory.
#
# @return Working Directory.
#
sub wdir
{
  my ( $self, $wdir ) = @_;
  $self->{ _WDIR } = $wdir if defined( $wdir );
  return $self->{ _WDIR };
}
#
# @brief Setup Eulerian Data Warehouse Peer.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $setup - Setup entries.
#
sub setup
{
  my ( $self, $setup ) = @_;

  # Setup base interface values
  $self->SUPER::setup( $setup );

  # Setup Rest specifics options
  $self->accept( $setup->{ accept } ) if exists( $setup->{ accept } );
  $self->encoding( $setup->{ encoding } ) if exists( $setup->{ encoding } );
  $self->wdir( $setup->{ wdir } ) if exists( $setup->{ wdir } );

}
#
# @brief Dump Eulerian Data Warehouse Peer setup.
#
# @param $self - Eulerian Data Warehouse Peer.
#
sub dump
{
  my $self = shift;
  my $dump = '';
  $self->SUPER::dump();
  $dump .= 'Accept   : ' . $self->accept() . "\n";
  $dump .= 'Encoding : ' . $self->encoding() . "\n";
  $dump .= 'WorkDir  : ' . $self->wdir() . "\n\n";
  print( $dump );
}
#
# @brief Get remote URL to Eulerian Data Warehouse Platform.
#
# @param $self - Eulerian Data Warehouse Peer.
#
# @return Remote URL to Eulerian Data Warehouse Platform.
#
sub url
{
  my $self = shift;
  my $platform;
  my $host;
  my $url;

  $url = $self->secure() ? 'https://' : 'http://';
  $platform = $self->platform();
  $host = $self->host();
  if( $host ) {
    $url .= $host . ':';
    $url .= $self->ports()->[ $self->secure() ];
  } elsif( $platform eq 'fr' ) {
    $url .= 'edw.ea.eulerian.com';
  } elsif( $platform eq 'ca' ) {
    $url .= 'edw.ea.eulerian.ca';
  } else {
    $url = undef;
  }

  return $url;
}
#
# @brief Get HTTP Request Body used to send command to Eulerian Data Warehouse
#        Platform.
#
# @param $self - Eulerian Data Warehouse Rest Peer.
# @param $command - Eulerian Data Warehouse Command.
#
# @return HTTP Request Body.
#
sub body
{
  my ( $self, $command ) = @_;
  my %body = (
    kind => 'edw#request',
    query => $command,
    creationTime => strftime( '%d/%m/%Y %H:%M:%S', gmtime() ),
    location => hostname(),
    expiration => undef,
  );
  return encode_json( \%body );
};
#
# @brief Setup HTTP Request Headers.
#
# @param $self - Eulerian Data Warehouse Peer.
#
# @return HTTP Headers.
#
sub headers
{
  my $self = shift;
  my $rc = $self->SUPER::headers();
  my $headers;

  $headers = $rc->{ headers } if ! $rc->{ error };
  $headers->push_header( 'Content-Type', 'application/json' );
  $headers->push_header( 'Accept', $self->accept() );
  $headers->push_header( 'Accept-Encoding', $self->encoding() );

  return $rc;
}
#
# @brief Create a new JOB on Eulerian Data Warehouse Rest Platform.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $command - Eulerian Data Warehouse Command.
#
# @return Reply content.
#
use Data::Dumper;
sub create
{
  my ( $self, $command ) = @_;
  my $response;
  my $rc;

  $rc = $self->headers();
  if( ! $rc->{ error } ) {
    my $url = $self->url() . '/edw/jobs';
    $response = Eulerian::Request->post(
      $url, $rc->{ headers }, $self->body( $command )
      );
    $rc = Eulerian::Request->reply( $response );
    if( ! $rc->{ error } ) {
      my $json = Eulerian::Request->json( $response );
      $self->uuid( $json->{ data }->[ 0 ] );
    }
  }

  return $rc;
}
#
# @brief Get Eulerian Data Warehouse Job Status.
#
# @param $self - Eulerian Data Warehouse Rest Peer.
# @param $reply - Eulerian Data Warehouse Platform Reply.
#
# @return Job Reply status.
#
sub status
{
  my ( $self, $rc ) = @_;
  my $response = $rc->{ response };
  my $url = Eulerian::Request->json(
    $response )->{ data }->[ 1 ];

  $rc = $self->headers();
  if( ! $rc->{ error } ) {
    $response = Eulerian::Request->get(
      $url, $rc->{ headers }
      );
    $rc = Eulerian::Request->reply( $response );
  }

  return $rc;
}
#
# @brief Test if Job status is 'Running';
#
# @param $self - Eulerian::Edw::Peers::Rest instance.
# @param $rc - Return context.
#
# @return 0 - Not running.
# @return 1 - Running.
#
sub running
{
  my ( $self, $rc ) = @_;
  return Eulerian::Request->json(
    $rc->{ response }
    )->{ status } eq 'Running';
}
#
# @brief Test if Job status is 'Done'.
#
# @param $self - Eulerian::Edw::Peers::Rest instance.
# @param $rc - Return context.
#
# @return 0 - Not Done.
# @return 1 - Done.
#
sub done
{
  my ( $self, $rc ) = @_;
  return ! $rc->{ error } ?
    Eulerian::Request->json(
      $rc->{ response }
      )->{ status } eq 'Done' :
      0;
}
#
# @brief Get Path to local filepath.
#
# @param $self - Eulerian::Edw::Peers::Rest instance.
#
# @return Local file path.
#
sub path
{
  my ( $self, $response ) = @_;
  my $encoding = $self->encoding();
  my $json = Eulerian::Request->json( $response );
  my $pattern = '([0-9]*)\.(json|csv|parquet)';
  my $url = $json->{ data }->[ 1 ];
  my $wdir = $self->wdir();
  my %rc = ();

  if( ! $wdir ) {
    %rc = (
      error => 1,
      error_code => 400,
      error_msg => "Working directory isn't set"
      );
  } elsif( ! Eulerian::File->writable( $wdir ) ) {
    %rc = (
      error => 1,
      error_code => 401,
      error_msg => "Working directory isn't writable"
      );
  } elsif( ! ( $url =~ m/$pattern/ ) ) {
    %rc = (
      error => 1,
      error_code => 400,
      error_msg => 'Unknown local file name',
      );
  } else {
    my $path = $wdir. '/' . "$1.$2";
    $path .= '.gz' if $encoding eq 'gzip';
    %rc = (
      error => 0,
      url => $url,
      path => $path,
    );
  }

  return \%rc;
}
#
# @brief Unzip given file.
#
# @param $self - Eulerian::Edw::Peers::Rest instance.
# @param $zipped - Path to zipped file.
#
# @return Path to unzipped file.
#
sub unzip
{
  my( $self, $zipped ) = @_;
  my $unzipped;

  # Parse zipped file
  $zipped =~ /(.*)\.gz/;

  # Unzipped file name
  $unzipped = $1;

  # Gunzip zipped file into unzipped file
  IO::Uncompress::Gunzip::gunzip(
    $zipped, $unzipped, BinModeOut => 1
    );

  # Remove zipped file
  unlink $zipped;

  # Return path to unzipped file
  return $unzipped;
}
#
# @brief Download Job reply file.
#
# @param $self - Eulerian Data Warehouse Rest Peer.
# @param $rc - Reply context.
#
# @return Reply context
#
sub download
{
  my ( $self, $rc ) = @_;

  # From Last status message compute local file path
  $rc = $self->path( $rc->{ response } );

  # If no error
  if( ! $rc->{ error } ) {
    my $path = $rc->{ path };
    my $url = $rc->{ url };
    my $response;

    # Get HTTP request headers
    $rc = $self->headers();

    if( ! $rc->{ error } ) {
      # Send Download request to remote host, reply is
      # writen into $path file
      $response = Eulerian::Request->get(
        $url, $rc->{ headers }, $path
        );
      $rc = Eulerian::Request->reply( $response );
      # Handle errors
      if( ! $rc->{ error } ) {
        $rc->{ path } = $self->encoding() eq 'gzip' ?
          $self->unzip( $path ) : $path;
      }
    }

  }

  return $rc;
}
#
# @brief Parse local file path and invoke hooks handlers.
#
# @param $self - Eulerian::Edw::Peers::Rest instance.
# @param $rc - Reply context.
#
# @return Reply context.
#
sub parse
{
  my $pattern = '[0-9]*\.(json|csv|parquet)';
  my ( $self, $rc ) = @_;
  my $path = $rc->{ path };
  my $parser;
  my $name;
  my %rc;

  # Parse file path, get file type
  if( ( $path =~ m/$pattern/ ) ) {
    # Lookup for parser matching file type
    if( ( $name = $PARSERS{ $1 } ) ) {
      # Create new instance of Parser
      if( ( $parser = $name->new( $path, $self->uuid() ) ) ) {
        # Parse reply file raise callback hooks
        $parser->do( $self->hooks() );
        # Return success
        %rc = ( error => 0 );
      } else {
        %rc = (
          error => 1,
          error_msg => 'Failed to create Parser',
          error_code => 401,
        );
      }
    } else {
      # Unknown file type
      %rc = (
        error => 1,
        error_msg => 'Not yet implemented file format',
        error_code => 501,
      );
    }
  } else {
    # Unparsable file name
    %rc = (
      error => 1,
      error_msg => 'Unknown file format',
      error_code => 401,
    );
  }

  return \%rc;
}
#
# @brief Do Request on Eulerian Data Warehouse Platform.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $command - Eulerian Data Warehouse Command.
#
sub request
{
  my ( $self, $command ) = @_;
  my $response;
  my $json;
  my $rc;

  # Create Job on Eulerian Data Warehouse Platform
  $rc = $self->create( $command );

  # Wait end of Job
  while( ! $rc->{ error } && $self->running( $rc ) ) {
    $rc = $self->status( $rc );
  }

  # If Done, download reply file
  if( $self->done( $rc ) ) {
    $rc = $self->download( $rc );
    if( ! $rc->{ error } ) {
      # Parse reply file, call hooks
      $rc = $self->parse( $rc );
    }
  }

  return $rc;
}
#
# @brief Cancel Job on Eulerian Data Warehouse Platform.
#
# @param $self - Eulerian::Edw::Peers::Rest instance.
# @param $rc - Reply context.
#
sub cancel
{
  my ( $self ) = @_;
  my $rc;

  # Get HTTP request headers
  $rc = $self->headers();
  if( ! $rc->{ error } ) {
    my $headers = $rc->{ headers };

    delete $rc->{ headers };
    # Create cancel job url
    if( ! $self->uuid() ) {
      $rc->{ error } = 1;
      $rc->{ error_msg } = 'Failed to cancel Job. Unknown UUID';
      $rc->{ error_code } = 404;
    } else {
      my $url = $self->url() . '/edw/jobs/';
      my $response;

      $url .= $self->uuid() . '/cancel';
      # Send Cancel request to remote host
      $response = Eulerian::Request->get( $url, $headers );
      $rc = Eulerian::Request->reply( $response );

    }
  }

  return $rc;
}
#
# End Up module properly
#
1;
