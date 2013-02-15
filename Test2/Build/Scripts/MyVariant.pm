package MyVariant;
use Mouse;
use Variant;

extends Variant;

my $_fieldDefs = [
    'toolChain' => ['msvc9_x86', 'msvc9_amd64', 'msvc10_x86', 'msvc10_amd64', 'msvc11_x86', 'msvc11_amd64', 'mingw_x86'],
    'config'    => ['dbg', 'rel']
];

sub getFieldDefs
{
    return $_fieldDefs;
}

1;
