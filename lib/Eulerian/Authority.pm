#/usr/bin/env perl
###############################################################################
#
# @file Authority.pm
#
# @brief Eulerian Authority module used to get Eulerian Data Warehouse
#        Access/Session Tokens.
#
# @author Thorillon Xavier:x.thorillon@eulerian.com
#
# @date 25/11/2021
#
# @version 1.0
#
###############################################################################
#
# Setup perl package name
#
package Eulerian::Authority;
#
# Enforce compilor rules
#
use strict; use warnings;
#
# Import Eulerian::Request ( HTTP requests )
#
use Eulerian::Request;
#
# Import Eulerian::Status
#
use Eulerian::Status;
#
# URL domain matching platform names
#
my %DOMAINS = (
  'fr' => 'api.eulerian.com',
  'ca' => 'api.eulerian.ca',
);
#
# URL Application matching Token Kind.
#
my %KINDS = (
  'session' => '/er/account/get_dw_session_token.json?ip=',
  'access'  => '/er/account/get_dw_access_token.json?ip=',
);
#
# @brief Get Eulerian Authority URL used to retrieve Session/Access Token
#        to Eulerian Data Warehouse Platform.
#
# @param $class - Eulerian::Authority Class.
# @param $kind - Eulerian Data Warehouse Token Kind.
# @param $platform - Eulerian Data Warehouse Platform name.
# @param $grid - Eulerian Data Warehouse Site Grid name.
# @param $ip - IP of Eulerian Data Warehouse Peer.
# @param $token - Eulerian Token.
#
# @return Eulerian::Status
#
sub url
{
  my ( $class, $kind, $platform, $grid, $ip, $token ) = @_;
  my $domain;
  #
  # Sanity check mandatories arguments
  #
  if( ! ( defined( $grid ) && length( $grid ) > 0 ) ) {
    return $class->error(
      406, "Mandatory argument 'grid' is missing or invalid"
      );
  } elsif( ! ( defined( $ip ) && length( $ip ) > 0 ) ) {
    return $class->error(
      406, "Mandatory argument 'ip' is missing"
    );
  } elsif( ! ( defined( $token ) && length( $token ) > 0 ) ) {
    return $class->error(
      406, "Mandatory argument 'token' is missing"
    );
  }
  #
  # URL formats are :
  #
  # Start :
  #
  #  https://<grid>.<domain>/ea/v2/<token>/er/account/
  #
  # Session token :
  #
  #   <Start>get_dw_session_token.json?ip=<ip>&output-as-kv=1
  #
  # Access token :
  #
  #   <Start>get_dw_access_token.json?ip=<ip>&output-as-kv=1
  #
  if( ! ( $kind = $KINDS{ $kind } ) ) {
    return $class->error( 406, "Invalid token kind : $kind" );
  } elsif( ! ( $domain = $DOMAINS{ $platform } ) ) {
    return $class->error( 506, "Invalid platform : $platform" );
  } else {
    my $status = Eulerian::Status->new();
    my $url;

    $url  = 'https://';
    $url .= $grid . '.';
    $url .= $domain . '/ea/v2/';
    $url .= $token . $kind;
    $url .= $ip . '&output-as-kv=1';
    $status->{ url } = $url;

    return $status;
  }
}
#
# @brief Get valid HTTP Authorization bearer used to access Eulerian
#        Data Warehouse Platform.
#
# @param $class - Eulerian Authority class.
# @param $kind - Eulerian Authority token kind.
# @param $platform - Eulerian Authority Platform.
# @param $grid - Eulerian Data Warehouse Grid.
# @param $ip - Peer IP.
# @param $token - Eulerian Token.
#
# @return Eulerian::Status
#
use Data::Dumper;
sub bearer
{
  my ( $class, $kind, $platform, $grid, $ip, $token ) = @_;
  my $response;
  my $status;
  my $code;
  my $json;

  # Get URL used to request Eulerian Authority for Token.
  $status = $class->url( $kind, $platform, $grid, $ip, $token );
  # Handle errors
  if( ! $status->error() ) {
    # Request Eulerian Authority
    $status = Eulerian::Request->get( $status->{ url } );
    # Get HTTP response
    $response = $status->{ response };
    # Get HTTP response code
    $code = $response->code;
    # We expect JSON reply data
    $json = Eulerian::Request->json( $response );
    if( $json && ( $code == 200 ) ) {
      $status = $json->{ error } ?
        $class->error( $code, $json->{ error_msg } ) :
        $class->success( $kind, $json );
    } else {
      $status = $class->error(
        $code, $json ?
          encode_json( $json ) :
          $response->decoded_content
        );
    }
  }

  return $status;
}
#
# @brief Return Error on Eulerian Authority Services.
#
# @param $class - Eulerian::Authority class.
# @param $code - HTTP Error code.
# @param $message - Error message.
#
# return Eulerian::Status
#
sub error
{
  my ( $class, $code, $message ) = @_;
  my $status = Eulerian::Status->new();
  my $error = "Request on Eulerian Authority failed.\n";
  $error .= 'Code     : ' . $code . "\n";
  $error .= 'Message  : ' . $message . "\n";
  $status->error( 1 );
  $status->code( $code );
  $status->msg( $error );
  return $status;
}
#
# @brief Return Success on Eulerian Authority Services.
#
# @param $class - Eulerian::Authority class.
# @param $kind - Token kind.
# @param $json - Json reply.
#
# @return Eulerian::Status
#
sub success
{
  my ( $class, $kind, $json ) = @_;
  my $status = Eulerian::Status->new();
  my $row = $json->{ data }->{ rows }->[ 0 ];
  $status->{ bearer } = 'bearer ' . $row->{ $kind . '_token' };
  return $status;
}
#
# End up perl module properly
#
1;
