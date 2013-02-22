package MyVariant;
use Mouse;
use Variant;

extends Variant;

my $_fieldDefs;

if ($^O eq "MSWin32") {
    $_fieldDefs = [
        os          => ['windows'],
        toolChain   => ['msvc9', 'msvc10', 'msvc11', 'mingw64'],
        arch        => ['x86', 'amd64'],
        config      => ['dbg', 'rel'],
        crt         => ['scrt', 'dcrt'],
    ];
}
elsif ($^O eq "linux") {
    $_fieldDefs = [
        os          => ['linux'],
        toolChain   => ['gcc'],
        arch        => ['x86', 'amd64'],
        config      => ['dbg', 'rel'],
        crt         => ['scrt', 'dcrt'],
    ];
}
else {
    die "unsupported build OS";
}

sub getFieldDefs
{
    return $_fieldDefs;
}

1;
