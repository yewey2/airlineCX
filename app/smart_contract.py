import json, web3
from web3 import Web3, EthereumTesterProvider

import os
from dotenv import load_dotenv
load_dotenv()
private_key = os.environ.get('private_key')

url = 'https://sepolia.infura.io/v3/c8916b4f64cd4080b5713572a5ffadbb'
w3 = web3.Web3(web3.HTTPProvider(url))
import solcx
solcx.install_solc() 
solcx.install_solc('0.8.12')

from solcx import compile_source, compile_standard

with open('contract.sol', 'r') as f:
    source_code = f.read()

# compiled_solidity = compile_source(str(source_code), output_values=['abi','bin'])

compiled_solidity = compile_standard({
    "language": "Solidity",
    "sources": {
        "contract.sol": {
            "content": source_code
        }
    },
    "settings": {
        "outputSelection": {
            "*": {"*":
                  ["abi","metadata","evm.bytecode","evm.sourceMap"]}
        },
    },
}, solc_version = "0.8.12")

abi = compiled_solidity['contracts']['contract.sol']['MSBAAirlinesCompensationSmartContract']['abi']
bytecode = compiled_solidity['contracts']['contract.sol']['MSBAAirlinesCompensationSmartContract']['evm']['bytecode']['object']

Contract = w3.eth.contract(abi=abi, bytecode=bytecode)

wallet = '0x14E9397B1d39b84Bbc4ADB324710F59b3AF29eC0'
sepolia = 11155111

tx = Contract.constructor().build_transaction(
    {
        'gasPrice': w3.eth.gas_price,
        'chainId': sepolia, # sepolia
        'from': wallet,
        'nonce': w3.eth.get_transaction_count(wallet),
        'value': 12345
    }
)
signed_transaction = w3.eth.account.sign_transaction(tx, private_key=private_key)
tx_hash = w3.eth.send_raw_transaction(signed_transaction.rawTransaction)
tx_receipt = w3.eth.wait_for_transaction_receipt(transaction_hash=tx_hash)
MyContract = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)


def get_sample_data():
    flight_number, departure, passport, duration, addr = MyContract.functions.test().call()
    return {
        'flightId': flight_number.decode('utf-8'),
        'departureDateTime': departure,
        'passportNumber': passport.decode('utf-8'),
        'duration': duration,
        'addr': addr,
    }