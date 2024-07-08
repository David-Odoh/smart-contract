# Include .env file if it exists and export its env vars.
-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""

all: clean remove install update build

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install the Modules
install :; 
	forge install OpenZeppelin/openzeppelin-contracts
	forge install foundry-rs/forge-std

build::
	@forge build

clean::
	@forge clean

gas-report::
	@forge test --gas-report

update::
	@forge update
update::
	@forge update

watch::
	@forge test --watch contracts/

snapshot::
	@forge snapshot

format::
	@forge fmt

fmt-check::
	@forge fmt --check

fmt-write::
	@forge fmt

test:
	@forge snapshot -vvvv --gas-report --use solc:$(SOLC_VERSION) $(FORGE_SNAPSHOT_OPTION)

coverage:
	@forge coverage --use solc:$(SOLC_VERSION)

remappings:
	@forge remappings > remappings.txt

inspect_storage:
	@forge inspect src/${contract}.sol:${contract} storage --pretty

inspect_function:
	@forge inspect src/${contract}.sol:${contract} methods --pretty

conversion:
	@cast --to-base ${value} ${format}

examine_storage:
	sol2uml storage -c ${contract} src	> mkdir /assets

open_storage:
	open -a Google\ Chrome ./${contract}.svg

print_abi:
	@forge inspect src/${contract}.sol:${contract} abi --pretty

analyzers::
	slither .
	
anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1


NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(DEPLOYER_PRIVATE_KEY) --broadcast -vvvv

# use the "@" to hide the command from your shell 
deploy:
	@forge script script/${contract}.s.sol:Deploy${contract} $(NETWORK_ARGS)

# use the "@" to hide the command from your shell 
# for more details, logging with emit, add verbosity 1 up to 5 v's
deploy-goerli :; @forge script script/${contract}.s.sol:Deploy${contract} --rpc-url ${GOERLI_RPC_URL}  --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY}  -vvvv

# This is the private key of account from the mnemonic from the "make anvil" command
deploy-anvil :; @forge script script/${contract}.s.sol:Deploy${contract} --rpc-url http://localhost:8545  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast 

deploy-all :; make deploy-${network} contract=APIConsumer && make deploy-${network} contract=KeepersCounter && make deploy-${network} contract=PriceFeedConsumer && make deploy-${network} contract=VRFConsumerV2

# cast abi-encode "constructor(uint256)" 1000000000000000000000000 -> 0x00000000000000000000000000000000000000000000d3c21bcecceda1000000
# Update with your contract address, constructor arguments and anything else
verify:
	@forge verify-contract --chain-id 11155111 --num-of-optimizations 200 --watch --constructor-args 0x00000000000000000000000000000000000000000000d3c21bcecceda1000000

## These commands must be configured before being executed
depositAndMint:
	@cast send <Contract Address deployed> "depositCollateralAndMintAir(uint256,uint256)" $(DEPOSIT_COLLATERAL_AMOUNT) $(MINTED_AIR_AMOUNT) --private-key $(DEFAULT_ANVIL_KEY)

