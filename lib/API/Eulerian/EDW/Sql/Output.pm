use strict; use warnings;

package API::Eulerian::EDW::Sql::Output;

sub new
{
  my $proto = shift;
  my $class = ref( $proto ) || $proto;
  my $setup = shift;
  return bless( {
    formula => $setup->{ formula } || undef
    }
  );
}
#
# @brief
#
# @return
#
sub str
{
  my ( $self ) = @_;
  return $self->{ formula };
}

1;

__END__
