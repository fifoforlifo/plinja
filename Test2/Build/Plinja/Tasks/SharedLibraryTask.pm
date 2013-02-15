package SharedLibraryTask;
use Mouse;
use BuildTask;

extends BuildTask;

has outputFileName => (is => 'ro');
has outputDir => (is => 'ro');
has workingDir => (is => 'ro');

sub BUILD
{
    my $task = shift;
    if (!$task->outputDir) {
        die "outputDir not defined";
    }
    $task->{INPUTS} = [];
}

sub inputs
{
    my $task = shift;
    return $task->{INPUTS};
}

sub outputFile
{
    my $task = shift;
    my $outputFile = File::Spec->catfile($task->outputDir, $task->outputFileName);
    return $outputFile;
}

sub emit
{
    my ($task, $toolChain, $FH) = @_;
    $toolChain->emitSharedLibrary($FH, $task);
}

1;
