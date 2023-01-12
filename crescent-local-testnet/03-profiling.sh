# Install module tester
cd $HOME
git clone https://github.com/b-harvest/modules-test-tool.git
cd modules-test-tool
git checkout mm-order
make install

# copy config.toml
TDIR=$HOME/tutorials/crescent-local-testnet
MDIR=$HOME/modules-test-tool
cp $TDIR/files/config.toml $MDIR

# Send Market Making Orders
tester mm-order 1 1.08 0.98 10000000 1.02 0.92 10000000 100 20000

# Install graphviz
sudo apt-get -y install graphviz # Ubuntu
sudo brew install graphviz # MacOS

# Launch one of below after the tester's mm-order completed
go tool trace -http 0.0.0.0:8080 $MDIR/profileData/trace.out
go tool pprof -http 0.0.0.0:8080 $MDIR/profileData/goroutine.pprof
go tool pprof -http 0.0.0.0:8080 $MDIR/profileData/mem.pprof
