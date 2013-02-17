package Plinja;
use File::Basename;
use lib dirname(__FILE__) . "/Tasks";
use lib dirname(__FILE__) . "/ToolChains";

sub ninjaEscapePath
{
    my $str = shift;
    $str =~ s/:/\$\:/;
    $str =~ s/ /\$ /;
    return $str;
}

sub emitRegeneratorTarget
{
    my ($FH, $ninjaFile, $makeFile) = @_;

    my $ninjaFileEsc = ninjaEscapePath($ninjaFile);
    
    print($FH "#############################################\n");
    print($FH "# Remake build.ninja if any perl sources changed.\n");
    print($FH "rule RERUN_MAKE\n");
    print($FH "  command = perl \"$makeFile\"\n");
    print($FH "  description = Re-running Make script.\n");
    print($FH "  generator = 1\n");
    print($FH "\n");
    print($FH "build $ninjaFileEsc : RERUN_MAKE \$\n");
    foreach my $key ( keys %INC ) {
        my $path = ninjaEscapePath($INC{$key});
        print($FH "    $path \$\n");
    }
    print($FH "\n");
    print($FH "\n");
}

1;
