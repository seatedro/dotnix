let
  ro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC+4G43cH27B5ploQx8E+E3gqSKDCHcZ7OJixe/veR4j git@seated.ro";
  forge = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKeTuU6sVhTxrW+G2i6f3uVA5/qEkzn1pmvyctC1tnC0 root@forge";
in
{
  "vanta-agent-key.age".publicKeys = [
    ro
    forge
  ];
}
