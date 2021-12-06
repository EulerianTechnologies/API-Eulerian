#/usr/bin/env perl
###############################################################################
#
# @file Csv.pm
#
# @brief Eulerian Data Warehouse REST Csv Parser Module definition.
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
package Eulerian::Edw::Parsers::Csv;
#
# Enforce compilor rules
#
use strict; use warnings;
#
# Inherited interface from Eulerian::Edw::Parser
#
use parent 'Eulerian::Edw::Parser';
#
# Import Text::CSV
#
use Text::CSV;
#
# @brief
#
# @param $class - Eulerian::Edw::Parser class.
# @param $path - File Path.
# @param $uuid - Request uuid.
#
# @return Eulerian::Edw::Json Parser.
#
sub new
{
  my ( $class, $path, $uuid ) = @_;
  my $self;
  my $file;
  my $fd;

  if( open( $file, '<:encoding(utf8)', $path ) ) {
    $self = $class->SUPER::new( $path, $uuid );
    $self->{ _FILE } = $file;
    $self->{ _PARSER } = Text::CSV->new( {
      binary => 1,
      auto_diag => 1,
      sep_char => ',',
    } );
  }

  return $self;
}
#
# @brief
#
# @param $self
#
# @return
#
sub file
{
  return shift->{ _FILE };
}
#
# @brief
#
# @param $self
#
# @return
#
sub parser
{
  return shift->{ _PARSER };
}
#
# @brief
#
# @param $self - Eulerian::Edw::Parser
#
sub do
{
  my ( $self, $hooks ) = @_;
  my $parser = $self->parser();
  my $file = $self->file();
  my $uuid = $self->uuid();
  my @headers = ();
  my $start = 0;
  my $end = 0;
  my @rows;
  my $line;

  # Process Headers line
  $line = <$file>; chomp $line;
  if( $parser->parse( $line ) ) {
    foreach my $field ( $parser->fields() ) {
      push @headers, [ 'UNKNOWN', $field ];
    }
    $hooks->on_headers( $uuid, $start, $end, \@headers );
  }

  # Process Next lines
  while( my $line = <$file> ) {
    chomp $line;
    if( $parser->parse( $line ) ) {
      @rows = [ $parser->fields() ];
      $hooks->on_add( $uuid, \@rows );
    }
  }

  $hooks->on_status( $uuid, '', 0, 'Success', 0 );

}
#
# Endup module properly
#
1;
