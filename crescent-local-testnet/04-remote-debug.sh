# Install dlv
go install github.com/go-delve/delve/cmd/dlv@latest

# Option 1 : Attach to running node by start the debug
dlv attach $(pgrep crescentd) $GOPATH/bin/crescentd --headless --api-version=2 --listen=0.0.0.0:12345
## API server listening at: [::]:12345
## 2023-01-12T18:39:24+09:00 warning layer=rpc Listening for remote connections (connections are not authenticated nor encrypted)

## VS Code > Debug > Configuration 추가 > Go > Connect to server
## 포트 12345로 수정

## crescent 폴더를 VS Code에 추가
## x/liquidity/keeper/swap.go > LimitOrder 등 관찰 대상 함수에 브레이크 포인트 설정


# Option 2 : Launch the server from debug tab of VS Code
dlv debug . --headless --api-version=2 --listen=0.0.0.0:12345 -- start --home $HOME/local-mooncat 
