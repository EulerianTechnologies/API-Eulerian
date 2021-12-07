#/usr/bin/env perl
###############################################################################
#
# @file Peer.pm
#
# @brief Eulerian Data Warehouse Peer Base class Module definition.
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
package Eulerian::Edw::Peer;
#
# Enforce compilor rules
#
use strict; use warnings;
#
# Import Eulerian::Edw::Peers::Rest
#
use Eulerian::Edw::Peers::Rest;
#
# Import Eulerian::Edw::Peers::Thin
#
use Eulerian::Edw::Peers::Thin;
#
# Import Eulerian::Status
#
use Eulerian::Status;
#
# @brief Allocate a new Eulerian Data Warehouse Peer.
#
# @param $class - Eulerian Data Warehouse Peer Class.
# @param $setup - Setup attributes.
#
# @return Eulerian Data Warehouse Peer instance.
#
sub new
{
  my ( $class, $setup ) = @_;
  $class = $setup->{ class };
  return $class->new( $setup );
}
#
# @brief Create a new Eulerian Data Warehouse Peer instance.
#
# @param $class - Eulerian Data Warehouse Peer class.
# @param $name - Eulerian Data Warehouse Peer class name.
#
# @return New Eulerian Data Warehouse Peer Instance.
#
sub create
{
  my $class = shift;
  my $self = bless ( {
    _CLASS => shift,
    _KIND => 'access',
    _PLATFORM => 'fr',
    _HOOKS => undef,
    _TOKEN => undef,
    _GRID => undef,
    _HOST => undef,
    _PORTS => [ 80, 443 ],
    _SECURE => 1,
    _IP => undef,
  }, $class );
  return $self;
}
#
# @brief Class attribute getter.
#
# @param $self - Eulerian Data Warehouse Peer.
#
# @return Eulerian Data Warehouse Peer Class name.
#
sub class
{
  return shift->{ _CLASS };
}
# @brief Token Kind attribute accessors.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $kind - Token kind.
#
# @return Token Kind.
#
sub kind
{
  my ( $self, $kind ) = @_;
  $self->{ _KIND } = $kind if defined( $kind );
  return $self->{ _KIND };
}
#
# @brief Host attribute accessors.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $host - Eulerian Data Warehouse Host name.
#
# @return Eulerian Data Warehouse Host Name.
#
sub host
{
  my ( $self, $host ) = @_;
  $self->{ _HOST } = $host if defined( $host );
  return $self->{ _HOST };
}
#
# @brief Ports attribute accessors.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $ports - Eulerian Data Warehouse Host Ports.
#
# @return Eulerian Data Warehouse Host Ports.
#
sub ports
{
  my ( $self, $ports ) = @_;
  $self->{ _PORTS } = $ports if defined( $ports );
  return $self->{ _PORTS };
}
#
# @brief Platform attribute accessors.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $platform - Eulerian Data Warehouse Platform.
#
# @return Eulerian Data Warehouse Platform.
#
sub platform
{
  my ( $self, $platform ) = @_;
  $self->{ _PLATFORM } = $platform if defined( $platform );
  return $self->{ _PLATFORM };
}
#
# @brief Hooks attribute accessors.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $hooks - Eulerian Data Warehouse Peer Hooks.
#
# @return Eulerian Data Warehouse Peer Hooks.
#
sub hooks
{
  my ( $self, $hooks ) = @_;
  $self->{ _HOOKS } = $hooks if defined( $hooks );
  return $self->{ _HOOKS };
}
#
# @brief Grid attribute accessors.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $grid - Eulerian Data Warehouse Grid.
#
# @return Eulerian Data Warehouse Grid.
#
sub grid
{
  my ( $self, $grid ) = @_;
  $self->{ _GRID } = $grid if defined( $grid );
  return $self->{ _GRID };
}
#
# @brief Secure attribute accessors.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $secure - Secure mode flag.
#
# @return Secure mode flag.
#
sub secure
{
  my ( $self, $secure ) = @_;
  $self->{ _SECURE } = $secure if defined( $secure );
  return $self->{ _SECURE };
}
#
# @brief IP attribute accessors.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $ip - Eulerian Data Warehouse Peer IP.
#
# @return Secure mode flag.
#
sub ip
{
  my ( $self, $ip ) = @_;
  $self->{ _IP } = $ip if defined( $ip );
  return $self->{ _IP };
}
#
# @brief Token attribute accessors.
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $token - Eulerian Token.
#
# @return Eulerian Token.
#
sub token
{
  my ( $self, $token ) = @_;
  $self->{ _TOKEN } = $token if defined( $token );
  return $self->{ _TOKEN };
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

  $self->kind( $setup->{ kind } ) if exists( $setup->{ kind } );
  $self->platform( $setup->{ platform } ) if exists( $setup->{ platform } );
  $self->hooks( $setup->{ hooks } ) if exists( $setup->{ hooks } );
  $self->secure( $setup->{ secure } ) if exists( $setup->{ secure } );
  $self->token( $setup->{ token } ) if exists( $setup->{ token } );
  $self->grid( $setup->{ grid } ) if exists( $setup->{ grid } );
  $self->ip( $setup->{ ip } ) if exists( $setup->{ ip } );
  $self->host( $setup->{ host } ) if exists( $setup->{ host } );
  $self->ports( $setup->{ ports } ) if exists( $setup->{ ports } );
  $self->dump();

}
#
# @brief Dump Eulerian Data Warehouse Peer settings.
#
# @param $self - Eulerian Data Warehouse Peer.
#
sub dump
{
  my ( $self ) = @_;
  my $hooks = $self->hooks() ? 'Set' : 'Unset';
  my $secure = $self->secure() ? 'True' : 'False';
  my $ports = $self->ports();
  my $dump = "\n";

  $ports = $ports ? $ports->[ 0 ] . ',' . $ports->[ 1 ] : undef;
  $dump .= 'Host     : ' . $self->host() . "\n" if $self->host();
  $dump .= 'Ports    : ' . $ports . "\n" if $ports;
  $dump .= 'Class    : ' . $self->class() . "\n";
  $dump .= 'Kind     : ' . $self->kind() . "\n";
  $dump .= 'Platform : ' . $self->platform() . "\n";
  $dump .= 'Hooks    : ' . $hooks . "\n";
  $dump .= 'Token    : ' . $self->token() . "\n";
  $dump .= 'Grid     : ' . $self->grid() . "\n";
  $dump .= 'Secure   : ' . $secure . "\n";
  $dump .= 'Ip       : ' . $self->ip() . "\n";

  print( $dump );

}
#
# @brief Get Authorization bearer value from Eulerian Authority Services.
#
# @param $self - Eulerian Data Warehouse Peer.
#
# @return Authorization Bearer.
#
use Data::Dumper;
sub bearer
{
  my $self = shift;
  my $bearer = $self->{ _BEARER };
  my $status;

  if( ! defined( $bearer ) ) {
    # Request Authority Services for a valid bearer
    $status = Eulerian::Authority->bearer(
      $self->kind(), $self->platform(),
      $self->grid(), $self->ip(),
      $self->token()
      );
    # Cache bearer value for next use
    $self->{ _BEARER } = $status->{ bearer } if ! $status->error();
  } else {
    # Return Cached bearer value
    $status = Eulerian::Status->new();
    $status->{ bearer } = $bearer;
  }

  return $status;
}
#
#
# @brief Default HTTP Request Headers.
#
# @param $self - Eulerian Data Warehouse Peer.
#
# @return HTTP Headers.
#
sub headers
{
  my $self = shift;
  my $status = $self->bearer();
  my $headers;

  if( ! $status->error() ) {
    # Create a new Object Headers
    $headers = Eulerian::Request->headers();
    # Setup Authorization Header value
    $headers->push_header( 'Authorization', $status->{ bearer } );
    # Setup reply context
    $status->{ headers } = $headers;
    # Remove bearer
    delete $status->{ bearer };
  }

  return $status;
}
#
# @brief
#
# @param $self - Eulerian Data Warehouse Peer.
# @param $command - Eulerian Data Warehouse Command.
#
sub request
{
}
#
# @brief
#
# @param $self - Eulerian Data Warehouse Peer.
#
sub cancel
{
}
#
# Endup module properly
#
1;

