package revo::wrap;

use warnings; use strict;

sub wrap {
  my $t = shift;
  my $r = "";
  my $nl = "";
  my $remainder = "";

  my $separator = "\n";
  my $separator2 = undef;
  my $columns = 100;  # <= lini-longeco...

  my $ll = $columns;
  my $lead = "";

  pos($t) = 0;
  while ($t !~ m{\G(?:\s)*\Z}xgc) {
    if ($remainder ne " " and $t =~ m{\G(\s*)}xmgc) {
      $lead = $1;
      $ll = $columns - length($1);
#      print "lead=$lead.\n";
    }

    if ($t =~ m{
      \G([^\n]{0,$ll})
      (\s|\n+|\z)
    }xmgc) {
      $r .= $nl . $lead . $1;
      $remainder = $2;
#      print "1lead=$lead. $1\nremainder=$2.\n";
    } elsif ($t =~ m{
        \G([^\n]*?)
        (\s|\n+|\z)
    }xmgc) {
      $r .= $nl . $lead . $1;
      $remainder = $2;
#      print "2lead=$lead. $1\nremainder=$2.\n";
    } else {
      die "Ho, tio devis ne okazi!\n";
    }
    $nl = $separator;
  }
  $r .= $remainder . "\n";

  return $r;
}

1;
