package revo::wrap;

use warnings; use strict;

# (c) 2008-2026 ĉe Wieland Pusch, Wolfram Diestel
#
# xml = wrap(xml) - tio laŭeble rompas liniojn pli longe ol $columns=100 ĉe spacoj

sub wrap {
  my $t = shift;
  my $r = "";
  my $nl = ""; # evitu enkonduki linirompon antaŭ la unua linio
  my $remainder = "";

  my $separator = "\n";
  my $separator2 = undef;
  my $columns = 100;  # <= lini-longeco...

  my $ll = $columns;
  my $lead = "";

  pos($t) = 0;
  while ($t !~ m{\G(?:\s)*\Z}xgc) { # ignoru malplenajn liniojn

    if ($remainder ne " " and $t =~ m{\G(\s*)}xmgc) {
      $lead = $1; # enŝovo: spacoj ĉe linikomenco
      $ll = $columns - length($1); # maksimuma linilongeco sen enŝovo
#      print "lead=$lead.\n";
    }

    # trovu la plej lastan spacon, linirompon aŭ tekstfinon
    # sur la nuna linio gis la maksimuma linileongeco
    if ($t =~ m{
      \G([^\n]{0,$ll})
      (\s|\n+|\z)
    }xmgc) {
      # kunmetu la linion ĝis tie
      $r .= $nl . $lead . $1;
      # la traktenda resto, komenciĝonta en nova linio
      $remainder = $2;
#      print "1lead=$lead. $1\nremainder=$2.\n";

    # se ne eblas rompi la linion antaŭ la maksimumo
    # ni rompos ĝin en la plej proksima posta ebla loko
    } elsif ($t =~ m{
        \G([^\n]*?)
        (\s|\n+|\z)
    }xmgc) {
      $r .= $nl . $lead . $1;
      $remainder = $2;
#      print "2lead=$lead. $1\nremainder=$2.\n";
    } else {
      # fakte ne povas esti, ke ni ne trovos
      # iun spacsignon aŭ la finon de la teksto
      # krom se ni enkondukis cimon
      die "Ho, tio devis ne okazi!\n";
    }
    $nl = $separator; # linirompo krom ĉe la unua linio
  }
  $r .= $remainder . "\n";

  return $r;
}

1;
