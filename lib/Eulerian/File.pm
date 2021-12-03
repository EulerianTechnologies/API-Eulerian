#/usr/bin/env perl
###############################################################################
#
# @file File.pm
#
# @brief Module
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
# @brief Read file content.
#
# @param path - File path.
#
# @return File content.
#
sub read
{
  my ( $class, $path ) = @_;
  open my $FD, '<', $path
    or die "Couldn't open file : $path. $!";
  my $data = do { local $/; <$FD> };
  close $FD;
  return $data;
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
