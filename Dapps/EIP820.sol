pragma solidity ^0.4.25;

import "./InterfaceImplementationRegistry.sol";

contract EIP820 {
    InterfaceImplementationRegistry interfaceImplementationRegistry = InterfaceImplementationRegistry(0x2415548c95ba18d82761ddbc05754004ed27f75d);
                                                                        //AXL-ERC820 Registry Address
    function setInterfaceImplementation(string ifaceLabel, address impl) internal {
        interfaceImplementationRegistry.setInterfaceImplementer(this, keccak256(ifaceLabel), impl);
    }

    function interfaceAddr(address addr, string ifaceLabel) internal constant returns(address) {
        return interfaceImplementationRegistry.getInterfaceImplementer(addr, keccak256(ifaceLabel));
    }

    function delegateManagement(address newManager) internal {
        interfaceImplementationRegistry.setManager(this, newManager);
    }
}
