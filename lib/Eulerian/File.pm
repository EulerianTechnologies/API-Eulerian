#/usr/bin/env perl
###############################################################################
#
# @file File.pm
#
# @brief Eulerian::File module used to manage local file system.
#
# @author Thorillon Xavier:x.thorillon@eulerian.com
#
# @date 25/11/2021
#
# @version 1.0
#
###############################################################################
#
# Setup perl package name
#
package Eulerian::File;
#
# Enforce compilor rules
#
use strict; use warnings;
#
# Import Eulerian::Status
#
use Eulerian::Status;
#
# @brief Read file content.
#
# @param path - File path.
#
# @return Eulerian::Status
#
sub read
{
  my $status = Eulerian::Status->new();
  my ( $class, $path ) = @_;
  my $data;
  my $fd;
  # Open file for reading
  open $fd, "<", $path or do {
    $status->error( 1 );
    $status->code( -1 );
    $status->msg( "Opening file : $path for reading failed. $!" );
    return $status;
  };
  # Read file content
  $data = do { local $/; <$fd> };
  # Close file
  close $fd;
  # Save content
  $status->{ data } = $data;
  return $status;
}
#
# @brief Test if given path is writable.
#
# @param $class - Eulerian::File class.
# @param $path - Filesystem path.
#
# @return 0 - Path isnt writable.
# @return 1 - Path is writable.
#
sub writable
{
  my ( $class, $path ) = @_;
  return -w $path;
}
#
# End up perl module properly
#
1;
