package ExecutableTask;
use Mouse;
use BuildTask;

extends BuildTask;

has outputFile => (is => 'ro');

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

1;
