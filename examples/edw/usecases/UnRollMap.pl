#!/usr/bin/perl
###############################################################################
#
# @brief Tests script of API::Eulerian::EDW::UseCases::UnRollMap::Sql().
#
# @file UnRollMap.pl
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
# Import UnRollMap Sql
#
use API::Eulerian::EDW::UseCases::UnRollMap::Sql;
#
# Main entry point of the script.
#
sub main
{
  my @setups = (
    {
      from => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 00:00:00" )',
      to => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 23:59:59" )',
      site => 'onisep-fr',
      target => 'metier/quiz-quels-metiers-selon-mes-gouts',
    },
    {
      from => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 00:00:00" )',
      to => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 23:59:59" )',
      site => 'onisep-fr',
      target => 'metier/quiz-quels-metiers-selon-mes-gouts',
      npages => 3,
    },
    {
      from => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 00:00:00" )',
      to => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 23:59:59" )',
      site => 'onisep-fr',
      target => 'metier/quiz-quels-metiers-selon-mes-gouts',
      npages => 3,
      npalmares => 10,
    },
    {
      from => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 00:00:00" )',
      to => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 23:59:59" )',
      site => 'onisep-fr',
      target => 'metier/quiz-quels-metiers-selon-mes-gouts',
      npages => 3,
      npalmares => 10,
      'mdevicetypefull-name' => [ 'Desktop', 'Tablet' ],
    },
    {
      from => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 00:00:00" )',
      to => 'strptime( "%Y/%m/%d %H:%M:%S", "Europe/Paris", "2025/11/01 23:59:59" )',
      site => 'onisep-fr',
      target => 'metier/quiz-quels-metiers-selon-mes-gouts',
      npages => 3,
      npalmares => 10,
      'mdevicetypefull-name' => [ 'Desktop', 'Tablet' ],
      'media-id' => 2812,
      'media-shortname' => [ 'se', 'rf' ],
    },
  );

  # Iterate through setups
  for my $setup ( @setups ) {
    # Forge Eulerian Data Warehouse SQL command.
    my $cmd = API::Eulerian::EDW::UseCases::UnRollMap::Sql( $setup );
    print( "$cmd\n" );
  }

}
#
# Run main function.
#
main();
