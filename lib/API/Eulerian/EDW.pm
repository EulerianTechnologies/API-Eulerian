package API::Eulerian::EDW;


use strict;
use API::Eulerian::EDW::Peer::Rest();

sub new {
  my $proto = shift();
  my $class = ref($proto) || $proto;
  return bless({}, $class);
}

sub get_csv_file {
  my ($self, $rh_p, $query) = @_;

  $rh_p ||= {};
  $rh_p->{accept} = 'text/csv';
  $rh_p->{hook} = 'API::Eulerian::EDW::Hook::Noop';

  $query ||= '';

  my $peer = new API::Eulerian::EDW::Peer::Rest( $rh_p );
  if ( !defined $peer ) {
    return { error => 1, error_msg => 'unable to build object' };
  }

  my $status = $peer->request( $query );

  if ( $status->error() ) {
    return {
      error => 1,
      error_msg => $status->msg()
    };
  }

  # kill request at EDW for clean-up
  $peer->cancel();

  return { error => 0, path2file => $status->path() };
}

1;
__END__

=pod

=head1 NAME

 API::Eulerian::EDW - Simple interface for interacting with Eulerian DataWareHouse

=head1 SYNOPSIS

 use API::Eulerian::EDW();

 my $edw = new API::Eulerian::EDW();
 my $rh_query = $edw->get_csv_file( \%h_conf, $query );

 if ( $rh_query->{error} ) {
   print STDERR "Error: ".$rh_query->{error_msg}."\n";
   exit(1);
 }

 my $path2csvfile = $rh_query->{path2file};

 # Content is in the CSV file

=head1 DESCRIPTION

 This module is a simple wrapper for querying the EDW and get the CSV file containing the content.

=head1 METHODS

=over 8

=item get_csv_file ( \%h_conf, $query )

 %h_conf is a hash reference containing :

=over 4

=item grid : name of the grid

=item token : generic authorization API token

=item site : name of the site

=back

 $query : is a EDW valid query

 The method returns a hash reference with containing error property set to 1 with error_msg, otherwise
 the csv path is provided in path2file.

=back

=head1 AUTHOR

 Mathieu Jondet <mathieu@eulerian.com>
 Xavier Thorillon <xavier@eulerian.com>

=cut
