# Install module tester
cd $HOME
git clone https://github.com/b-harvest/modules-test-tool.git
cd modules-test-tool
git checkout mm-order
make install

# copy main.go into crescent, rebuild crescentd
TDIR=$HOME/tutorials/crescent-local-testnet
CDIR=$HOME/crescent/cmd/crescentd

cp $TDIR/files/main.go $CDIR/main.go
cd $HOME/crescent
go mod tidy
make install

# Restart the crescentd
# Open new terminal 
# Terminal 2 : Make the crescent process keep running in this dedicated terminal
VHOME=$HOME/local-mooncat
BINARY=$(which crescentd)

cd $HOME
$BINARY start --home $VHOME

# Check the new directory profileData after 30 seconds
ls $HOME/profileData

# copy tester config.toml
MDIR=$HOME/modules-test-tool
cp $TDIR/files/config.toml $MDIR

# Send Market Making Orders
cd $MDIR
tester mm-order 1 1.03 0.99 10000000 1.01 0.97 10000000 100 20000
## MM ORDER 가 대량 발생하는 시점의 Trace 필요
## main.go 에 profile 코드를 어떻게 사용해야 하나?
## tester mm-order가 여러 개의 지갑으로 BUY SELL 하도록 수정 필요

# Install graphviz
sudo apt-get -y install graphviz # Ubuntu
brew install graphviz # MacOS

# Launch one of below after the tester's mm-order completed
go tool trace -http 0.0.0.0:8080 $MDIR/profileData/trace.out
go tool pprof -http 0.0.0.0:8080 $MDIR/profileData/goroutine.pprof
go tool pprof -http 0.0.0.0:8080 $MDIR/profileData/mem.pprof
