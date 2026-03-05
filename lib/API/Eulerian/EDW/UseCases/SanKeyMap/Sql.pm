package API::Eulerian::EDW::UseCases::SanKeyMap;

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

sub AddJoin
{
  my ( $builder, $setup ) = @_;
  my $media = $setup->{ 'media-shortname' } || undef;
  my $imedia = int( $setup->{ 'media-id' } || 0 );

  if( $imedia ) {
    # Setup join filter
    my $filter = '';
    $filter .= "clickview.timestamp > visit.first.pageview.timestamp && ";
    $filter .= "clickview.timestamp <= visit.last.pageview.timestamp && ";
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
    my $output = $prefix;
    $output .= "visit.items( $ioutput ).pageview.page.name";
    $builder->outputs( $output );
  }

}

sub AddFilter
{
  my ( $builder, $prefix, $setup ) = @_;
  my $roots = ToArray( $setup, 'roots' );

  # Add outputs filter
  if( scalar( @$roots ) > 0 ) {
    my $filter = '';

    if( $prefix ne '' ) {
      $filter .= $prefix;
      $filter .= "visit.first.pageview.timestamp != NULL && ";
    }
    if( scalar( @$roots ) == 1 ) {
      $filter .= $prefix;
      $filter .= "visit.items( 0 ).pageview.page.name == '";
      $filter .= $roots->[ 0 ];
      $filter .= "'";
    } elsif( scalar( @$roots ) > 1 ) {
      $filter .= "IN( ";
      $filter .= $prefix;
      $filter .= "visit.items( 0 ).pageview.page.name, ";
      $filter .= join( ', ', map { '"' . $_ . '"' } @$roots );
      $filter .= " )";
    }
    $builder->filter( $filter );

  }

}

sub AddThen
{
  my ( $builder, $setup ) = @_;
  my $palmares = int( $setup->{ npalmares } || 5 );
  $builder->thens( "SanKeyMap( $palmares )" );
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
  AddVisit( $builder, $setup );
  if( AddJoin( $builder, $setup ) ) {
    $builder->master( 'join' );
    $prefix = 'join.';
  }
  AddOutputs( $builder, $prefix, $setup );
  AddFilter( $builder, $prefix, $setup );
  AddThen( $builder, $setup );

  return $builder->str();
}