__END__

=pod

=head1  NAME

Eulerian::Edw::Peer - Eulerian Data Warehouse Peer module.

=head1 DESCRIPTION

This module is the base interface of an Eulerian Data Warehouse Peer.

=head1 METHODS

=head2 new()

I<Allocate and initialize a new Eulerian::Edw::Peer instance.>

=head3 input

=over 4

=item * setup - Hash Perl of initialization parameters

o class : Eulerian Data Warehouse Peer class name.

o kind : Eulerian Authority token kind.

o platform : Eulerian Authority platform.

o hooks : Eulerian::Edw::Hooks instance.

o token : Eulerian customer token.

o grid : Eulerian customer Grid.

o ip : Eulerian customer IP.

=back

=head3 output

=over 4

=item * Instance of an Eulerian::Edw::Peer.

=back

=head2 create()

I<Create a new Eulerian Data Warehouse Peer instance.>

=head3 input

=over 4

=item * name - Eulerian Data Warehouse Peer class name.

=back

=head3 output

=over 4

=item * Eulerian Data Warehouse Peer instance.

=back

=head2 class()

I<Get Eulerian Data Warehouse Peer class name.>

=head3 output

=over 4

=item * Eulerian Data Warehouse Peer class name.

=back

=head2 kind()

I<Get/Set Eulerian Authority token kind.>

