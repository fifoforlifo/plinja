package ToolChain;
use Mouse;

has name => (is => 'ro');

sub emitRules
{
    die sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

1;
