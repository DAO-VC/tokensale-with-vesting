// SPDX-License-Identifier: MIT
/// @author KRogLA (https://github.com/krogla)
pragma solidity ^0.8.0;

error StoreBundleMissmatch();
error StoreInsufficientAmount();

library AmountStore {
    using AmountStore for Store;

    struct Bundle {
        // Array with id
        uint256[] ids;
        // Array with amount
        uint256[] amounts;
    }

    struct Store {
        mapping(uint256 => uint256) _index;
        Bundle _bundle;
    }

    function _add(
        Store storage self,
        uint256 id,
        uint256 amount
    ) internal {
        if (self._index[id] == 0) {
            // i.e. id not in list yet
            self._bundle.ids.push(id);
            self._bundle.amounts.push(amount);
            self._index[id] = self._bundle.ids.length;
        } else {
            self._bundle.amounts[self._index[id] - 1] += amount;
        }
    }

    function _sub(
        Store storage self,
        uint256 id,
        uint256 amount
    ) internal {
        if (self._index[id] == 0) revert StoreInsufficientAmount();
        uint256 idx = self._index[id] - 1;
        self._bundle.amounts[idx] -= amount;
        if (self._bundle.amounts[idx] == 0) {
            uint256 lastIdx = self._bundle.ids.length - 1;
            self._index[id] = 0;
            if (idx < lastIdx) {
                id = self._bundle.ids[lastIdx];
                self._bundle.ids[idx] = id;
                self._bundle.amounts[idx] = self._bundle.amounts[lastIdx];
                self._index[id] = idx + 1;
            }
            self._bundle.ids.pop();
            self._bundle.amounts.pop();
        }
    }

    function empty(Store storage self) internal {
        for (uint256 i = 0; i < self._bundle.ids.length; i++) {
            delete self._index[self._bundle.ids[i]];
        }
        delete self._bundle;
    }

    function len(Store storage self) internal view returns (uint256) {
        return self._bundle.ids.length;
    }

    function get(Store storage self) internal view returns (Bundle memory) {
        return self._bundle;
    }

    function hash(Store storage self) internal view returns (bytes32) {
        return keccak256(abi.encodePacked(self._bundle.ids, self._bundle.amounts));
    }

    function bandleHash(Bundle memory bundle) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(bundle.ids, bundle.amounts));
    }

    function add(Store storage self, Bundle memory bundle) internal {
        if (bundle.ids.length != bundle.amounts.length) revert StoreBundleMissmatch();
        for (uint256 i = 0; i < bundle.ids.length; i++) {
            self._add(bundle.ids[i], bundle.amounts[i]);
        }
    }

    function sub(Store storage self, Bundle memory bundle) internal {
        if (bundle.ids.length != bundle.amounts.length) revert StoreBundleMissmatch();
        for (uint256 i = 0; i < bundle.ids.length; i++) {
            self._sub(bundle.ids[i], bundle.amounts[i]);
        }
    }

    function migrate(Store storage self, Store storage target) internal {
        self.transfer(target, self._bundle);
    }

    function swap(
        Store storage self,
        Store storage target,
        Bundle memory bundle
    ) internal {
        if (bundle.ids.length != bundle.amounts.length) revert StoreBundleMissmatch();
        self.migrate(target);
        target.transfer(self, bundle);
    }

    function transfer(
        Store storage self,
        Store storage target,
        Bundle memory bundle
    ) internal {
        if (bundle.ids.length != bundle.amounts.length) revert StoreBundleMissmatch();
        for (uint256 i = 0; i < bundle.ids.length; i++) {
            self._sub(bundle.ids[i], bundle.amounts[i]);
            target._add(bundle.ids[i], bundle.amounts[i]);
        }
    }
}
