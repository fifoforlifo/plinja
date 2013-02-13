package ModuleMan;
use Mouse;
use File::Basename;
use Module::Util qw(find_installed);
use RootPaths;

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

    $mod = $moduleName->new(moduleMan => $moduleMan, variant => $variant);
    $mod->{MODULE_DIR} = dirname(find_installed($moduleName));
    $mod->{OUTPUT_DIR} = File::Spec->catdir($rootPaths{'Built'}, $rootPaths{$moduleName . "_rel"}, $variant->str);

    $moduleMan->{names}->{$moduleName}->{$variant->str} = $mod;
    $mod->addToGraph();
    return $mod;
}

1;
