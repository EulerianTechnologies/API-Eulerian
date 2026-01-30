use strict; use warnings;

package API::Eulerian::EDW::Sql::Group;

sub new
{
  my $proto = shift;
  my $class = ref( $proto ) || $proto;
  my $setup = shift;
  return bless( {
      name => $setup->{ name } || undef,
      with => $setup->{ with } || undef,
      filter => $setup->{ filter } || undef,
    }
  );
}
#
#
#
#
sub isset
{
  my ( $self, $key ) = @_;
  return exists( $self->{ $key } ) &&
    defined( $self->{ $key } );
}

sub str
{
  my ( $self ) = @_;
  my $str = '';

  $str .= $self->{ name };
  $str .= ' WITH ';
  $str .= $self->{ with };
  if( $self->isset( 'filter' ) ) {
    $str .= " IF { ";
    $str .= $self->{ filter };
    $str .= " } ";
  }

  return $str;
}

1;

__END__
