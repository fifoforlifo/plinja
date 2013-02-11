package SharedLibraryTask;
use Mouse;
use BuildTask;

extends BuildTask;

has outputFileName => (is => 'ro');
has outputDir => (is => 'ro');

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
    my $task = shift;
    my $fh = shift;

    my $outputFile = $task->outputFile;
    print("$outputFile: \\\n");
    foreach (@{$task->inputs}) {
        my $input = $_;
        print("  $input \\\n");
    }
}

1;
