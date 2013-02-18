package ModuleMan;
use Mouse;
use File::Basename;
use Module::Util qw(find_installed);
use RootPaths;

has 'FH' => (is => 'ro');

sub getModule
{
    my ($moduleMan, $moduleName, $variant) = @_;

    my $mod = $moduleMan->{modules}->{$moduleName}->{$variant->str};
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

    $mod = $moduleName->new(moduleMan => $moduleMan, variant => $variant);
    $mod->{MODULE_DIR} = dirname(find_installed($moduleName));
    $mod->{OUTPUT_DIR} = File::Spec->catdir($rootPaths{'Built'}, $rootPaths{$moduleName . "_rel"}, $variant->str);

    $moduleMan->{modules}->{$moduleName}->{$variant->str} = $mod;
    $mod->addToGraph();
    return $mod;
}

sub getToolChain
{
    my ($moduleMan, $toolChainName) = @_;
    my $toolChain = $moduleMan->{toolChains}->{$toolChainName};
    return $toolChain;
}

sub addToolChain
{
    my ($moduleMan, $toolChain) = @_;

    if ($moduleMan->getToolChain($toolChain->name)) {
        confess "$toolChain already exists";
    }

    $moduleMan->{toolChains}->{$toolChain->name} = $toolChain;
}

sub emitRules
{
    my ($moduleMan, $FH) = @_;

    foreach my $toolChainName (keys %{$moduleMan->{toolChains}}) {
        my $toolChain = $moduleMan->{toolChains}->{$toolChainName};
        $toolChain->emitRules($moduleMan->FH);
    }
}

1;
