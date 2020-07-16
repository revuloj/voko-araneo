use eosort;

use utf8;

my $sercxata = "acxeti";
#my $sercxata_eo = "ĉevalo";
my $sercxata_eo = shift @ARGV;
utf8::decode $sercxata_eo;

my $sorter = new eosort(dbg=>1);

if ($sercxata_eo eq $sercxata) {
  $sercxata = $sorter->remap_ci($sercxata);
  $sercxata_eo = $sercxata;
} else {
  $sercxata = $sorter->remap_ci($sercxata);
  $sercxata_eo = $sorter->remap_ci($sercxata_eo);
}


print "$sercxata\n$sercxata_eo\n";

