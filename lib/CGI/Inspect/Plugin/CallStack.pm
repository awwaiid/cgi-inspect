package CGI::Inspect::Plugin::CallStack;

use strict;
use base 'CGI::Inspect::Plugin';
use Devel::StackTrace::WithLexicals;
use Data::Dumper;

sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  $self->{trace} = Devel::StackTrace::WithLexicals->new;
  return $self;
}

sub print_trace {
  my $self = shift;
  my $output = "<div class=dialog id=stacktrace title='Stacktrace'><ul>";
  my $trace = $self->{trace};
  $trace->reset_pointer;
  my $frame_index = 0;
  my $frame;
  while($frame = $trace->next_frame) {
    last if $frame->package() !~ /^(Continuity|Coro|CGI::Inspect)/;
    $frame_index++;
  }
  my $next_frame = $frame;
  while($next_frame = $trace->next_frame) {
    $output .= "<li>" . $next_frame->subroutine
      . " (" . $next_frame->filename . ":" . $next_frame->line . ")"
    ;
    $output .= $self->print_lexicals($frame->lexicals, $frame_index);
    $output .= "</li>";
    $frame = $next_frame;
    $frame_index++;
  }
  $output .= "</ul></div>";
  return $output;
}

sub print_lexicals {
  my ($self, $lexicals, $frame_index) = @_;
  my $output = '<ul>';
  local $Data::Dumper::Terse = 1;

  foreach my $var (sort keys %$lexicals) {
    my $val = Dumper(${ $lexicals->{$var} });
    my $out;
    my $save_button = $self->request->callback_submit(
      Save => sub {
        my $val = $self->param('blah');
        $out = qq{got: $val};
        print STDERR "val: $val\n";
      }
    );
    my $edit_link = $self->request->callback_link(
      Edit => sub {
        $out = qq{<input type=text name=blah value="$val">$save_button};
      }
    );
    #$out ||= "<li><pre>$var = $val</pre>$edit_link</li>";
    $out ||= "<li><pre>$var = $val</pre></li>";
    $output .= "<li>$out</li>";
  }

  $output .= "</ul>";
  return $output;
}


sub process {
  my ($self) = @_;
  return $self->print_trace;
}

1;

