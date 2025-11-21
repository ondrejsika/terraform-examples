resource "slr_dogsay" "woof" {
  text = chomp(<<EOT
Woof Woof! I'm Dela,
follow me on Instagram @jsemdela!
EOT
  )
}

output "woof" {
  value = slr_dogsay.woof.output
}

resource "slr_dogsay" "woof2" {
  text = slr_dogsay.woof.output
}

output "woof2" {
  value = slr_dogsay.woof2.output
}
