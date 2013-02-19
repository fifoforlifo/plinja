package Plinja;
use File::Basename;
use File::Slurp;
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
    my ($FH, $ninjaFile, $makeFile, $moduleMan) = @_;

    my $ninjaFileEsc = ninjaEscapePath($ninjaFile);
    my $modules = $moduleMan->getModules();

    print($FH "#############################################\n");
    print($FH "# Remake build.ninja if any perl sources changed.\n");
    print($FH "rule RERUN_MAKE\n");
    print($FH "  command = perl \"$makeFile\"\n");
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
    print($FH "  : RERUN_MAKE |");
    while (my ($key, $path) = each %INC) {
        my $pathEsc = ninjaEscapePath($path);
        print($FH " \$\n    $pathEsc");
    }
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
