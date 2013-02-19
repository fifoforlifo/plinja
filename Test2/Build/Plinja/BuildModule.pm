package BuildModule;
use Mouse;
use Carp;
use Variant;
use ModuleMan;

has 'variant' => (is => 'ro', isa => 'Variant');
has 'moduleMan' => (is => 'ro', isa => 'ModuleMan');

sub BUILD
{
    my ($mod) = @_;
    $mod->{MAKE_FILES} = [];
}

sub moduleName
{
    confess sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

sub define
{
    confess sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

sub addToGraph
{
    my $mod = shift;
    if ($mod->{addedToGraph}) {
        croak "Programmer Error: addToGraph called multiple times";
    }
    $mod->{addedToGraph} = 1;

    $mod->define();
}

sub makeFiles
{
    my ($mod) = @_;
    return $mod->{MAKE_FILES};
}

1;
