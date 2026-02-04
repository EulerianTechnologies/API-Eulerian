#!/usr/bin/perl
###############################################################################
#
# @brief Tests script of API::Eulerian::EDW::UseCases::SanKeyMap::Sql().
#
# @file SanKeyMap.pl
#
# @date 04-02-2026
#
# @author x.thorillon@eulerian.com
#
###############################################################################
#
# Enforce compilor rules.
#
use strict; use warnings;
#
# Import SanKeyMap Sql
#
use API::Eulerian::EDW::UseCases::SanKeyMap::Sql;
#
# Main entry point of the script.
#
sub main
{
  my @setups = (
    {
      from => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 00:00:00" )',
      to => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/30 23:59:59" )',
      site => 'demo-fr',
    },
    {
      from => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 00:00:00" )',
      to => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/30 23:59:59" )',
      site => 'demo-fr',
      npages => 10,
    },
    {
      from => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 00:00:00" )',
      to => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/30 23:59:59" )',
      site => 'demo-fr',
      npages => 5,
      session => 30,
    },
    {
      from => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 00:00:00" )',
      to => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/30 23:59:59" )',
      site => 'onisep-fr',
      npages => 5,
      session => 30,
      roots => 'metier/des-metiers-qui-recrutent/',
    },
    {
      from => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 00:00:00" )',
      to => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/30 23:59:59" )',
      site => 'onisep-fr',
      npages => 5,
      session => 30,
      roots => [
        'metier/des-metiers-qui-recrutent/la-transition-energetique-c-est-quoi',
        'metier/des-metiers-qui-recrutent/',
      ],
    },
    {
      from => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 00:00:00" )',
      to => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/30 23:59:59" )',
      site => 'onisep-fr',
      npages => 5,
      session => 30,
      'mdevicetypefull-name' => 'Linux',
      roots => [
        'metier/des-metiers-qui-recrutent/la-transition-energetique-c-est-quoi',
        'metier/des-metiers-qui-recrutent/',
      ],
    },
    {
      from => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 00:00:00" )',
      to => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/30 23:59:59" )',
      site => 'onisep-fr',
      npages => 5,
      session => 30,
      'mdevicetypefull-name' => [ 'Linux', 'Windows' ],
      roots => [
        'metier/des-metiers-qui-recrutent/la-transition-energetique-c-est-quoi',
        'metier/des-metiers-qui-recrutent/',
      ],
    },
    {
      from => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 00:00:00" )',
      to => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/30 23:59:59" )',
      site => 'onisep-fr',
      npages => 5,
      session => 30,
      'mdevicetypefull-name' => [ 'Linux', 'Windows' ],
      'subkey2-name' => 'SubKey1',
      roots => [
        'metier/des-metiers-qui-recrutent/la-transition-energetique-c-est-quoi',
        'metier/des-metiers-qui-recrutent/',
      ],
    },
    {
      from => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 00:00:00" )',
      to => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/30 23:59:59" )',
      site => 'onisep-fr',
      npages => 5,
      session => 30,
      'mdevicetypefull-name' => [ 'Linux', 'Windows' ],
      'subkey2-name' => [ 'SubKey1', 'SubKey2' ],
      roots => [
        'metier/des-metiers-qui-recrutent/la-transition-energetique-c-est-quoi',
        'metier/des-metiers-qui-recrutent/',
      ],
    },
    {
      from => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 00:00:00" )',
      to => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/30 23:59:59" )',
      site => 'onisep-fr',
      npages => 5,
      session => 30,
      'mdevicetypefull-name' => [ 'Linux', 'Windows' ],
      'subkey2-name' => [ 'SubKey1', 'SubKey2' ],
      'media-id' => 2812,
      'media-shortname' => [ 'Google', 'adblock' ],
      roots => [
        'metier/des-metiers-qui-recrutent/la-transition-energetique-c-est-quoi',
        'metier/des-metiers-qui-recrutent/',
      ],
    },
  );

  # Iterate through setups
  for my $setup ( @setups ) {
    # Forge Eulerian Data Warehouse SQL command.
    my $cmd = API::Eulerian::EDW::UseCases::SanKeyMap::Sql( $setup );
    print( "$cmd\n" );
  }

}
#
# Run main function.
#
main();
