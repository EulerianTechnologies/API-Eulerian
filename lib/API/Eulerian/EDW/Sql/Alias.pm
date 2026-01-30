#!/usr/bin/perl
###############################################################################
#
# @brief Eulerian EDW Sql Alias class definition.
#
# @file API/Eulerian/EDW/Sql/Alias.pm
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
package API::Eulerian::EDW::Sql::Alias;
#
# @brief Allocate and initialize a new Sql::Alias instance.
#
# @param $proto - Class name.
# @param $setup - Alias initial attributes values.
#                 name : Alias name.
#                 formula : Alias formula.
#
# @return Alias instance.
#
sub new
{
  my $proto = shift;
  my $class = ref( $proto ) || $proto;
  my $setup = shift;
  return bless( {
      name => $setup->{ name } || undef,
      formula => $setup->{ formula } || undef
    }
  );
}
#
# @brief Stringify Sql::Alias instance.
#
# @param $self - Self.
#
# @return Stringified Alias.
#
sub str
{
  my ( $self ) = @_;
  my $str = '';

  $str .= $self->{ name };
  $str .= ' = ';
  $str .= $self->{ formula };

  return $str;
}
#
# End up module properly
#
1;

__END__
