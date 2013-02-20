package Plinja;
use strict;
use File::Basename;
use File::Slurp;
use File::Spec;
use File::Path;
use lib dirname(__FILE__) . "/Tasks";
use lib dirname(__FILE__) . "/ToolChains";

sub ninjaEscapePath
{
    my $str = shift;
    $str =~ s/:/\$\:/g;
    $str =~ s/ /\$ /g;
    return $str;
}

sub emitRegeneratorTarget
{
    my ($FH, $ninjaFile, $rootMakeFile, $moduleMan) = @_;

    my $ninjaFileEsc = ninjaEscapePath($ninjaFile);
    my $modules = $moduleMan->getModules();

    print($FH "#############################################\n");
    print($FH "# Remake build.ninja if any perl sources changed.\n");
    print($FH "rule RERUN_MAKE\n");
    print($FH "  command = perl \"$rootMakeFile\"\n");
    print($FH "  description = Re-running Make script.\n");
    print($FH "  generator = 1\n");
    print($FH "  restat = 1\n");
    print($FH "\n");

    print($FH "build $ninjaFileEsc \$\n");
    for my $mod (@{$modules}) {
        for my $makeFile (@{$mod->makeFiles}) {
            my $path = ninjaEscapePath($makeFile);
            print($FH "  $path \$\n");
        }
    }
    print($FH "  : RERUN_MAKE |\$\n");
    while (my ($key, $path) = each %INC) {
        if (!File::Spec->file_name_is_absolute($path)) {
            $path = File::Spec->catfile(dirname($rootMakeFile), $path);
        }
        my $pathEsc = ninjaEscapePath($path);
        print($FH "    $pathEsc \$\n");
    }
    my $rootMakeFileEsc = ninjaEscapePath($rootMakeFile);
    print($FH "    $rootMakeFileEsc\n");
    print($FH "\n");
    print($FH "\n");
}

sub writeFileIfDifferent
{
    my ($filePath, $newContents) = @_;
    my $needToWrite = 0;
    if (-e $filePath) {
        my $oldContents = read_file($filePath);
        if ($oldContents ne $newContents) {
            $needToWrite = 1;
        }
    }
    else {
        $needToWrite = 1;
    }
    if ($needToWrite) {
        File::Path::make_path(dirname($filePath));
        write_file($filePath, {binmode => ':utf8'}, $newContents );
    }
}

1;
