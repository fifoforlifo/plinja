if [ ! -e "Built/build.ninja" ]; then
    ./Make.pl
fi

pushd Built
ninja "$@"
popd

