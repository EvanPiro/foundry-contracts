#forge script script/NFTPrinter.s.sol:DeployAndMint --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv

source .env && forge script script/DeployNFTPrinter.s.sol:DeployNFTPrinter --rpc-url $SEPOLIA_RPC_URL --broadcast --verify