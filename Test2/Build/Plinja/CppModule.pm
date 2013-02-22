package CppModule;

use English;
use Mouse;
use BuildModule;
use CppTask;
use StaticLibraryTask;
use SharedLibraryTask;
use ExecutableTask;
use File::Spec;
use File::Basename;
use RootPaths;
use Carp;


extends BuildModule;


sub BUILD
{
    my ($mod) = @_;
    $mod->{INPUTS} = [];
}

sub toolChain
{
    confess sprintf("you need to implement %s::%s", $_[0], (caller(0))[3]);
}

sub outputDir
{
    my $mod = shift;
    return $mod->{OUTPUT_DIR};
}

sub outputFile
{
    my ($mod) = @_;
    confess "outputFile not set" if (!$mod->{OUTPUT_FILE});
    return $mod->{OUTPUT_FILE};
}

sub libraryFile
{
    my ($mod) = @_;
    confess "libraryFile not set" if (!$mod->{OUTPUT_FILE});
    return $mod->{LIBRARY_FILE};
}

sub addInputLibrary
{
    my ($mod, $libFile) = @_;
    $mod->addInputFile($libFile);
}

sub addInputFile
{
    my ($mod, $filename) = @_;
    push(@{$mod->{INPUTS}}, $filename);
}

sub compile
{
    my ($mod, $sourceFile, $lambda) = @_;

    my $objectFile;
    if (File::Spec->file_name_is_absolute($sourceFile)) {
        $objectFile = File::Spec->catfile($mod->{OUTPUT_DIR}, basename($sourceFile) . ".o");
    }
    else {
        $objectFile = File::Spec->catfile($mod->{OUTPUT_DIR}, $sourceFile . ".o");
        $sourceFile = File::Spec->catfile($mod->{MODULE_DIR}, $sourceFile);
    }

    my $task = CppTask->new(sourceFile => $sourceFile, objectFile => $objectFile, workingDir => $mod->{MODULE_DIR});
    $mod->setCompileOptions($task);
    if ($lambda) {
        &$lambda($mod, $task);
    }
    $task->emit($mod->toolChain, $mod->moduleMan->FH, $mod);

    $mod->addInputFile($task->outputFile);
    return $task;
}

sub setCompileOptions
{
    my ($mod, $task) = @_;
}

sub staticLibrary
{
    my ($mod, $outputFileName, $lambda) = @_;

    if ($mod->{OUTPUT}) {
        die "Output already selected: $mod->{OUTPUT}";
    }
    if (!$outputFileName) {
        die "You must specify an outputFileName parameter.";
    }

    my $outputFile = File::Spec->catfile($mod->outputDir, $outputFileName);
    $mod->{LIBRARY_FILE} = $outputFile;

    my $task = new StaticLibraryTask(outputFile => $outputFile, workingDir => $mod->{MODULE_DIR});
    $mod->setStaticLibraryOptions($task);
    if ($lambda) {
        &$lambda($task);
    }
    foreach (@{$mod->{INPUTS}}) {
        my $input = $_;
        push(@{$task->inputs}, $input);
    }
    $task->emit($mod->toolChain, $mod->moduleMan->FH, $mod);

    $mod->{OUTPUT_FILE} = $task->outputFile;
    return $task;
}

sub setStaticLibraryOptions
{
    my ($mod, $task) = @_;
}

sub sharedLibrary
{
    my ($mod, $outputFile, $lambda) = @_;

    if ($mod->{OUTPUT}) {
        die "Output already selected: $mod->{OUTPUT}";
    }
    if (!$outputFile) {
        die "You must specify an outputFileName parameter.";
    }

    my $task = new SharedLibraryTask(outputFile => $outputFile, libraryFile => $mod->{LIBRARY_FILE}, workingDir => $mod->{MODULE_DIR});
    $mod->setSharedLibraryOptions($task);
    if ($lambda) {
        &$lambda($task);
    }
    foreach (@{$mod->{INPUTS}}) {
        my $input = $_;
        push(@{$task->inputs}, $input);
    }
    $task->emit($mod->toolChain, $mod->moduleMan->FH, $mod);

    $mod->{OUTPUT_FILE} = $task->outputFile;
    return $task;
}

sub setSharedLibraryOptions
{
    my ($mod, $task) = @_;
}

sub executable
{
    my ($mod, $outputFileName, $lambda) = @_;

    if ($mod->{OUTPUT}) {
        die "Output already selected: $mod->{OUTPUT}";
    }
    if (!$outputFileName) {
        die "You must specify an outputFileName parameter.";
    }

    my $outputFile = File::Spec->catfile($mod->outputDir, $outputFileName);

    my $task = new ExecutableTask(outputFile => $outputFile, workingDir => $mod->{MODULE_DIR});
    $mod->setExecutableOptions($task);
    if ($lambda) {
        &$lambda($task);
    }
    foreach (@{$mod->{INPUTS}}) {
        my $input = $_;
        push(@{$task->inputs}, $input);
    }
    $task->emit($mod->toolChain, $mod->moduleMan->FH, $mod);

    $mod->{OUTPUT_FILE} = $task->outputFile;
    return $task;
}

sub setExecutableOptions
{
    my ($mod, $task) = @_;
}

1;
