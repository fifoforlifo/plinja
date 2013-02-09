package BuildModule;
use Mouse;
use Carp;
use Variant;

use ModuleMan;

has 'variant' => (is => 'ro', isa => 'Variant');
has 'moduleMan' => (is => 'ro', isa => 'ModuleMan');

sub moduleName
{
    die sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

sub defaultTarget
{
    die sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

sub addToGraph_module
{
    die sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

sub addToGraph
{
    my $mod = shift;
    if ($mod->{addedToGraph}) {
        croak "Programmer Error: addToGraph called multiple times";
    }
    $mod->{addedToGraph} = 1;
    
    $mod->addToGraph_module();
}

1;
