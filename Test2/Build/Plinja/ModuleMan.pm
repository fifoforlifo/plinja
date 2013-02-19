package ModuleMan;
use Mouse;
use File::Basename;
use Module::Util qw(find_installed);
use RootPaths;

has 'FH' => (is => 'ro');

sub getModule
{
    my ($moduleMan, $moduleName, $variant) = @_;

    my $mod = $moduleMan->{MODULES}->{$moduleName}->{$variant->str};
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

    $moduleMan->{MODULES}->{$moduleName}->{$variant->str} = $mod;
    $mod->addToGraph();
    return $mod;
}

sub getToolChain
{
    my ($moduleMan, $toolChainName) = @_;
    my $toolChain = $moduleMan->{TOOL_CHAINS}->{$toolChainName};
    return $toolChain;
}

sub addToolChain
{
    my ($moduleMan, $toolChain) = @_;

    if ($moduleMan->getToolChain($toolChain->name)) {
        confess "$toolChain already exists";
    }

    $moduleMan->{TOOL_CHAINS}->{$toolChain->name} = $toolChain;
}

sub emitRules
{
    my ($moduleMan, $FH) = @_;

    while (my ($toolChainName, $toolChain) = each %{$moduleMan->{TOOL_CHAINS}}) {
        $toolChain->emitRules($moduleMan->FH);
    }
}

sub getModules
{
    my ($moduleMan) = @_;
    my $modules = [];
    while (my ($moduleName, $variantToMod) = each %{$moduleMan->{MODULES}}) {
        while (my ($variantStr, $mod) = each %{$variantToMod}) {
            push(@$modules, $mod);
        }
    }
    return $modules;
}

1;
