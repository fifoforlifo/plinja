package CppTask;
use Mouse;
use File::Basename;
use File::Spec;
use BuildTask;

extends BuildTask;

has sourceFile => (is => 'ro');
has outputDir => (is => 'ro');
has optLevel => (is => 'rw');
has debugLevel => (is => 'rw');

sub BUILD
{
    my $task = shift;
    if (!$task->outputDir) {
        die "outputDir not defined";
    }
    $task->{INCLUDE_PATHS} = [];
}

sub includePaths
{
    my $task = shift;
    return $task->{INCLUDE_PATHS};
}

sub outputFile
{
    my $task = shift;
    my $outfile;
    if ($task->outputDir) {
        $outfile = File::Spec->join($task->outputDir, $task->sourceFile) . ".o";
    }
    else {
        $outfile = File::Spec->join(dirname(__FILE__), $task->sourceFile) . ".o";
    }
    return $outfile;
}

sub emit
{
    my $task = shift;

    my $outputFile = $task->outputFile;
    my $sourceFile = $task->sourceFile;
    print("$outputFile: $sourceFile\n");
}

1;
