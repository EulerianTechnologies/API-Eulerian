#/usr/bin/env perl
###############################################################################
#
# @file Rest.pl
#
# @brief Example of Eulerian Data Warehouse Peer performing an Analysis using
#        Rest Protocol.
#
# @author Thorillon Xavier:x.thorillon@eulerian.com
#
# @date 25/11/2021
#
# @version 1.0
#
###############################################################################
#
# Enforce compilor rules
#
use strict; use warnings;
#
# Import Eulerian::Edw::Peer instance factory
#
use Eulerian::Edw::Peer;
#
# Import Eulerian::Edw::Hooks::Print
#
use Eulerian::Edw::Hooks::Print;
#
# Sanity check mandatory command file
#
unless( defined( $ARGV[ 0 ] ) ) {
  die "Mandatory argument command file path is missing";
}
#
# Create a user specific Hooks used to handle Analysis replies.
#
my $hooks = new Eulerian::Edw::Hooks::Print();
#
# Setup Peer options
#
my $path = $ARGV[ 0 ];
my %setup = (
  class => 'Eulerian::Edw::Peers::Rest',
  hooks => $hooks,
  grid => '', # TODO
  ip => '', # TODO
  token => '', #TODO
);
my $status;
my $peer;
my $cmd;

# Read command from File
$status = Eulerian::File->read( $path );
if( $status->error() ) {
  $status->dump();
} else {
  # Get command from file
  $cmd = $status->{ data };
  # Create Peer instance
  $peer = new Eulerian::Edw::Peer( \%setup );
  # Send Command, call hooks
  $status = $peer->request( $cmd );
  if( $status->error() ) {
    $status->dump();
  } else {
    # Cancel the command
    $peer->cancel();
  }
}
