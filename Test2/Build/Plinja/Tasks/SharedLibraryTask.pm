package SharedLibraryTask;
use Mouse;
use BuildTask;

extends BuildTask;

has outputFile => (is => 'ro');
has libraryFile => (is => 'ro');
has workingDir => (is => 'ro');
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
    my ($task, $toolChain, $FH) = @_;
    $toolChain->emitSharedLibrary($FH, $task);
}

1;
