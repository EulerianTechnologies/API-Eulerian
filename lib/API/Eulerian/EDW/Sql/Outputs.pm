use strict; use warnings;

package API::Eulerian::EDW::Sql::Outputs;

use API::Eulerian::EDW::Sql::Array;
use API::Eulerian::EDW::Sql::Output;

sub new
{
  my $proto = shift;
  my $class = ref( $proto ) || $proto;
  my $setup = shift;
  return bless( {
    master => $setup->{ master } || undef,
    mode => $setup->{ mode } || undef,
    filter => $setup->{ filter } || undef,
    formulas => new API::Eulerian::EDW::Sql::Array( { sep => ", " } ),
    }
  );
}

sub master
{
  my ( $self, $master ) = @_;

  if( defined( $master ) ) {
    $self->{ master } = $master;
  } else {
    $master = $self->{ master };
  }

  return $master;
}

sub mode
{
  my ( $self, $mode ) = @_;

  if( defined( $mode ) ) {
    $self->{ mode } = $mode;
  } else {
    $mode = $self->{ mode };
  }

  return $mode;
}

sub filter
{
  my ( $self, $filter ) = @_;

  if( defined( $filter ) ) {
    $self->{ filter } = $filter;
  } else {
    $filter = $self->{ filter };
  }

  return $filter;
}

sub add
{
  my ( $self, $formula ) = @_;
  my $formulas = $self->{ formulas };

  $formulas->push(
    new API::Eulerian::EDW::Sql::Output( {
      formula => $formula
    } )
  );

  return $formulas->count();
}

sub str
{
  my ( $self ) = @_;
  my $formulas = $self->{ formulas };
  my $filter = $self->{ filter };
  my $str = '';

  $str .= $self->mode();
  $str .= '( ';
  $str .= $self->master();
  $str .= " ) { ";
  if( $formulas->count() ) {
    $str .= $formulas->str();
  }
  $str .= " } ";
  if( defined( $filter ) ) {
    $str .= "IF { ";
    $str .= $filter;
    $str .= " } ";
  }

  return $str;
}

1;

__END__
