# Redactions in retained cluster evidence

Authentication values are removed from the committed copies. Each row gives the original file's SHA-256, which the
retrieval checksums refer to, and the hash of the committed copy. Nothing else in a file changes. Originals are kept
outside the repository by `scripts/redact_evidence.py`, readable by the owner only, and remain on Vanda in the clone
that wrote them. Copies committed before 6 Nov 2026 also remain unredacted in this repository's earlier commits,
which are not rewritten.

| File | Field | Original SHA-256 | Committed SHA-256 |
|---|---|---|---|
| `artifacts/cluster/runs/bench16-20261105T092045Z-1523703/env/environment.txt` | `PBS_JOBCOOKIE` | `dc380e0ac28d23cc6584099e99bfaa9dd40eeaba5df086b73307dd17e3ea70f6` | `08c32d4a2ef4e159ecbdb714a33dc0530daeb4308b78ea5f2cfa5a46d6d22197` |
| `artifacts/cluster/runs/correctness-20261028T123124Z-1503779/env/environment.txt` | `PBS_JOBCOOKIE` | `40f51f57ac3f5f59e56461998f7d4356d11d2fd0a914334c3366870ef5a6237f` | `1032a8eaff1a079888d3b18e013da3756c1f81cae59b7493ee69f6165620f16e` |
| `artifacts/cluster/runs/diag-20261103T073541Z-1513781/env/environment.txt` | `PBS_JOBCOOKIE` | `8ad5c28d3a9884f3d7f456a8f0d1c87e75f098c5e51354113a9a218bc55dbca2` | `44c5b5f03938ad769d75aabace0ac5ff6b38f22614a37e469cbde162a048ef27` |
| `artifacts/cluster/runs/diag-20261103T082648Z-1514029/env/environment.txt` | `PBS_JOBCOOKIE` | `bb5290e3196a2e45566a6cc892e8b76f520556c4ae4a9f4b7f5eb69ec2b69cad` | `db319fb417531eafb4fc8fc8ca0756ada74818d266b8c495262f26c979431ef0` |
| `artifacts/cluster/runs/gpu_timing-20261104T111747Z-1519638/env/environment.txt` | `PBS_JOBCOOKIE` | `5fa4d76cd43ac1c27d9a7fdb8b9f6e4c2d4d1d770f1050afcf4fb39b577781de` | `1274f1c2baccb06592933dc1398dbfe59c097426739ee3269f05769898af0ed2` |
| `artifacts/cluster/runs/gpu_validate-20261103T134410Z-1514775/env/environment.txt` | `PBS_JOBCOOKIE` | `79fe6dc9fc8517d2b54733957f27c807f8fc05602054970f4c60746a2022647f` | `283ac12272a4947d8c15c2b996f30d7bfae146eb40fe3317bf3a5d0dc9078a0c` |
| `artifacts/cluster/runs/pilot1-20261104T211117Z-1519637/env/environment.txt` | `PBS_JOBCOOKIE` | `64d37646c9ba02565372dec9e9b247f29dd3a3083c6b0a6c4472c2f363540b86` | `2bc1ffd22447a9c4030e678a001a1ad1d58c6c94be71faf6ea7cfd4d6e7dd5d9` |
| `artifacts/cluster/runs/pilot1-20261105T093901Z-1522998/env/environment.txt` | `PBS_JOBCOOKIE` | `03abb2f373fec6916651b8b3f594f31de8bc05340c709fa4ac755aa905095e44` | `b6a3c09e991f2e334590c581584106da3697f4c62bd23ff8e9076b06a31277ca` |
| `artifacts/cluster/runs/pilot16-20261105T063623Z-1523275/env/environment.txt` | `PBS_JOBCOOKIE` | `746362b8935bd99fe6e76447e38c96f8511195152ccdd90e5442b65dfe8f6262` | `4cb078176be09d50c57c9129c1484309fad60a06e6e44d81ff2c6d976b827fef` |
| `artifacts/cluster/runs/twonode-20261029T053005Z-1506687/env/environment.txt` | `PBS_JOBCOOKIE` | `2d493e843c6e8d7518608a4cb8e73b0e31b80e116f20b8d6e5b83d11e9852583` | `a4718b475f4b6a9348aa22e79153ef4e0d6d0e74e4a8bc2bfdc3e7e118942c23` |
| `artifacts/cluster/runs/twonode-20261029T071525Z-1507215/env/environment.txt` | `PBS_JOBCOOKIE` | `6fd539e3cc9eb771700d407b13c6d2240f71d42e8819d225e058e875d24f6b94` | `cf5db538462cc4635468ad580376596cdfe4c12e16a29f6ee67a6ef605f3b9fe` |
| `artifacts/cluster/runs/twonode-20261103T102750Z-1514458/env/environment.txt` | `PBS_JOBCOOKIE` | `ad5c5c74653aff205c575f5076ad08cfe4777ce79a175a9fc2c5e85536df5e7c` | `ae893f05ab73493929c678f713bbcc9c4dd0a87fed5b8cc866648e39727c4f01` |
| `artifacts/cluster/runs/pilot2-20261106T233758Z-1526470/env/environment.txt` | `PBS_JOBCOOKIE` | `b747553e97ba6faa954048c9651b33897afc7fb2804d176d510b10098abb5ec2` | `2aa8b84d6f834404e31a9b5f888a9936953ec72887020a03b0849d31e1251906` |
| `artifacts/cluster/runs/bench1-20261106T130250Z-1526501/env/environment.txt` | `PBS_JOBCOOKIE` | `cc3f4926d3f10ba6b49f201a37c70d6bbe0ebadf2e3a1bc5c7ebcfc273a5e42e` | `7e6ea7ad574528e180b2ebc4e9c764141498dd1740216b63e435dd8da8ac4263` |
| `artifacts/cluster/runs/bench1-20261107T033925Z-1528774/env/environment.txt` | `PBS_JOBCOOKIE` | `9f4761e1b1524d29ca8beda066b3b7faedebde67b70ed4bac557f1fc6fa15cb3` | `9a9d638e906ceb85321207faaae577ccb19bfd08e77305c239e38f52c9071f88` |
| `artifacts/cluster/runs/pilot4-20261110T094241Z-1535640/env/environment.txt` | `PBS_JOBCOOKIE` | `9eba7501bf94f67d3f55578b62ec516b2af060bbe62d2af609c921dc412cc8d5` | `8cba11cba582932ff44063c8178bb632ca26f278eb87de3b7d54522d9bd97d6d` |
| `artifacts/cluster/runs/bench4-20261110T103706Z-1535991/env/environment.txt` | `PBS_JOBCOOKIE` | `b5a0f1b46efdf4d35c64c8528ad62818a1206717f4044397050666df7e9a486d` | `b40ed7295189d4341b67070552cd644921f187d9a02fbaaee433ad5befbcb8ce` |
