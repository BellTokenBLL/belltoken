# Security & Verification

## BLL token

BLL is a fixed-supply OpenZeppelin ERC-20 deployed on Base Mainnet. The deployed token contract mints the fixed 1,000,000,000 BLL supply at deployment and has no owner-controlled post-deployment minting mechanism.

## Presale

The presale contract uses OpenZeppelin `Ownable`, `ReentrancyGuard` and `SafeERC20`. It enforces sale dates, purchase limits, wallet accounting, the BLL allocation cap and one-time claiming.

## Audit status

An independent third-party smart-contract security audit is being pursued. The project should not be described as audited until an independent audit has been completed and its findings/remediation status are published.

## Verification

Always verify the official BLL contract on Base before interacting:

`0x8257c74A62fDAdC192ffB6eAfa2c1534f11c28f0`
