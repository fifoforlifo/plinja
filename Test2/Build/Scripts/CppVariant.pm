package MyVariant;
use Mouse;
use Variant;

extends Variant;

my $_fieldDefs = [
    os          => ['windows', 'linux', 'darwin'],
    toolChain   => ['msvc9', 'msvc10', 'msvc11', 'mingw', 'gcc'],
    arch        => ['x86', 'amd64'],
    config      => ['dbg', 'rel'],
];

sub getFieldDefs
{
    return $_fieldDefs;
}

1;
