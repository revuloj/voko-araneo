use eosort_new;

use utf8;

my $sercxata = "agxo";
my $sercxata_eo = shift @ARGV;

#my $sorter = new eosort(dbg=>1);

$sorter = new eosort();


if ($sercxata_eo eq $sercxata) {
  $sercxata = $sorter->remap_ci($sercxata);
  $sercxata_eo = $sercxata;
} else {
  $sercxata = $sorter->remap_ci($sercxata);
  $sercxata_eo = $sorter->remap_ci($sercxata_eo);
}


print "$sercxata\n$sercxata_eo\n";

