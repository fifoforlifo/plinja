package ModuleMan;
use Mouse;
use File::Basename;
use Module::Util qw(find_installed);
use RootPaths;
use Plinja;

has 'FH' => (is => 'ro');

sub findModule
{
    my ($moduleMan, $moduleName, $variant) = @_;

    my $mod = $moduleMan->{MODULES}->{$moduleName}->{$variant->str};
    return $mod;
}

# get or create module for $variant
sub getModule
{
    my ($moduleMan, $moduleName, $variant) = @_;

    my $mod = $moduleMan->findModule($moduleName, $variant);
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
    my ($moduleMan) = @_;
    my $FH = $moduleMan->FH;

    print($FH "#############################################\n");
    print($FH "# CUSTOM_COMMAND\n");
    print($FH "\n");
    print($FH "rule CUSTOM_COMMAND\n");
    print($FH "  command = \$COMMAND \n");
    print($FH "  description = \$DESC\n");
    print($FH "  restat = 1\n");
    print($FH "\n");

    while (my ($toolChainName, $toolChain) = each %{$moduleMan->{TOOL_CHAINS}}) {
        $toolChain->emitRules($FH);
    }
}

# %info = {
#   COMMAND => "",
#   DESC => "",
#   INPUTS => [],
#   OUTPUTS => [],
# }
sub emitCustomCommand
{
    my ($moduleMan, $FH, $info) = @_;

    print($FH "build \$\n");
        for my $output (@{$info->{OUTPUTS}}) {
            my $outputEsc = Plinja::ninjaEscapePath($output);
            print($FH "    $outputEsc \$\n");
        }
        print($FH "  : CUSTOM_COMMAND");
        for my $input (@{$info->{INPUTS}}) {
            my $inputEsc = Plinja::ninjaEscapePath($input);
            print($FH " \$\n    $inputEsc");
        }
        print($FH "\n");
    print($FH "  COMMAND = ${$info->{COMMAND}}\n");
    print($FH "  DESC = ${$info->{DESC}}\n");
    print($FH "\n");
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
