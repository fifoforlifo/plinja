package MyVariant;
use Mouse;
use Variant;

extends Variant;

my $_fieldDefs = [
    'toolchain' => ['msvc9-x86', 'msvc9-amd64', 'msvc10-x86', 'msvc10-amd64', 'gcc4.6-x86'],
    'config'    => ['dbg', 'rel']
];

sub getFieldDefs
{
    return $_fieldDefs;
}

1;
