#/usr/bin/env perl
###############################################################################
#
# @file Request.pm
#
# @brief Eulerian Request module used to send HTTP request to remote Peer.
#
# @author Thorillon Xavier:x.thorillon@eulerian.com
#
# @date 26/11/2021
#
# @version 1.0
#
###############################################################################
#
# Setup module name.
#
package Eulerian::Request;
#
# Enforce compilor rules
#
use strict; use warnings;
#
# Import Eulerian::Status
#
use Eulerian::Status;
#
# Import HTTP::Headers
#
use HTTP::Headers;
#
# Import HTTP::Request
#
use HTTP::Request;
#
# Import LWP::UserAgent
#
use LWP::UserAgent;
#
# Import IO::Socket::SSL
#
use IO::Socket::SSL;
#
# Import HTTP::Status
#
use HTTP::Status qw( :constants :is status_message );
#
# Import JSON
#
use JSON;
#
# Import Encode
#
use Encode;
#
# @brief Create new HTTP Headers.
#
# @param $class - Eulerian::HTTP class.
#
# @return HTTP Headers.
#
sub headers
{
  return HTTP::Headers->new();
}
#
# @brief Test if the content type of given HTTP response is a
#        JSON format.
#
# @param $class - Eulerian::Request Class.
# @param $response - HTTP response.
#
# @return 1 - Content type is JSON.
# @return 0 - Content type isnt JSON.
#
sub is_json
{
  my ( $class, $response ) = @_;
  my $type;

  # Get content type value from HTTP response
  $type = $response->header( 'content-type' );
  if( defined( $type ) ) {
    # Split content type into an array.
    my @subtypes = split( '; ', $type );
    # Iterate on subtypes entries
    foreach my $subtype ( @subtypes ) {
      # Test if subtype is JSON format
      if( $subtype eq 'application/json' ) {
        return 1;
      }
    }
  }

  return 0;
}
#
# @brief Get JSON object from HTTP response.
#
# @param $class - Eulerian::Request class.
# @param $response - HTTP response.
#
# @return JSON object.
#
sub json
{
  my ( $class, $response ) = @_;
  my $data = undef;

  if( $class->is_json( $response ) ) {
    $data = $response->decoded_content;
    if( defined( $data ) ) {
      chomp( $data );
      $data = encode( 'utf-8', $data );
      $data = decode_json( $data );
    }
  }

  return $data;
}
#
# @brief Send HTTP request on given url.
#
# @param $class - Eulerian Request class.
# @param $method - HTTP method.
# @param $url - Remote URL.
# @param $headers - HTTP headers.
# @param $what - Data of POST request.
# @param $type - Data type of POST request
# @param $file - Local file path used to store HTTP reply.
#
# @return Eulerian::Status instance.
#
sub request
{
  my ( $class, $method, $url, $headers, $what, $type, $file ) = @_;
  my $status = Eulerian::Status->new();
  my $endpoint;
  my $request;

  # Ensure default type
  $type = $type || 'application/json';

  # Sanity check POST arguments
  if( $method eq 'POST' ) {
    if( ! ( defined( $what ) && defined( $type ) ) ) {
      $status->error( 1 );
      $status->msg( "Mandatory argument to post request is/are missing" );
      $status->code( 400 );
      return $status;
    } else {
      # Setup Content_Length and Content_Type
      $headers->push_header( Content_Length => length( $what ) );
      $headers->push_header( Content_Type => $type );
    }
  }

  # Create HTTP Request
  $request = HTTP::Request->new( $method, $url, $headers, $what );

  # Create End Point used to communicate with remote server
  $endpoint = LWP::UserAgent->new(
    keep_alive => 0,
    cookie_jar => {},
    ssl_opts   => {
      SSL_verifycn_publicsuffix => '',
      SSL_verify_mode           => IO::Socket::SSL::SSL_VERIFY_NONE,
      verify_hostname           => 0,
      SSL_hostname              => '',
    },
  );

  # Send Request, wait response if file is defined reply content is
  # writen into local file.
  my $response = $endpoint->request( $request, $file );
  my $json = Eulerian::Request->json( $response );

  if( $response->code != HTTP_OK ) {
    $status->error( 1 );
    $status->code( $response->code );
    $status->msg(
      defined( $json ) ?
        encode_json( $json ) : $response->content()
      );
  } else {
    $status->{ response } = $response;
  }

  return $status;
}
#
# @brief Do HTTP Get on given URL.
#
# @param $class - Eulerian::HTTP class.
# @param $url - Remote URL.
# @param $headers - HTTP::Headers.
# @param $file - Local file path.
#
# @return Eulerian::Status instance.
#
sub get
{
  my ( $class, $url, $headers, $file ) = @_;
  return request( $class, 'GET', $url, $headers, undef, undef, $file );
}
#
# @brief Do HTTP Post on given URL.
#
# @param $class - Eulerian::HTTP class.
# @param $url - Remote URL.
# @param $headers - HTTP::Headers.
# @param $what - Request Data.
# @param $type - Request Data Type.
#
# @return Eulerian::Status instance.
#
sub post
{
  my ( $class, $url, $headers, $what, $type ) = @_;
  return request( $class, 'POST', $url, $headers, $what, $type );
}
#
# End up module properly
#
1;

__END__

=pod

=head1  NAME

Eulerian::Request - Eulerian Request module.

=head1 DESCRIPTION

This module is used to send HTTP request to remote Peer.

=head1 METHODS

=head2 headers :

I<Create a new HTTP::Headers instance>

=head3 output

=over 4

=item * Instance of an HTTP::Headers.

=back

=head2 is_json :

I<Test if given HTTP response content is a JSON format>

=head3 input

=over 4

=item * HTTP response.

=back

=head3 output

=over 4

=item * 1 - HTTP response content is in JSON format.

=item * 0 - HTTP response content isnt in JSON format.

=back

=head2 json :

I<Get JSON message from HTTP response>

=head3 input

=over 4

=item * HTTP response.

=back

=head3 output

=over 4

=item * JSON message.

=back

=head2 request :

I<Send HTTP request on given url.>

=head3 input

=over 4

=item * method : HTTP method. ( ie: POST, GET ).

=item * url : Remote url.

=item * headers : HTTP headers.

=item * what : Content of POST request.

=item * type : Content type of POST request.

=item * file : Local file path used to store HTTP reply.

=back

=head3 output

=over 4

=item * Eulerian::Status. On success a new entry named 'response' is inserted into the status.

=back

=head2 get :

I<Send HTTP GET request on given url>

=head3 input

=over 4

=item * url : Remote url.

=item * headers : HTTP headers.

=item * file : Local file path used to store HTTP reply.

=back

=head3 output

=over 4

=item * Eulerian::Status. On success a new entry named 'response' is inserted into the status.

=back

=head2 post :

I<Send HTTP POST request on given url>

=head3 input

=over 4

=item * url : Remote url.

=item * headers : HTTP headers.

=item * what : Content of POST request.

=item * type : Content type of POST request.

=back

=head3 output

=over 4

=item * Eulerian::Status. On success a new entry named 'response' is inserted into the status.

=back

=cut

