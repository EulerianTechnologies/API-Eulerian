
package API::Eulerian::EDW::UseCases::RollMap;

use API::Eulerian::EDW::Sql::Builder;
use strict; use warnings;
use base 'Exporter';

our @EXPORT = qw( Sql );

sub AddTimerange
{
  my ( $builder, $setup ) = @_;
  $builder->timerange(
    $setup->{ from }, $setup->{ to }
    );
}

sub ToArray
{
  my ( $hash, $key ) = @_;
  my $value = $hash->{ $key } || [];
  $value = [ $value ] if ref( $value ) ne 'ARRAY';
  return $value;
}

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
  # Add clickview reader
  if( $filter ne '' ) {
    $builder->readers(
      'clickview', 'ea:clickview', $setup->{ site }, $filter
      );
  }

}

sub AddMerged
{
  my ( $builder, $setup ) = @_;
  my $filter;

  # Setup visit filter
  $filter  = 'merged.first.pageview.page.name != pageview.page.name';
  $filter .= ' || pageview.rtvisit == 1';

  # Create visit
  $builder->groups( 'merged', 'pageview', $filter );

}

sub AddVisit
{
  my ( $builder, $setup ) = @_;
  my $filter;

  # Setup visit filter
  $filter = 'pageview.rtvisit == 1';
  
  # Create visit
  $builder->groups( 'visit', 'merged', $filter );

}

sub AddJoin
{
  my ( $builder, $setup ) = @_;
  my $media = $setup->{ 'media-shortname' } || undef;
  my $imedia = int( $setup->{ 'media-id' } || 0 );

  if( $imedia ) {
    # Setup join filter
    my $filter = '';
    $filter .= "clickview.timestamp >= visit.first.merged.first.pageview.timestamp && ";
    $filter .= "clickview.timestamp <= visit.last.merged.last.pageview.timestamp && ";
    $filter .= "join.count() < 1 ";
    # Add join on clickview
    $builder->joins( 'join', 'visit', 'clickview', $filter );
  }

  return $imedia;
}

sub AddOutputs
{
  my ( $builder, $prefix, $setup ) = @_;
  my $npages = int( $setup->{ npages } || 5 );

  # Add outputs
  for my $ioutput ( 0 ... $npages - 1 ) {
    $builder->outputs( "Page$ioutput" );
  }

}

sub AddFilter
{
  my ( $builder, $prefix, $setup ) = @_;
  my $roots = ToArray( $setup, 'roots' );
  my $filter = '';
  
  # Add outputs filter  
  $filter .= "$prefixvisit.first.merged.first.pageview.rtvisit == 1 ";
  
  if( defined( $roots ) && scalar( @$roots ) > 0 ) {
    $filter .= ' && ';
    if( $prefix ne '' ) {
      $filter .= $prefix;
      $filter .= "visit.first.merged.first.pageview.timestamp != NULL && ";
    }
    if( scalar( @$roots ) == 1 ) {
      $filter .= "Page0 == '";
      $filter .= $roots->[ 0 ];
      $filter .= "'";
    } elsif( scalar( @$roots ) > 1 ) {
      $filter .= "IN( ";
      $filter .= 'Page0, ';
      $filter .= join( ', ', map { '"' . $_ . '"' } @$roots );
      $filter .= " )";
    }
  }
  $builder->filter( $filter );
}

sub AddThen
{
  my ( $builder, $setup ) = @_;
  my $palmares = int( $setup->{ npalmares } || 5 );
  $builder->thens( "RollMap( $palmares )" );
}

sub AddAliases
{
  my ( $builder, $prefix, $setup ) = @_;
  my $npages = int( $setup->{ npages } || 5 );

  for my $ialias ( 0 ... $npages - 1 ) {
    $builder->aliases(
      "Page$ialias", "${prefix}visit.items( $ialias ).merged.first.pageview.page.name"
    );
  }

}

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
  AddClickview( $builder, $setup );
  AddMerged( $builder, $setup );
  AddVisit( $builder, $setup );
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
