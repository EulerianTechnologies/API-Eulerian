#!/usr/bin/perl
###############################################################################
#
# @file API/Eulerian/EDW/Sql/Builder.pm
#
# @brief Eulerian Data Warehouse SQL Builder class definition.
#
# @author x.thorillon@eulerian.com
#
# @date 27/01/2016
#
###############################################################################
#
# Enforce compilor rules
#
use strict; use warnings;
#
# Set Package Name
#
package API::Eulerian::EDW::Sql::Builder;
#
# Load Sql modules.
#
use API::Eulerian::EDW::Sql::Timerange;
use API::Eulerian::EDW::Sql::Reader;
use API::Eulerian::EDW::Sql::Group;
use API::Eulerian::EDW::Sql::Join;
use API::Eulerian::EDW::Sql::Alias;
use API::Eulerian::EDW::Sql::Array;
use API::Eulerian::EDW::Sql::Outputs;
use API::Eulerian::EDW::Sql::Then;
#
# @brief Map of Eulerian Data Warehouse Analytics Analysis outputs mode.
#
use constant OUTPUTS => sub { {
  ROW      => 'OUTPUTS_ROW',
  DISTINCT => 'OUTPUTS_DISTINCT',
  PIVOT    => 'OUTPUTS_PIVOT',
}->{ +shift } };
#
# @brief Allocate and initialize a new API Eulerian Data Warehouse Sql
#        Builder instance.
#
# @param $proto - Class name.
# @param $setup - Initial setup values ( unused ).
#
# @return SQL Builder instance.
#
sub new
{
  my $proto = shift;
  my $class = ref( $proto ) || $proto;
  my $setup = shift || {};
  return bless( {
    timerange => new API::Eulerian::EDW::Sql::Timerange(),
    readers => new API::Eulerian::EDW::Sql::Array( { sep => ' ' } ),
    groups => new API::Eulerian::EDW::Sql::Array(),
    joins => new API::Eulerian::EDW::Sql::Array(),
    aliases => new API::Eulerian::EDW::Sql::Array( { sep => ', ' } ),
    thens => new API::Eulerian::EDW::Sql::Array(),
    outputs => new API::Eulerian::EDW::Sql::Outputs(),
    },
  );
}
#
# @brief Setup Eulerian Data Warehouse Sql Timerange.
#
# @param $self - Sql builder.
# @param $begin - Timerange begin.
# @param $end - Timerange end.
#
# @return 0 - Success.
#
sub timerange
{
  my ( $self, $begin, $end ) = @_;
  my $timerange = $self->{ timerange };

  $timerange->begin( $begin );
  $timerange->end( $end );

  return $timerange->valid();
}
#
# @brief Add reader.
#
# @param $self - Sql builder.
# @param $name - Reader name.
# @param $path - Reader path ( ie : <store>:<object> ).
# @param $site - Site.
# @param $filter - Objects filter.
#
# @return Readers count.
#
sub readers
{
  my ( $self, $name, $path, $site, $filter ) = @_;
  my $readers = $self->{ readers };

  if( ! ( defined( $name ) && defined( $path ) && defined( $site ) ) ) {
    die( 'Adding reader failed, mandatory argument is missing' );
  }

  $readers->push(
    new API::Eulerian::EDW::Sql::Reader( {
      name => $name,
      path => $path,
      site => $site,
      filter => $filter,
      } )
  );

  return $readers->count();
}
#
# @brief Add group.
#
# @param $self - Sql builder.
# @param $name - Group name.
# @param $with - Source of the group.
# @param $filter - Group filtering.
#
# @return Groups count.
#
sub groups
{
  my ( $self, $name, $with, $filter ) = @_;
  my $groups = $self->{ groups };

  if( ! ( defined( $name ) && defined( $with ) ) ) {
    die( 'Adding group failed, mandatory argument is missing' );
  }

  $groups->push(
    new API::Eulerian::EDW::Sql::Group( {
      name => $name,
      with => $with,
      filter => $filter,
      } )
  );

  return $groups->count();
}
#
# @brief Add join.
#
# @param $self - Sql builder.
# @param $name - Group name.
# @param $left - Left data source.
# @param $right - Right data source.
# @param $criteria - Join criteria.
#
# @return Joins count.
#
sub joins
{
  my ( $self, $name, $left, $right, $filter ) = @_;
  my $joins = $self->{ joins };

  if( ! ( defined( $name ) && defined( $left ) && defined( $right ) ) ) {
    die( 'Adding join failed, mandatory argument is missing' );
  }

  $joins->push(
    new API::Eulerian::EDW::Sql::Join( {
      name => $name,
      left => $left,
      right => $right,
      filter => $filter,
      } )
  );

  return $joins->count();
}
#
# @brief Add alias.
#
# @param $self - Sql builder.
# @param $name - Alias name.
# @param $formula - Alias formula.
#
# @return Aliases count.
#
sub aliases
{
  my ( $self, $name, $formula ) = @_;
  my $aliases = $self->{ aliases };

  if( ! ( defined( $name ) && defined( $formula ) ) ) {
    die( 'Adding alias failed, mandatory argument is missing' );
  }

  $aliases->push(
    new API::Eulerian::EDW::Sql::Alias( {
      name => $name,
      formula => $formula
      } )
  );

  return $aliases->count();
}
#
# @brief Add then.
#
# @param $self - Sql builder.
# @param $formula - Then formula.
#
# @return Thens formulas count.
#
sub thens
{
  my ( $self, $formula ) = @_;
  my $thens = $self->{ thens };

  if( ! defined( $formula ) ) {
    die( 'Adding then failed, mandatory argument is missing' );
  }

  $thens->push(
    new API::Eulerian::EDW::Sql::Then( {
      formula => $formula
      } )
  );

  return $thens->count();
}
#
# @brief Setup Eulerian Data Warehouse Analytics Analysis outputs master.
#
# @param $self - Sql builder.
# @param $name - Master outputs name.
#
# @return Master name.
#
sub master
{
  my ( $self, $name ) = @_;
  my $outputs = $self->{ outputs };
  $outputs->master( $name );
  return $name;
}
#
# @brief Setup Eulerian Data Warehouse Analytics Analytics outputs mode.
#
# @param $self - Sql builder.
# @param $mode - Master outputs mode.
#
# @return Master name.
#
sub mode
{
  my ( $self, $mode ) = @_;
  my $outputs = $self->{ outputs };
  $outputs->mode( OUTPUTS->( $mode ) );
  return $outputs->mode();
}
#
# @brief Setup Eulerian Data Warehouse Analytics Analysis outputs filter.
#
# @param $self - Sql builder.
# @param $formula - Filter formula.
#
# @return Filter.
#
sub filter
{
  my ( $self, $formula ) = @_;
  my $outputs = $self->{ outputs };
  $outputs->filter( $formula );
  return $outputs->filter();
}
#
# @brief Add output to Eulerian Data Warehouse Analytics Analysis outputs.
#
# @param $self - Sql builder.
# @param $formula - Output formula
#
# @return Count of outputs.
#
sub outputs
{
  my ( $self, $formula ) = @_;
  my $outputs = $self->{ outputs };
  return $outputs->add( $formula );
}
#
# @brief Stringify Sql request.
#
# @param $self - Sql builder.
#
# @return Stringified Sql request.
#
sub str
{
  my $self = shift;
  my $timerange = $self->{ timerange };
  my $aliases = $self->{ aliases };
  my $readers = $self->{ readers };
  my $outputs = $self->{ outputs };
  my $groups = $self->{ groups };
  my $joins = $self->{ joins };
  my $thens = $self->{ thens };
  my $str = '';
  my $mode;

  $str .= "GET { ";
  $str .= $timerange->str();
  if( $readers->count() ) {
    $str .= " READERS { ";
    $str .= $readers->str();
    $str .= " } ";
  }
  if( $groups->count() ) {
    $str .= "GROUPS { ";
    $str .= $groups->str();
    $str .= " } ";
  }
  if( $joins->count() ) {
    $str .= "JOINS { ";
    $str .= $joins->str();
    $str .= " } ";
  }
  if( $aliases->count() ) {
    $str .= "ALIASES { ";
    $str .= $aliases->str();
    $str .= " } ";
  }
  $str .= $outputs->str();
  if( $thens->count() ) {
    $str .= "THEN { ";
    $str .= $thens->str();
    $str .= " } ";
  }
  $str .= "};";

  return $str;
}
#
# End up module properly
#
1;

__END__
