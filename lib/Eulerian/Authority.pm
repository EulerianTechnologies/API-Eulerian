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
# @return URL.
#
sub url
{
  my ( $class, $kind, $platform, $grid, $ip, $token ) = @_;
  my $domain = $DOMAINS{ $platform };
  my $url = undef;
  my %rc;
  #
  # Sanity check mandatories arguments
  #
  if( ! defined( $grid ) ) {
    return $class->error(
      406, "Mandatory argument 'grid' is missing"
      );
  } elsif( ! defined( $ip ) ) {
    return $class->error(
      406, "Mandatory argument 'ip' is missing"
    );
  } elsif( ! defined( $token ) ) {
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
    $url  = 'https://';
    $url .= $grid . '.';
    $url .= $domain . '/ea/v2/';
    $url .= $token . $kind;
    $url .= $ip . '&output-as-kv=1';
    %rc = (
      error => 0,
      url => $url,
    );
  }
  return %rc;
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
# @return Bearer token.
#
sub bearer
{
  my ( $class, $kind, $platform, $grid, $ip, $token ) = @_;
  my $code = 400;
  my $json;
  my %rc;

  # Get URL used to request Eulerian Authority for Token.
  %rc = $class->url( $kind, $platform, $grid, $ip, $token );
  # Handle errors
  if( ! $rc{ error } ) {
    # Request Eulerian Authority
    my $response = Eulerian::Request->get( $rc{ url } );
    # Get HTTP response code
    $code = $response->code;
    # We expect JSON reply data
    $json = Eulerian::Request->json( $response );
    if( $json && ( $code == 200 ) ) {
      %rc = $json->{ error } ?
        $class->error( $code, $json->{ error_msg } ) :
        $class->success( $kind, $json );
    } else {
      %rc = $class->error(
        $code, $json ?
          encode_json( $json ) :
          $response->decoded_content
        );
    }
  }

  return \%rc;
}
#
# @brief Return Error on Eulerian Authority Services.
#
# @param $class - Eulerian::Authority class.
# @param $code - HTTP Error code.
# @param $message - Error message.
#
# return Hash( error, error_code, error_msg )
#
sub error
{
  my ( $class, $code, $message ) = @_;
  my $error = "Request on Eulerian Authority failed.\n";
  $error .= 'Code     : ' . $code . "\n";
  $error .= 'Message  : ' . $message . "\n";
  return (
    error => 1,
    error_code => $code,
    error_msg => $error
    );
}
#
# @brief Return Success on Eulerian Authority Services.
#
# @param $class - Eulerian::Authority class.
# @param $kind - Token kind.
# @param $json - Json reply.
#
# @return Hash( error, bearer )
#
sub success
{
  my ( $class, $kind, $json ) = @_;
  my $data = $json->{ data };
  my $rows = $data->{ rows };
  my $row  = $rows->[ 0 ];
  return (
    error => 0,
    bearer => 'bearer ' . $row->{ $kind . '_token' }
    );
}
#
# End up perl module properly
#
1;
