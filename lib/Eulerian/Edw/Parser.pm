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
#
# @return
#
sub new
{
  my ( $class, $path ) = @_;
  return bless(
    { _PATH => $path, }, $class
    );
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
