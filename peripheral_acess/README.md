# Generate rust PAC

## Install dependencies
```bash
cargo install svd2rust
```

## Refresh PAC
```bash
svd2rust --nightly -i ../build/basys3.svd
rm -rf src
form -i lib.rs -o src/ && rm lib.rs
cargo fmt
```

