using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libogg"], :libogg),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/staticfloat/OggBuilder/releases/download/v1.3.3-7"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/Ogg.v1.3.3.aarch64-linux-gnu.tar.gz", "f1439f0bef74e6992a355bb0119acbb5a97814b64b6a22547cbc37b67bc25760"),
    Linux(:aarch64, :musl) => ("$bin_prefix/Ogg.v1.3.3.aarch64-linux-musl.tar.gz", "5e2c5a97edb8ebac76ba9efe7db0f1bccf13be271e2d7a7ebdc819b5b71ce333"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/Ogg.v1.3.3.arm-linux-gnueabihf.tar.gz", "896e80735ab987d4c09764bd40526de6ced5be6513ca9c5b3ca81e755d06eba5"),
    Linux(:armv7l, :musl, :eabihf) => ("$bin_prefix/Ogg.v1.3.3.arm-linux-musleabihf.tar.gz", "f6019e9addb1b89ee6ee033d6c7931ed4247b49a939c8b808913ebb62a1a1bd5"),
    Linux(:i686, :glibc) => ("$bin_prefix/Ogg.v1.3.3.i686-linux-gnu.tar.gz", "4e8932bbeea9b3b6a09955274e019356a2f0f54b65c1bbbd63c24da42b8660c3"),
    Linux(:i686, :musl) => ("$bin_prefix/Ogg.v1.3.3.i686-linux-musl.tar.gz", "7ce598fad16f91a1348d914dea465b3d8f1c3ca5234d7225d13d9461bc9097c8"),
    Windows(:i686) => ("$bin_prefix/Ogg.v1.3.3.i686-w64-mingw32.tar.gz", "d962cd608e8cd4f2d9c1fd55a972f9fa009eaba3d5c0499afac58c5368e83296"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/Ogg.v1.3.3.powerpc64le-linux-gnu.tar.gz", "85b3fa46e017ea3a8a4f5d4ddca0b7811e842cc6da1a881972fe692af423ab59"),
    MacOS(:x86_64) => ("$bin_prefix/Ogg.v1.3.3.x86_64-apple-darwin14.tar.gz", "8675490424561ed8c62f1f00984b1784e6587b0106e8e79ab31412a4a1b30b30"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/Ogg.v1.3.3.x86_64-linux-gnu.tar.gz", "63672bf4233f3d56a984a0e01d29fdf4a491f02eba8637f444387264632c0e65"),
    Linux(:x86_64, :musl) => ("$bin_prefix/Ogg.v1.3.3.x86_64-linux-musl.tar.gz", "2cf5c429afd13644a5fd864ee47e6155bd1eac1108df50e6047e785810522e22"),
    FreeBSD(:x86_64) => ("$bin_prefix/Ogg.v1.3.3.x86_64-unknown-freebsd11.1.tar.gz", "4f9cdbbfc3770d5fbad7367537cb78b97cd2a988a53d62f0ca826bdc4ee09d6b"),
    Windows(:x86_64) => ("$bin_prefix/Ogg.v1.3.3.x86_64-w64-mingw32.tar.gz", "143628e52347de1f32dce4bcb224cc7e595391b96c45a9eacea51e766066176c"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps_codec.jl"), products)