=head3 input

=over 4

=item * kind - Eulerian Authority token kind

=back

=head3 output

=over 4

=item * Eulerian Authority token kind.

=back

=head2 platform()

I<Get/Set Eulerian Authority platform.>

=head3 input

=over 4

=item * kind - Eulerian Authority platform.

=back

=head3 output

=over 4

=item * Eulerian Authority platform.

=back

=head2 hooks()

I<Get/Set Eulerian Data Warehouse Peer Hooks.>

=head3 input

=over 4

=item * kind - Eulerian Data Warehouse Peer Hooks.

=back

=head3 output

=over 4

=item * Eulerian Data Warehouse Peer Hooks.

=back

=head2 grid()

I<Get/Set Eulerian Custormer Grid.>

=head3 input

=over 4

=item * kind - Eulerian Customer Grid.

=back

=head3 output

=over 4

=item * Eulerian Custormer Grid.

=back

=head2 ip()

I<Get/Set Eulerian Customer IP.>

=head3 input

=over 4

=item * kind - Eulerian Customer IP.

=back

=head3 output

=over 4

=item * Eulerian Customer IP.

=back

=head2 token()

I<Get/Set Eulerian Customer token.>

=head3 input

=over 4

=item * kind - Eulerian Customer token.

=back

=head3 output

=over 4

=item * Eulerian Customer token.

=back

=head2 setup()

I<Setup Eulerian Data Warehouse Peer.>

=head3 input

=over 4

=item * setup - Perl Hash of peer parameters.

o class : Eulerian Data Warehouse Peer class name.

o kind : Eulerian Authority token kind.

o platform : Eulerian Authority platform.

o hooks : Eulerian::Edw::Hooks instance.

o token : Eulerian customer token.

o grid : Eulerian customer Grid.

o ip : Eulerian customer IP.

=back

=head1 AUTHOR

Xavier Thorillon <x.thorillon@eulerian.com>

=head1 COPYRIGHT

Copyright (c) 2008 Eulerian Technologies Ltd L<http://www.eulerian.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

=cut
