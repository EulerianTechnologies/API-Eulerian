###############################################################################
#
# @brief RollMap EDW sql builder implementation.
#
# This module is used to produce a D3 SanKey Map datas. Those datas allow to
# draw a palmares of pages read before a given page.
#
# @file API/Eulerian/EDW/UseCases/UnRollMap.pm
#
# @date 2026/02/03
#
###############################################################################
#
# Enforce compilor rules.
#
use strict; use warnings;
#
# Define package name.
#
package API::Eulerian::EDW::UseCases::UnRollMap;
#
# Use Sql::Builder.
#
use API::Eulerian::EDW::Sql::Builder;
#
# Import Exporter.
#
use base 'Exporter';
#
# Define exported interface
#
our @EXPORT = qw( Sql );
#
# @brief Add Timerange.
#
# @param $builder - Sql builder.
# @param $setup - Request setup.
#
sub AddTimerange
{
  my ( $builder, $setup ) = @_;
  $builder->timerange( $setup->{ from }, $setup->{ to } );
}
#
# @brief Get an array from a hash map entry.
#
# @param $hash - Hash map.
# @param $key - Key.
#
# @return Array.
#
sub ToArray
{
  my ( $hash, $key ) = @_;
  my $value = $hash->{ $key } || [];
  $value = [ $value ] if ref( $value ) ne 'ARRAY';
  return $value;
}
#
# @brief Add Pageview reader.
#
# @param $builder - Sql builder.
# @param $setup - Request setup.
#
sub AddPageview
{
  my ( $builder, $setup ) = @_;
  my $devices = ToArray( $setup, 'mdevicetypefull-name' );
  my $subkeys = ToArray( $setup, 'subkey2-name' );
  my $ndevices = scalar( @$devices );
  my $nsubkeys = scalar( @$subkeys );
  my $filter = '';

  # Handle pageview filtering on devices if any
  if( $ndevices == 1 ) {
    $filter .= 'pageview.device.devicetype.type == ';
    $filter .= "'";
    $filter .= $devices->[ 0 ];
    $filter .= "'";
  } elsif( $ndevices > 1 ) {
    $filter .= 'IN( pageview.device.devicetype.type, ';
    $filter .= join( ', ', map { '"' . $_ . '"' } @$devices );
    $filter .= ' )';
  }

  # Handle pageview filtering on subkey2 if any
  if( $nsubkeys == 1 ) {
    if( $ndevices ) { $filter .= " && "; }
    $filter .= 'pageview.subkey2.name == ';
    $filter .= "'";
    $filter .= $subkeys->[ 0 ];
    $filter .= "'";
  } elsif( $nsubkeys > 1 ) {
    if( $ndevices ) { $filter .= " && "; }
    $filter .= 'IN( pageview.subkey2.name, ';
    $filter .= join( ', ', map { '"' . $_ . '"' } @$subkeys );
    $filter .= ' )';
  }

  # Add pageview reader
  $builder->readers(
    'pageview', 'ea:pageview', $setup->{ site }, $filter
  );

}
#
# @brief Add Clickview reader.
#
# @param $builder - Sql builder.
# @param $setup - Request setup.
#
sub AddClickview
{
  my ( $builder, $setup ) = @_;
  my $medias = ToArray( $setup, 'media-shortname' );
  my $imedia = int( $setup->{ 'media-id' } || 0 );
  my $nmedias = scalar( @$medias );
  my $filter = '';

  # Handle clickview if need it */
  if( $nmedias == 1 ) {
    # Setup clickview filter
    $filter .= "clickview.channel.odmedia == '";
    $filter .= $medias->[ 0 ];
    $filter .= "'";
  } elsif( $nmedias > 1 ) {
    $filter .= 'IN( clickview.channel.odmedia, ';
    $filter .= join( ', ', map { '"' . $_ . '"' } @$medias );
    $filter .= ' )';
  }
  if( $filter ne '' ) {
    # Add clickview reader
    $builder->readers(
      'clickview', 'ea:clickview', $setup->{ site }, $filter
      );
  }

}
#
# @brief Add group visit.
#
# @param $builder - Sql builder.
# @param $setup - Request setup.
#
sub AddVisit
{
  my ( $builder, $setup ) = @_;
  my $filter;

  # Setup visit filter
  $filter  = 'visit.last.pageview.timestamp + MINS( ';
  $filter .= int( $setup->{ session } || 30 );
  $filter .= ' ) < pageview.timestamp';
  # Create visit
  $builder->groups( 'visit', 'pageview', $filter );

}
#
# @brief Join visit and clickview.
#
# @param $builder - Sql builder.
# @param $setup - Request setup.
#
sub AddJoin
{
  my ( $builder, $setup ) = @_;
  my $imedia = int( $setup->{ 'media-id' } || 0 );

  if( $imedia ) {
    # Setup join filter
    my $filter = '';
    $filter .= 'clickview.timestamp >= visit.first.pageview.timestamp && ';
    $filter .= 'clickview.timestamp <= visit.last.pageview.timestamp && ';
    $filter .= 'join.count() < 1 ';
    # Add join on clickview
    $builder->joins( 'join', 'visit', 'clickview', $filter );
  }

  return $imedia;
}
#
# @brief Add aliases.
#
# @param $builder - Sql builder.
# @param $setup - Request setup.
#
sub AddAliases
{
  my ( $builder, $prefix, $setup ) = @_;
  my $npages = int( $setup->{ npages } || 5 );
  my $target = "'" . $setup->{ target } . "'";
  # Target Alias
  $builder->aliases( "Target", $target );
  # PageId Alias
  $builder->aliases(
    "PageId",
    "visit.find_last( visit.current.pageview.page.name == Target )"
    );
}
#
# @brief Add outputs.
#
# @param $builder - Sql builder.
# @param $setup - Request setup.
#
sub AddOutputs
{
  my ( $builder, $prefix, $setup ) = @_;
  my $npages = int( $setup->{ npages } || 5 );

  # Add outputs
  for my $ioutput ( 0 ... $npages - 1 ) {
    $builder->outputs(
      "visit.items( PageId - $ioutput ).pageview.page.name"
    );
  }

}
#
# @brief Add outputs filter.
#
# @param $builder - Sql builder.
# @param $setup - Request setup.
#
sub AddFilter
{
  my ( $builder, $prefix, $setup ) = @_;
  my $filter = 'PageId != NULL';
  $builder->filter( $filter );
}
#
# @brief Add Post processing command.
#
# @param $builder - Sql builder.
# @param $setup - Request setup.
#
sub AddThen
{
  my ( $builder, $setup ) = @_;
  my $palmares = int( $setup->{ npalmares } || 5 );
  $builder->thens( "UnRollMap( $palmares )" );
}
#
# @brief Forge SQL request used to produce DS3 Sankey Map
#        Graph.
#
# @param $setup - Request setup.
#
# @return Sql request.
#
sub Sql
{
  my $builder = new API::Eulerian::EDW::Sql::Builder();
  my $master = 'visit';
  my ( $setup ) = @_;
  my $prefix = '';

  $builder->mode( 'ROW' );
  $builder->master( 'visit' );
  AddTimerange( $builder, $setup );
  AddPageview( $builder, $setup );
  AddVisit( $builder, $setup );
  AddClickview( $builder, $setup );
  if( AddJoin( $builder, $setup ) ) {
    $builder->master( 'join' );
    $prefix = 'join.';
  }
  AddAliases( $builder, $prefix, $setup );
  AddOutputs( $builder, $prefix, $setup );
  AddFilter( $builder, $prefix, $setup );
  AddThen( $builder, $setup );

  return $builder->str();
}
