// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseSetup} from "@chimera/BaseSetup.sol";
import {ERC20} from "./mocks/ERC20.sol";
import {WETH} from "./mocks/weth.sol";
import {OracleMock} from "../../src/mocks/OracleMock.sol";
import {Morpho} from "../../src/Morpho.sol";
import {IrmMock} from "../../src/mocks/IrmMock.sol";
import {Id, IMorpho, MarketParams} from "../../src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "../../src/libraries/MarketParamsLib.sol";
import {Test} from "forge-std/Test.sol";
import "forge-std/console2.sol";

abstract contract Setup is BaseSetup, Test {
    using MarketParamsLib for MarketParams;

    //A market needs a loanToken , a collateralToken an oracle etc

    // address of loanToken
    ERC20 public loanToken;
    // address of collateralToken
    ERC20 public collateralToken;

    WETH public weth;
    // address of oracle
    OracleMock public oracle;
    // address of irm
    address public irm;

    //address public receiver = address(0x1);
    // lltv
    uint256 public lltv = 0.5e18;

    // deployer
    address owner = msg.sender;
    address USER1 = address(1);
    // address of morpho
    Morpho public morpho;
    // market parameters
    MarketParams marketParams;

    Id public id;
    // I want to have a mapping for colllateral token and loan token. Idea is check the collateral we use, either usdc
    // or weth
    // something like liquidation[colllateralToken][assets] = true
    mapping(address => mapping(uint256 => bool)) public liquidation;

    // Lets have a way to deploy new  markets with new parameters
    function changeCombination() public {
        vm.startPrank(USER1);
        vm.deal(USER1, 20e18);
        loanToken = new ERC20("newloanToken", "NLOAN");
        weth = new WETH();
        oracle = new OracleMock();
        irm = address(new IrmMock());
        lltv = 0.7e18;
        // set the market parameters for creating a new market
        marketParams = MarketParams(address(loanToken), address(weth), address(oracle), address(irm), lltv);
        id = marketParams.id();

        loanToken.mint(USER1, 10e18);
        loanToken.approve(address(morpho), 10e18);
        weth.deposit{value: 10e18}();
        weth.approve(address(morpho), 10e18);
        vm.stopPrank();
        //set the price
        oracle.setPrice(1e18);
    }

    function setup() internal virtual override {
        // deploy loanToken
        loanToken = new ERC20("loanToken", "LOAN"); //weth
        // deploy collateralToken
        collateralToken = new ERC20("collateralToken", "COLL"); //usdc
        // deploy oracle
        oracle = new OracleMock();
        // deploy irm
        irm = address(new IrmMock());

        // deploy 1 morpho
        morpho = new Morpho(address(this));
        // set the market parameters for creating a new market
        marketParams = MarketParams(address(loanToken), address(collateralToken), address(oracle), address(irm), lltv);
        id = marketParams.id();

        morpho.enableIrm(address(irm));
        morpho.enableLltv(lltv);
        morpho.createMarket(marketParams);

        loanToken.mint(address(this), 10e18);
        loanToken.approve(address(morpho), 10e18);

        collateralToken.mint(address(this), 10e18);
        collateralToken.approve(address(morpho), 10e18);

        //set the price
        oracle.setPrice(1e18);
    }
}
