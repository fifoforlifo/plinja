package ModuleMan;
use Mouse;

sub getModule
{
    my ($moduleMan, $moduleName, $variant) = @_;

    my $mod = $moduleMan->{names}->{$moduleName}->{$variant->str};
    return $mod;
}

# get-or-create Module
sub gorcModule
{
    my ($moduleMan, $moduleName, $variant) = @_;
    
    my $mod = $moduleMan->getModule($moduleName, $variant);
    if ($mod) {
        return $mod;
    }

    # pull module into scope as needed
    eval "require $moduleName";

    $mod = $moduleName->new('moduleMan' => $moduleMan, 'variant' => $variant);
    $moduleMan->{names}->{$moduleName}->{$variant->str} = $mod;
    $mod->addToGraph();
    return $mod;
}

1;
