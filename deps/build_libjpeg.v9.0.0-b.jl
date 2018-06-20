using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, String["libjpeg"], :libjpeg),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/SimonDanisch/LibJPEGBuilder/releases/download/v9b"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/libjpeg.v9.0.0-b.aarch64-linux-gnu.tar.gz", "c16bf68080646df79b30be93742a21417dcf424f01b125b015da3f98e3040681"),
    Linux(:aarch64, :musl) => ("$bin_prefix/libjpeg.v9.0.0-b.aarch64-linux-musl.tar.gz", "2ee2b96e9cd95ac4ccb6008a92e0594c1103d582ab35004366a521986e963be5"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/libjpeg.v9.0.0-b.arm-linux-gnueabihf.tar.gz", "370e76335dc42c9049c0b28eaff6a2289ea6009611e659c949ede6293c941e49"),
    Linux(:armv7l, :musl, :eabihf) => ("$bin_prefix/libjpeg.v9.0.0-b.arm-linux-musleabihf.tar.gz", "3fb254a91419a540ce83024764d42d4cc2dd90fd01b734647a10f9531d88584c"),
    Linux(:i686, :glibc) => ("$bin_prefix/libjpeg.v9.0.0-b.i686-linux-gnu.tar.gz", "597b07c5839f4b1be148e66f54138a2bbb823e90479591d9da581c55498043f8"),
    Linux(:i686, :musl) => ("$bin_prefix/libjpeg.v9.0.0-b.i686-linux-musl.tar.gz", "334719ed926aa53e8fb15d540008a63b4fa5b69928a2a732df99309e17f007a0"),
    Windows(:i686) => ("$bin_prefix/libjpeg.v9.0.0-b.i686-w64-mingw32.tar.gz", "6cc83c065fd15a5ad13de05c63294abb50269dfa03e56aaf7df6251ed59d585e"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/libjpeg.v9.0.0-b.powerpc64le-linux-gnu.tar.gz", "cd7be3bba1af729d1aeacd66555a7b9b6aa43225a5e8df42b8352f990de15b5b"),
    MacOS(:x86_64) => ("$bin_prefix/libjpeg.v9.0.0-b.x86_64-apple-darwin14.tar.gz", "060ae7e82ae4bcd8342c00326f4c7b784897720a15372a06cb3a1f26ec6869c3"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/libjpeg.v9.0.0-b.x86_64-linux-gnu.tar.gz", "8512bd2971e8d3d5d1e236e2efc4bba8c52ec12a919a8c44a2e6a7b515136b24"),
    Linux(:x86_64, :musl) => ("$bin_prefix/libjpeg.v9.0.0-b.x86_64-linux-musl.tar.gz", "b11b1d832c90b7627b6422b8e83c6d6348ed8eeed350971861313277d07501db"),
    FreeBSD(:x86_64) => ("$bin_prefix/libjpeg.v9.0.0-b.x86_64-unknown-freebsd11.1.tar.gz", "aaf30ea9cd2afeed96e99da75cef734d74ef181bca93885594515109ab9d0c13"),
    Windows(:x86_64) => ("$bin_prefix/libjpeg.v9.0.0-b.x86_64-w64-mingw32.tar.gz", "89ed58e379c4b5edd029ec97426ce562511504158605c82bded8a198d9bba5f9"),
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
write_deps_file(joinpath(@__DIR__, "deps_jpeg.jl"), products)
