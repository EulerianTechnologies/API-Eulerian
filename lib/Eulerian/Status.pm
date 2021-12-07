#/usr/bin/env perl
###############################################################################
#
# @file Status.pm
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
package Eulerian::Status;
#
# Enforce compilor rules
#
use strict; use warnings;
#
# @brief
#
# @param $class -
#
# @return
#
sub new
{
  my ( $class ) = @_;
  my $self = bless( {
      _ERROR => 0,
      _MSG => '',
      _CODE => 0,
    }, $class
  );
  return $self;
}
#
# @brief
#
# @param $self
# @param $msg
#
# @return $msg
#
sub msg
{
  my ( $self, $msg ) = @_;
  $self->{ _MSG } = $msg if defined( $msg );
  return $self->{ _MSG };
}
#
# @brief
#
# @param $self
# @param $code
#
# @return $code
#
sub code
{
  my ( $self, $code ) = @_;
  $self->{ _CODE } = $code if defined( $code );
  return $self->{ _CODE };
}
#
# @brief
#
# @param $self
# @param $code
#
# @return $code
#
sub error
{
  my ( $self, $error ) = @_;
  $self->{ _ERROR } = $error if defined( $error );
  return $self->{ _ERROR };
}
#
# @brief
#
# @param $self
#
sub dump
{
  my ( $self ) = @_;
  my $error = $self->error() ? 'Yes' : 'No';
  my $code = $self->code();
  my $msg = $self->msg();
  my $string = <<string_end;
    Error   : $error
    Code    : $code
    Message : $msg
string_end
  print( $string );
}
#
# End up perl module properly
#
1;
