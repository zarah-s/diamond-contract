// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/facets/Pool.sol";
import "../contracts/facets/Staking.sol";
import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../contracts/Diamond.sol";
import "../contracts/interfaces/IDiamond.sol";

contract DiamondDeployer is Test, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;

    Pool pool;

    IDiamond i_diamond;

    address A = mkaddr("ADDRESS A");
    address B = mkaddr("ADDRESS B");

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }

    function setUp() public {
        //deploy facets

        switchSigner(A);
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(dCutFacet), address(0));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        pool = new Pool();

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](4);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(pool),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("Pool")
            })
        );

        cut[3] = (
            FacetCut({
                facetAddress: address(new Staking()),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("Staking")
            })
        );

        i_diamond = IDiamond(address(diamond));

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
    }

    function testStake() public {
        console2.log("Haloha");
        vm.expectRevert(abi.encodeWithSelector(UNAUTHORIZED.selector));
        i_diamond.list_user(address(1), 50);
    }

    function switchSigner(address _newSigner) public {
        address foundrySigner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        if (msg.sender == foundrySigner) {
            vm.startPrank(_newSigner);
        } else {
            vm.stopPrank();
            vm.startPrank(_newSigner);
        }
    }

    function generateSelectors(
        string memory _facetName
    ) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
