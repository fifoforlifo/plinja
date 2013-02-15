package StaticLibraryTask;
use Mouse;
use File::Spec;
use BuildTask;

extends BuildTask;

has outputFile => (is => 'ro');
has workingDir => (is => 'ro');

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
    $toolChain->emitStaticLibrary($FH, $task);
}

1;
