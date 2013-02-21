package StaticLibraryTask;
use Mouse;
use File::Spec;
use BuildTask;

extends BuildTask;

has outputFile => (is => 'ro');
has workingDir => (is => 'ro');

# common options (across all toolchains)
has extraOptions => (is => 'ro', default => sub { [] });

sub BUILD
{
    my $task = shift;
    $task->{INPUTS} = [];
}

sub inputs
{
    my $task = shift;
    return $task->{INPUTS};
}

sub emit
{
    my ($task, $toolChain, $FH, $mod) = @_;
    $toolChain->emitStaticLibrary($FH, $mod, $task);
}

1;
