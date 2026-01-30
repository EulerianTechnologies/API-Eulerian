use strict; use warnings;

package API::Eulerian::EDW::Sql::Reader;

#
# @brief
#
# @param $class - Class.
# @param $setup - Setup.
#
sub new
{
  my $proto = shift;
  my $class = ref( $proto ) || $proto;
  my $setup = shift;
  return bless( {
      path => $setup->{ path } || undef,
      site => $setup->{ site } || undef,
      name => $setup->{ name } || undef,
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
# @return Stringified Reader.
#
sub str
{
  my ( $self ) = @_;
  my $str = '';

  $str .= $self->{ path };
  $str .= '@';
  $str .= $self->{ site };
  $str .= ' AS ';
  $str .= $self->{ name };
  if( $self->isset( 'filter' ) ) {
    $str .= " IF { ";
    $str .= $self->{ filter };
    $str .= " } ";
  }

  return $str;
}

1;

__END__
