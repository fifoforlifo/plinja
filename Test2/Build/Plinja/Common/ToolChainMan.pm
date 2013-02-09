package ToolChainMan;
use Mouse;

sub getToolChain
{
    my ($toolChainMan, $toolChainName) = @_;
    my $toolChain = $toolChainMan->{names}->{$toolChainName};
    return $toolChain;
}

# get-or-create Module
sub gorcToolChain
{
    my ($toolChainMan, $toolChainName) = @_;
    
    my $toolChain = $moduleMan->getToolChain($toolChainName);
    if ($toolChain) {
        return $toolChain;
    }

    # pull module into scope as needed
    eval "require $toolChainName";

    $toolChain = $toolChainName->new();
    $toolChainMan->{names}->{$toolChainName} = $toolChain;
    return $toolChain;
}

1;
