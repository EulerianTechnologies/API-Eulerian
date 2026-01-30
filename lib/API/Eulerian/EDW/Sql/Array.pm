#!/usr/bin/perl
###############################################################################
#
# @brief Eulerian EDW Sql Array class definition.
#
# @file API/Eulerian/EDW/Sql/Array.pm
#
# @author x.thorillon@eulerian.com
#
###############################################################################
#
# Enforce compilor rules.
#
use strict; use warnings;
#
# Setup Package path.
#
package API::Eulerian::EDW::Sql::Array;
#
# @brief Allocate and initialize a new Sql::Array instance.
#
# @param $proto - Class name.
# @param $setup - Alias initial attributes values.
#                 sep : Array values separator.
#                 crlf : Array values CRLF,
#                 tab : Array values tabulation.
#
# @return Array instance.
#
sub new
{
  my $proto = shift;
  my $class = ref( $proto ) || $proto;
  my $setup = shift;
  return bless( {
    items => [],
    sep => $setup->{ sep } || '',
    crlf => $setup->{ crlf } || '',
    tab => $setup->{ tab } || '',
    }
  );
}
#
# @brief Add item into SQL array.
#
# @param $self - Self.
# @param $item - Item.
#
# @return Array items count.
#
sub push
{
  my ( $self, $item ) = @_;
  my $items = $self->{ items };
  push( @$items, $item );
  return scalar( @$items );
}
#
# @brief Get item at given index.
#
# @param $self - Self.
# @param $index - Item index.
#
# @return Item.
#
sub get
{
  my ( $self, $index ) = @_;
  my $items = $self->{ items };
  return $items->[ $index ];
}
#
# @brief Get count of items in the array.
#
# @param $self - Self.
#
# @return Items count.
#
sub count
{
  my ( $self ) = @_;
  my $items = $self->{ items };
  return scalar( @$items );
}
#
# @brief Stringify Array values.
#
# @param $self - Self.
#
# @return Stringified Array values.
#
sub str
{
  my ( $self ) = @_;
  my $items = $self->{ items };
  my $nitems = scalar( @$items );
  my $str = '';
  my $iitem;
  my $item;

  if( $nitems ) {
    for $iitem ( 0 ... $nitems - 2 ) {
      $item = $items->[ $iitem ];
      $str .= $self->{ tab };
      $str .= $item->str();
      $str .= $self->{ sep };
      $str .= $self->{ crlf };
    }
    $item = $items->[ $nitems - 1 ];
    $str .= $self->{ tab };
    $str .= $item->str();
    $str .= $self->{ crlf };
  }

  return $str;
}
#
# End up module properly
#
1;

__END__
