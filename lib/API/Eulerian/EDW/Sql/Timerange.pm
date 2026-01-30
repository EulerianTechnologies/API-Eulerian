#!/usr/bin/perl
###############################################################################
#
# @brief Eulerian EDW Sql Timerange class definition.
#
# @file API/Eulerian/EDW/Sql/Timerange.pm
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
package API::Eulerian::EDW::Sql::Timerange;
#
# @brief Allocate and initialize a new Eulerian Data Warehouse Sql Timerange.
#
# @param $class - Class.
# @param $setup - Initial setup parameters.
#                 begin => Timerange begin.
#                 end   => Timerange end.
#
# @return Timerange.
#
sub new
{
  my $proto = shift;
  my $class = ref( $proto ) || $proto;
  my $setup = shift;
  return bless( {
      begin => $setup->{ begin } || undef,
      end => $setup->{ end } || undef,
    }
  );
}
#
# @brief Setup Timerange begin.
#
# @param $self - Sql Timerange.
# @param $begin - Timerange begin.
#
# @return Timerange begin.
#
sub begin
{
  my ( $self, $begin ) = @_;

  if( defined( $begin ) ) {
    $self->{ begin } = $begin;
  } else {
    $begin = $self->{ begin };
  }

  return $begin;
}
#
# @brief Setup Timerange end.
#
# @param $self - Sql Timerange.
# @param $end - Timerange end.
#
# @return Timerange end.
#
sub end
{
  my ( $self, $end ) = @_;

  if( defined( $end ) ) {
    $self->{ end } = $end;
  } else {
    $end = $self->{ end };
  }

  return $end;
}
#
# @brief Test if timerange is valid.
#
# @param $self - Self.
#
# @return 1 - Valid.
# @return 0 - Invalid.
#
sub valid
{
  my $self = shift;
  return 1;
}
#
# @brief Stringify Eulerian Data Warehouse Sql Timerange.
#
# @param $self - Self.
#
# @return Stringified timerange.
#
sub str
{
  my ( $self ) = @_;
  my $string = '';
  $string .= "TIMERANGE{ ";
  $string .= $self->{ begin };
  $string .= ", ";
  $string .= $self->{ end };
  $string .= " }";
  return $string;
}

1;

__END__
