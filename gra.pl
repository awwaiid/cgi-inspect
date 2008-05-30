#!/usr/bin/perl -w

use lib 'lib';
use Devel::Graph;

my $code = shift || 'examples/test';
my $format = shift || 'as_ascii';
my $debug = shift;

my $a = $code;
$a = \$code unless -f $code;		# code or file?

if ($debug)
  {
  require PPI::Dumper;
  PPI::Dumper->new(PPI::Document->new($a), whitespace => 0)->print();
  }

my $grapher = Devel::Graph->new();
my $gr = $grapher->graph($a);

print STDERR "Resulting graph has ", 
	scalar $gr->nodes(), " nodes and ", 
	scalar $gr->edges()," edges:\n\n";

binmode STDOUT, ':utf8' or die ("binmode STDERR, ':utf8' failed: $!");
print $gr->$format();
