// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract BLLPrelaunchSale is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    IERC20 public immutable bll;
    IERC20 public immutable usdc;
    uint256 public immutable priceUSDCPerBLL = 800;
    uint256 public immutable saleStart;
    uint256 public immutable saleEnd;
    uint256 public immutable claimStart;
    uint256 public immutable minPurchaseUSDC;
    uint256 public immutable maxPurchaseUSDC;
    uint256 public immutable allocationBLL;
    uint256 public totalUSDC;
    uint256 public totalBLLSold;
    bool public cancelled;
    bool public unsoldReturned;
    mapping(address => uint256) public purchasedBLL;
    mapping(address => uint256) public paidUSDC;
    mapping(address => bool) public claimed;
    event BLLPurchased(address indexed buyer,uint256 usdcAmount,uint256 bllAmount);
    event BLLClaimed(address indexed buyer,uint256 bllAmount);
    event SaleCancelled();
    event UnsoldReturned(address indexed recipient,uint256 amount);
    constructor(address initialOwner,address bll_,address usdc_,uint256 saleStart_,uint256 saleEnd_,uint256 claimStart_,uint256 minPurchaseUSDC_,uint256 maxPurchaseUSDC_,uint256 allocationBLL_) Ownable(initialOwner) {
        require(initialOwner != address(0), "owner is zero"); require(bll_ != address(0), "BLL is zero"); require(usdc_ != address(0), "USDC is zero");
        require(saleStart_ > block.timestamp, "start must be future"); require(saleEnd_ > saleStart_, "invalid sale period"); require(claimStart_ >= saleEnd_, "claim before sale ends");
        require(minPurchaseUSDC_ > 0, "min is zero"); require(maxPurchaseUSDC_ >= minPurchaseUSDC_, "invalid max"); require(allocationBLL_ > 0, "allocation is zero");
        bll = IERC20(bll_); usdc = IERC20(usdc_); saleStart = saleStart_; saleEnd = saleEnd_; claimStart = claimStart_; minPurchaseUSDC = minPurchaseUSDC_; maxPurchaseUSDC = maxPurchaseUSDC_; allocationBLL = allocationBLL_;
    }
    function buy(uint256 usdcAmount) external nonReentrant { require(!cancelled, "sale cancelled"); require(block.timestamp >= saleStart, "sale not started"); require(block.timestamp < saleEnd, "sale ended"); require(usdcAmount >= minPurchaseUSDC, "below minimum"); uint256 newPaid = paidUSDC[msg.sender] + usdcAmount; require(newPaid <= maxPurchaseUSDC, "wallet limit exceeded"); uint256 bllAmount = (usdcAmount * 1e18) / priceUSDCPerBLL; require(bllAmount > 0, "zero BLL"); require(totalBLLSold + bllAmount <= allocationBLL, "allocation exceeded"); paidUSDC[msg.sender] = newPaid; purchasedBLL[msg.sender] += bllAmount; totalUSDC += usdcAmount; totalBLLSold += bllAmount; usdc.safeTransferFrom(msg.sender,address(this),usdcAmount); emit BLLPurchased(msg.sender,usdcAmount,bllAmount); }
    function claim() external nonReentrant { require(!cancelled, "sale cancelled"); require(block.timestamp >= claimStart, "claims not started"); require(!claimed[msg.sender], "already claimed"); uint256 amount = purchasedBLL[msg.sender]; require(amount > 0, "nothing to claim"); claimed[msg.sender] = true; bll.safeTransfer(msg.sender, amount); emit BLLClaimed(msg.sender, amount); }
    function cancelSale() external onlyOwner { require(!cancelled, "already cancelled"); require(block.timestamp < saleEnd, "sale ended"); cancelled = true; emit SaleCancelled(); }
    function refund() external nonReentrant { require(cancelled, "sale not cancelled"); uint256 amount = paidUSDC[msg.sender]; require(amount > 0, "nothing to refund"); paidUSDC[msg.sender] = 0; purchasedBLL[msg.sender] = 0; totalUSDC -= amount; usdc.safeTransfer(msg.sender, amount); }
    function returnUnsoldBLL() external onlyOwner nonReentrant { require(block.timestamp >= saleEnd, "sale still active"); require(!unsoldReturned, "already returned"); unsoldReturned = true; uint256 unsold = allocationBLL - totalBLLSold; if (unsold > 0) bll.safeTransfer(owner(), unsold); emit UnsoldReturned(owner(), unsold); }
    function withdrawUSDC() external onlyOwner nonReentrant { require(!cancelled, "sale cancelled"); require(block.timestamp >= saleEnd, "sale still active"); uint256 amount = usdc.balanceOf(address(this)); require(amount > 0, "no USDC"); usdc.safeTransfer(owner(), amount); }
    function remainingBLL() external view returns (uint256) { return allocationBLL - totalBLLSold; }
    function bllForUSDC(uint256 usdcAmount) external pure returns (uint256) { return (usdcAmount * 1e18) / 800; }
    function usdcForBLL(uint256 bllAmount) external pure returns (uint256) { return (bllAmount * 800) / 1e18; }
    receive() external payable { revert("USDC only"); }
    fallback() external payable { revert("USDC only"); }
}
