package CppModule;
use English;
use Mouse;
use BuildModule;
use CppTask;
use StaticLibraryTask;
use SharedLibraryTask;
use ExecutableTask;

extends BuildModule;

sub BUILD
{
    my $mod = shift;
    $mod->{INPUTS} = [];
}

# Should return a string containing the output directory for the current module and variant.
sub outputDir
{
    die sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

sub outputFile
{
    my $mod = shift;
    die "outputFile not set" if (!$mod->{OUTPUT_FILE});
    return $mod->{OUTPUT_FILE};
}

sub addToGraph_module
{
    my $mod = shift;
    $mod->addToGraph_cppModule();
}

sub addToGraph_cppModule
{
    die sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

sub addStaticLibrary
{
    my $mod = shift;
    my $libFile = shift;
    push($mod->{INPUTS}, $libFile);
}

sub addInputFile
{
    my $mod = shift;
    my $filename = shift;
    push($mod->{INPUTS}, $filename);
}

sub compile
{
    my $mod = shift;
    my $sourceFile = shift;
    my $lambda = shift;

    my $task = CppTask->new('sourceFile' => $sourceFile, 'outputDir' => $mod->outputDir);
    $mod->compileOverride($task);
    if ($lambda) {
        &$lambda($task);
    }
    $task->emit();
    
    push($mod->{INPUTS}, $task->outputFile);
    
    return $task;
}

sub compileOverride
{
}

sub staticLibrary
{
    my $mod = shift;
    my $outputFileName = shift;
    my $lambda = shift;

    if ($mod->{OUTPUT}) {
        die "Output already selected: $mod->{OUTPUT}";
    }
    if (!$outputFileName) {
        die "You must specify an outputFileName parameter.";
    }

    if ($OSNAME eq "MSWin32") {
        $outputFileName = $outputFileName . ".lib";
    }
    else {
        $outputFileName = 'lib' . $outputFileName . '.a';
    }
    
    my $task = new StaticLibraryTask(outputFileName => $outputFileName, 'outputDir' => $mod->outputDir);
    $mod->staticLibraryOverride($task);
    if ($lambda) {
        &$lambda($task);
    }
    foreach (@{$mod->{INPUTS}}) {
        my $input = $_;
        push($task->{INPUTS}, $input);
    }
    $task->emit();
    
    $mod->{OUTPUT_FILE} = $task->outputFile;
    return $task;
}

sub staticLibraryOverride
{
}

sub sharedLibrary
{
    my $mod = shift;
    my $outputFileName = shift;
    my $lambda = shift;

    if ($mod->{OUTPUT}) {
        die "Output already selected: $mod->{OUTPUT}";
    }
    if (!$outputFileName) {
        die "You must specify an outputFileName parameter.";
    }

    if ($OSNAME eq "MSWin32") {
        $outputFileName = $outputFileName . ".dll";
    }
    else {
        $outputFileName = 'lib' . $outputFileName . '.so';
    }
    
    my $task = new SharedLibraryTask(outputFileName => $outputFileName, outputDir => $mod->outputDir);
    $mod->sharedLibraryOverride($task);
    if ($lambda) {
        &$lambda($task);
    }
    foreach (@{$mod->{INPUTS}}) {
        my $input = $_;
        push($task->{INPUTS}, $input);
    }
    $task->emit();

    $mod->{OUTPUT_FILE} = $task->outputFile;
    return $task;
}

sub sharedLibraryOverride
{
}

sub executable
{
    my $mod = shift;
    my $outputFileName = shift;
    my $lambda = shift;

    if ($mod->{OUTPUT}) {
        die "Output already selected: $mod->{OUTPUT}";
    }
    if (!$outputFileName) {
        die "You must specify an outputFileName parameter.";
    }

    if ($OSNAME eq "MSWin32") {
        $outputFileName = $outputFileName . ".exe";
    }
    else {
        # just use the plain name
    }

    my $task = new ExecutableTask(outputFileName => $outputFileName, outputDir => $mod->outputDir);
    $mod->executableOverride($task);
    if ($lambda) {
        &$lambda($task);
    }
    foreach (@{$mod->{INPUTS}}) {
        my $input = $_;
        push($task->{INPUTS}, $input);
    }
    $task->emit();
    
    $mod->{OUTPUT_FILE} = $task->outputFile;
    return $task;
}

sub executableOverride
{
}

1;
