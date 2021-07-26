function init(address _Owner, address _pairAddress) external onlyOwner {
    if (Owner == address(0)) {
        Owner = _Owner;
        pairAddress = _pairAddress;

        _rOwned[Owner] = _rTotal;
        setNoFee(Owner, true);
        excludeReflectAccount(Owner);
        excludeReflectAccount(pairAddress);

        // Set transfer pair address so contract know which one is buy or sell
        setTransferPairAddress(pairAddress, true);

        // Set no fee since we use this contract as principal to generate rewards for LP provider
        setNoFee(address(this), true);
    }
}

function setNoFee(address account, bool value) public onlyOwner {
    _isNoFee[account] = value;
}

function setTransferPairAddress(address transferPairAddress, bool value) public onlyOwner {
    _transferPairAddress[transferPairAddress] = value;
}

function setRestrictBuyAmount(uint256 amount) external onlyOwner {
    restrictBuyAmount = amount;
}

function excludeReflectAccount(address account) public onlyOwner {
    require(!_isReflectExcluded[account], "Already excluded");
    if (_rOwned[account] > 0) {
        _tOwned[account] = tokenFromReflection(_rOwned[account]);
    }
    _isReflectExcluded[account] = true;
    _reflectExcluded.push(account);
}

function includeReflectAccount(address account) public onlyOwner {
    require(_isReflectExcluded[account], "Already included");
    for (uint256 i = 0; i < _reflectExcluded.length; i++) {
        if (_reflectExcluded[i] == account) {
            _reflectExcluded[i] = _reflectExcluded[_reflectExcluded.length - 1];
            _tOwned[account] = 0;
            _isReflectExcluded[account] = false;
            _reflectExcluded.pop();
            break;
        }
    }
}
    function setFee(
        uint256 _reflectFeeDenominator,
        uint256 _buyTxFeeDenominator,
        uint256 _sellTxFeeDenominator,
        uint256 _buyBonusDenominator,
        uint256 _sellFeeDenominator
    ) external onlyOwner {
        reflectFeeDenominator = _reflectFeeDenominator;
        buyTxFeeDenominator = _buyTxFeeDenominator;
        sellTxFeeDenominator = _sellTxFeeDenominator;
        buyBonusDenominator = _buyBonusDenominator;
        sellFeeDenominator = _sellFeeDenominator;
    }

    function setReserveSupply(uint256 amount) external onlyOwner {
        reserveSupply = amount;
    }

    /// @notice Deposit principal supply from Owner
    function depositPrincipalSupply(uint256 amount) external onlyOwner {
        principalSupply = amount;
        _transferFromExcluded(Owner, address(this), principalSupply, false, TransferState.Normal);
    }

    /// @notice Withdraw back principal supply to Owner
    function withdrawPrincipalSupply() external onlyOwner returns(uint256) {
        _transferToExcluded(address(this), Owner, balanceOf(address(this)), false, TransferState.Normal);
        return principalSupply;
    }

    /// @notice Reward LP providers if pair address is specified, otherwise just add the reward to reserve supply for liquidity
    function distributePrincipalRewards(address rewardPairAddress) external onlyOwner {
        uint256 balance = balanceOf(address(this));
        if (balance > 0) {
            uint256 reward = balance.sub(principalSupply);
            // If pair address specified then reward LP provider
            if (rewardPairAddress != address(0)) {
                _transferToExcluded(address(this), rewardPairAddress, reward, false, TransferState.Normal);
                IUniswapV2Pair(rewardPairAddress).sync();
            }
            // else add as reserve supply to generate liquidity
            else {
                _transferToExcluded(address(this), Owner, reward, false, TransferState.Normal);
                reserveSupply = reserveSupply.add(reward);
            }
        }
    }
