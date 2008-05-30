#!/usr/bin/perl

use lib '../lib';
use strict;
use warnings;
use URI::Escape;
use Continuity::Monitor;
use Runops::Resume;

=head1 Summary

This is pretty clearly an emulation of the Seaside tutorial.  Except the
overhead for seaside is a bit bigger than this...  I'd say. There is no smoke
or mirrors here, just the raw code. We even implement our own 'prompt'...

This is meant to be as minimal (yet almost useful) example as possible, serving
as a very simple tutorial of the basic functionality.

=cut

use Continuity;
use vars qw( $server );
$server = new Continuity( port => 8080 );
#Continuity::Monitor->new( server => $server, port => 8081 );
#Continuity::Monitor->new( port => 8081 );
$server->loop;

# Ask a question and keep asking until they answer. General purpose prompt.
sub prompt {
  my ($request, $msg, @ops) = @_;
  $request->print("$msg<br>");
  foreach my $option (@ops) {
    $request->print('<a href="?option='.uri_escape($option)."\">$option</a>&nbsp;");
  }
  # Subtle! Halt, wait for next request, and grab the 'option' param
  my $option = $request->next->param('option');
  return $option || prompt($request, $msg, @ops);
}

# Main is invoked when we get a new session
sub main {
  # We are given a handle to get new requests
  my $request = shift;

  # This keeps track of the number we're currently on
  my $counter = 0;

  eval {

  # After we're done with that we enter a loop. Forever.
  while(1) {
      print "Displaying current count and waiting for instructions.\n";
      my $action = prompt($request,"Count: $counter", "++", "--", "REPL");
      print "Got '$action' back from the user.\n";
      if($action eq '--' && $counter == 0) {
        my $choice = prompt($request, "Do you really want to GO NEGATIVE?", "Yes", "No");
        $action = '' if $choice eq 'No';
      }
      $counter++ if $action eq '++';
      $counter-- if $action eq '--';
      if($action eq 'REPL') {
        print STDERR "TIME TO DIE!\n";
        die "Who needs a reason?";
        print STDERR "BACK FROM THE DEAD!!!\n";
      }
      if($counter == 42) {
        $request->print(q{
          <h1>The Answer to Life, The Universe, and Everything</h1>
        });
      }
  }

  };

  if($@) {
    my $repl = Continuity::Monitor::REPL->new( request => $request );
    $repl->repl->run;
    print STDERR "Running resume() ...\n";
    resume();
    print STDERR "back from resume! oh noes!\n";
  }
  print STDERR "Out of loop land!\n";
}

1;

