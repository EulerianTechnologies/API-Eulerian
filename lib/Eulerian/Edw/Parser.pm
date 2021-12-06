#/usr/bin/env perl
###############################################################################
#
# @file Parser.pm
#
# @brief Eulerian Data Warehouse REST Parser Module definition.
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
package Eulerian::Edw::Parser;
#
# Enforce compilor rules
#
use strict; use warnings;
#
# @brief
#
# @param $class
# @param $path
# @param $uuid
#
# @return
#
sub new
{
  my ( $class, $path, $uuid ) = @_;
  return bless( {
      _PATH => $path,
      _UUID => $uuid,
    }, $class );
}
#
# @brief
#
# @parm $self -
#
# @return
#
sub uuid
{
  my ( $self, $uuid ) = @_;
  $self->{ _UUID } = $uuid if $uuid;
  return $self->{ _UUID };
}
#
# @brief
#
# @parm $self -
#
# @return
#
sub path
{
  my ( $self, $path ) = @_;
  $self->{ _PATH } = $path if $path;
  return $self->{ _PATH };
}
#
# @brief
#
# @param $self -
# @param $hooks -
#
sub do {}
#
# Endup module properly
#
1;
