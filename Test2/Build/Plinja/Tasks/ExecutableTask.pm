package ExecutableTask;
use Mouse;
use BuildTask;

extends BuildTask;

has outputFile => (is => 'ro');
has workingDir => (is => 'ro');

sub BUILD
{
    my $task = shift;
    $task->{INPUTS} = [];
    $task->{LIBPATHS} = [];
}

sub inputs
{
    my $task = shift;
    return $task->{INPUTS};
}

sub libPaths
{
    my $task = shift;
    return $task->{LIBPATHS};
}

sub emit
{
    my ($task, $toolChain, $FH) = @_;
    $toolChain->emitExecutable($FH, $task);
}

1;
