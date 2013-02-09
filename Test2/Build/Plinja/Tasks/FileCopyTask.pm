package FileCopyTask;
use Mouse;
use Carp;
use File::Basename;
use File::Spec;
use BuildTask;

extends BuildTask;

has inputFile => (is => 'ro');
has outputDir => (is => 'ro');
has outputFile => (is => 'ro');

sub BUILD
{
    my $task = shift;
    if (!$inputFile) {
        croak "You need to specify inputFile.";
    }
    if (!$task->outputDir && !$task->outputFile) {
        croak "You need to specify either outputDir or outputFile.";
    }
}

sub outputBasePath
{
    my $task = shift;
    return $task->{OUTPUT_BASE_PATH};
}

1;
