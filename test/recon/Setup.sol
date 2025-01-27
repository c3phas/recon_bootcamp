// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseSetup} from "@chimera/BaseSetup.sol";
import {ERC20} from "./mocks/ERC20.sol";
import {OracleMock} from "../../src/mocks/OracleMock.sol";
import {Morpho} from "../../src/Morpho.sol";
import {IrmMock} from "../../src/mocks/IrmMock.sol";
import {Id, IMorpho, MarketParams} from "../../src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "../../src/libraries/MarketParamsLib.sol";
import {Test} from "forge-std/Test.sol";

abstract contract Setup is BaseSetup, Test {
    using MarketParamsLib for MarketParams;

    //A market needs a loanToken , a collateralToken an oracle etc

    // address of loanToken
    ERC20 public loanToken;
    // address of collateralToken
    ERC20 public collateralToken;
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

    function setup() internal virtual override {
        // deploy loanToken
        loanToken = new ERC20("loanToken", "LOAN");
        // deploy collateralToken
        collateralToken = new ERC20("collateralToken", "COLL");
        // deploy oracle
        oracle = new OracleMock();
        // deploy irm
        irm = address(new IrmMock());

        // deploy 1 morpho
        morpho = new Morpho(address(this));
        // set the market parameters for creating a new market
        marketParams = MarketParams(address(loanToken), address(collateralToken), address(oracle), address(irm), lltv);
        id = marketParams.id();
        //morpho.enableIrm(address(irm));
        // morpho.enableLltv(lltv);
        //morpho.createMarket(marketParams);
        morpho.enableIrm(address(irm));
        morpho.enableLltv(lltv);
        morpho.createMarket(marketParams);
        //oracle.setPrice(100);
        loanToken.mint(address(this), 10e18);
        loanToken.approve(address(morpho), 10e18);
        collateralToken.mint(address(this), 10e18);
        collateralToken.approve(address(morpho), 10e18);

        //set the price
        oracle.setPrice(1e18);
    }
}
