use strict; use warnings;

package API::Eulerian::EDW::Sql::Join;

sub new
{
  my $proto = shift;
  my $class = ref( $proto ) || $proto;
  my $setup = shift;
  return bless( {
      name => $setup->{ name } || undef,
      left => $setup->{ left } || undef,
      right => $setup->{ right } || undef,
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

#
# @brief
#
# @return
#
sub str
{
  my ( $self ) = @_;
  my $str = '';

  $str .= $self->{ left };
  $str .= ' WITH ';
  $str .= $self->{ right };
  if( $self->isset( 'filter' ) ) {
    $str .= " IF { ";
    $str .= $self->{ filter };
    $str .= " } AS $self->{ name }";
  }

  return $str;
}

1;

__END__
