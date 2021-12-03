#/usr/bin/env perl
###############################################################################
#
# @file Hooks.pm
#
# @brief Eulerian Data Warehouse Peer Hooks Base class Module definition.
#
# This module is aimed to provide callback hooks userfull to process reply data.
# Library user can create is own Hooks class conforming to this module interface
# to handle reply data in specific manner.
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
package Eulerian::Edw::Hooks;
#
# Enforce compilor rules
#
use strict; use warnings;
#
# @brief Allocate a new Eulerian Data Warehouse Peer Hooks.
#
# @param $class - Eulerian Data Warehouse Peer Hooks Class.
# @param $setup - Setup attributes.
#
# @return Eulerian Data Warehouse Peer Hooks instance.
#
sub new
{
  my ( $class, $setup ) = @_;
  my $self = bless( {}, $class );
  $self->setup( $setup );
  return $self;
}
#
# @brief Setup Eulerian Data Warehouse Peer Hooks.
#
# @param $self - Eulerian Data Warehouse Peer Hooks.
# @param $setup - Setup entries.
#
sub setup
{
  my ( $self, $setup ) = @_;
}
#
# @brief
#
# @param $self - Eulerian Data Warehouse Peer Hooks.
# @param $uuid - UUID of Eulerian Analytics Analysis.
# @param $start - Timerange begin.
# @param $end - Timerange end.
# @param $columns - Array of Columns definitions.
#
# @return  0 - Success.
# @return >0 - Error.
#
sub on_headers
{
  my ( $self, $uuid, $start, $end, $columns ) = @_;
  return 0;
}
#
# @brief
#
# @param $self - Eulerian Data Warehouse Peer Hooks.
# @param $uuid - UUID of Eulerian Analytics Analysis.
# @param $rows - Array of Array of Columns values.
#
# @return  0 - Success.
# @return >0 - Error.
#
sub on_add
{
  my ( $self, $uuid, $rows ) = @_;
  return 0;
}
#
# @brief
#
# @param $self - Eulerian Data Warehouse Peer Hooks.
# @param $uuid - UUID of Eulerian Analytics Analysis.
# @param $rows - Array of Array of Columns values.
#
# @return  0 - Success.
# @return >0 - Error.
#
sub on_replace
{
  my ( $self, $uuid, $rows ) = @_;
  return 0;
}
#
# @brief
#
# @param $self - Eulerian Data Warehouse Peer Hooks.
# @param $uuid - UUID of Eulerian Analytics Analysis.
# @param $progress - Progression value.
#
# @return  0 - Success.
# @return >0 - Error.
#
sub on_progress
{
  my ( $self, $uuid, $progress ) = @_;
  return 0;
}
#
# @brief
#
# @param $self - Eulerian Data Warehouse Peer Hooks.
# @param $uuid - UUID of Eulerian Analytics Analysis.
# @param $token - AES Token or Bearer.
# @param $errnum - Error number.
# @param $err - Error description.
# @param $updated - Count of updates on server.
#
# @return  0 - Success.
# @return >0 - Error.
#
sub on_status
{
  my ( $self, $uuid, $token, $errnum, $err, $updated ) = @_;
  return 0;
}
#
# Endup module properly
#
1;
