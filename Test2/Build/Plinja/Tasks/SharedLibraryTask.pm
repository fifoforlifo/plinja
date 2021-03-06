package SharedLibraryTask;
use Mouse;
use BuildTask;

extends BuildTask;

has outputFile => (is => 'ro');
has libraryFile => (is => 'ro');
has workingDir => (is => 'ro');

# common options (across all toolchains)
has extraOptions => (is => 'ro', default => sub { [] });
has keepDebugInfo => (is => 'rw', default => 1);

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
    $toolChain->emitSharedLibrary($FH, $mod, $task);
}

1;
