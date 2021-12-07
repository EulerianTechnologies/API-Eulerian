#/usr/bin/env perl
###############################################################################
#
# @file Print.pm
#
# @brief Eulerian Data Warehouse Peer Print Hooks class Module definition.
#
# This module is aimed to print Eulerian Data Warehouse Analytics Results into
# the terminal.
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
package Eulerian::Edw::Hooks::Print;
#
# Enforce compilor rules
#
use strict; use warnings;
#
# Inherited interface from Eulerian::Edw::Hooks
#
use parent 'Eulerian::Edw::Hooks';
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
  return $class->SUPER::new( $setup );
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
# @brief Start a new Analysis.
#
# @param $self - Eulerian Data Warehouse Peer Hooks.
# @param $uuid - UUID of Eulerian Analytics Analysis.
# @param $start - Timerange begin.
# @param $end - Timerange end.
# @param $columns - Array of Columns definitions.
#
sub on_headers
{
  my ( $self, $uuid, $start, $end, $columns ) = @_;
  my $string = <<string_end;
  {
    . UUID      : $uuid
    . TIMERANGE : {
        begin : $start,
        end : $end,
      },
    . HEADERS   : {
string_end
  foreach my $column ( @$columns ) {
    if( ref( $column ) eq 'ARRAY' ) {
      $string .= "        $column->[ 0 ] : $column->[ 1 ],\n";
    } else {
      # Thin Peer doesnt return columns types
      $string .= "               UNKNOWN : $column,\n";
    }
  }
  $string .= "      },\n  }\n";
  print( $string );

}
#
# @brief Analysis reply rows on Row outputs analysis.
#
# @param $self - Eulerian Data Warehouse Peer Hooks.
# @param $uuid - UUID of Eulerian Analytics Analysis.
# @param $rows - Array of Array of Columns values.
#
sub on_add
{
  my ( $self, $uuid, $rows ) = @_;
  my $string = '';

  for my $row ( @$rows ) {
    for my $col ( @$row ) {
      $string .= "$col | ";
    }
    $string .= "\n";
  }
  print( $string );

}
#
# @brief Analysis reply rows on Distinct/Pivot analysis.
#
# @param $self - Eulerian Data Warehouse Peer Hooks.
# @param $uuid - UUID of Eulerian Analytics Analysis.
# @param $rows - Array of Array of Columns values.
#
sub on_replace
{
  my ( $self, $uuid, $rows ) = @_;
  my $string = '';

  for my $row ( @$rows ) {
    for my $col ( @$row ) {
      $string .= "$col | ";
    }
    $string .= "\n";
  }
  print( $string );

}
#
# @brief Analysis progression callback.
#
# @param $self - Eulerian Data Warehouse Peer Hooks.
# @param $uuid - UUID of Eulerian Analytics Analysis.
# @param $progress - Progression value.
#
sub on_progress
{
  my ( $self, $uuid, $progress ) = @_;
  print( "PROGRESSION : $progress\n" );
}
#
# @brief End of Eulerian Data Warehouse Analysis.
#
# @param $self - Eulerian Data Warehouse Peer Hooks.
# @param $uuid - UUID of Eulerian Analytics Analysis.
# @param $token - AES Token or Bearer.
# @param $errnum - Error number.
# @param $err - Error description.
# @param $updated - Count of updates on server.
#
sub on_status
{
  my ( $self, $uuid, $token, $errnum, $err, $updated ) = @_;
  my $string = <<string_end;
    $uuid : {
     error_code => $errnum,
     error_msg => $err,
    }
string_end
  print( $string );

}
#
# Endup module properly
#
1;
