// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseTargetFunctions} from "@chimera/BaseTargetFunctions.sol";
import {BeforeAfter} from "./BeforeAfter.sol";
import {Properties} from "./Properties.sol";
import {vm} from "@chimera/Hevm.sol";
import {Id, Authorization, Signature} from "../../src/interfaces/IMorpho.sol";
import "forge-std/console2.sol";

abstract contract TargetFunctions is BaseTargetFunctions, Properties {
    function morpho_accrueInterest(bool switchComb) public {
        if (switchComb) {
            changeCombination();
        }
        morpho.accrueInterest(marketParams);
    }

    function morpho_createMarket(bool switchComb) public {
        if (switchComb) {
            changeCombination();
        }
        morpho.createMarket(marketParams);
    }

    function morpho_enableIrm() public {
        morpho.enableIrm(irm);
    }

    function morpho_enableLltv() public {
        morpho.enableLltv(lltv);
    }

    function morpho_flashLoan(address token, uint256 assets, bytes memory data) public {
        morpho.flashLoan(token, assets, data);
    }

    function morpho_setAuthorization(address authorized, bool newIsAuthorized) public {
        morpho.setAuthorization(authorized, newIsAuthorized);
    }

    function morpho_setAuthorizationWithSig(Authorization memory authorization, Signature memory signature) public {
        morpho.setAuthorizationWithSig(authorization, signature);
    }

    function morpho_setFee(uint256 newFee) public {
        morpho.setFee(marketParams, newFee);
    }

    function morpho_setFeeRecipient(address newFeeRecipient) public {
        morpho.setFeeRecipient(newFeeRecipient);
    }

    function morpho_setOwner(address newOwner) public {
        morpho.setOwner(newOwner);
    }

    function morpho_supply(uint256 assets, address onBehalf, bytes memory data, bool switchComb) public {
        if (switchComb) {
            changeCombination();
        }
        morpho.supply(marketParams, assets, 0, address(this), "");
    }

    function morpho_supply_shares(uint256 shares, address onBehalf, bytes memory data, bool switchComb) public {
        if (switchComb) {
            changeCombination();
        }
        morpho.supply(marketParams, 0, shares, address(this), "");
    }

    function morpho_supplyCollateral(uint256 assets, address onBehalf, bytes memory data, bool switchComb) public {
        if (switchComb) {
            changeCombination();
        }
        morpho.supplyCollateral(marketParams, assets, address(this), "");
    }

    function morpho_borrow(uint256 assets, address onBehalf, address receiver) public {
        morpho.borrow(marketParams, assets, 0, address(this), receiver);
    }

    function morpho_borrow_shares(uint256 shares, address onBehalf, address receiver) public {
        morpho.borrow(marketParams, 0, shares, address(this), receiver);
    }

    function morpho_repay(uint256 assets, uint256 shares, address onBehalf) public {
        morpho.repay(marketParams, assets, shares, address(this), "");
    }

    function morpho_repay_assets(uint256 assets, address onBehalf, bytes memory data) public {
        morpho.repay(marketParams, assets / 2, 0, address(this), "");
    }

    function morpho_repay_shares(uint256 shares, address onBehalf, bytes memory data) public {
        morpho.repay(marketParams, 0, shares / 2, address(this), "");
    }

    function morpho_withdraw(uint256 assets, address onBehalf, address _receiver) public {
        morpho.withdraw(marketParams, assets, 0, address(this), _receiver);
    }

    function morpho_withdrawShares(uint256 shares, address onBehalf, address _receiver) public {
        morpho.withdraw(marketParams, 0, shares, address(this), _receiver);
    }

    function morpho_withdrawCollateral(uint256 assets, address onBehalf, address _receiver) public {
        (,, uint256 AvailableCollateral) = morpho.position(id, address(this));
        assert(assets <= AvailableCollateral);
        morpho.withdrawCollateral(marketParams, assets, address(this), _receiver);
    }

    function morpho_liquidate(address borrower, uint256 seizedAssets, uint256 repaidShares, bytes memory data) public {
        morpho.liquidate(marketParams, address(this), seizedAssets, repaidShares, "");
    }

    function morpho_liquidate_assets(address borrower, uint256 seizedAssets, bytes memory data) public {
        oracle.setPrice(10 wei);
        morpho.liquidate(marketParams, address(this), seizedAssets, 0, hex"");
        liquation[address(collateralToken)][assets] = true;
    }

    function morpho_liquidate_repaidShares(address borrower, uint256 repaidShares, bytes memory data) public {
        oracle.setPrice(10 wei);

        morpho.liquidate(marketParams, address(this), 0, repaidShares, hex"");
    }

    function morpho_liquidate_zeroCollateral(address borrower, bool switchComb) public {
        if (switchComb) {
            changeCombination();
        }
        // oracle.setPrice(10 wei);
        (,, uint256 AvailableCollateral) = morpho.position(id, address(this));

        morpho.liquidate(marketParams, address(this), AvailableCollateral, 0, hex"");
    }
}
