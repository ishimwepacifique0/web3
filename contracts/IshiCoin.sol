pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract IshiCoin is ERC20, ReentrancyGuard, Ownable {
    uint256 public constant INITIAL_SUPPLY = 1000000 * 10**18; // 1 million tokens
    uint256 public constant LIQUIDITY_FEE = 25; // 0.25% fee
    uint256 public constant FEE_DENOMINATOR = 10000;
    
    // Liquidity pool for ETH swaps
    uint256 public ethLiquidity;
    uint256 public tokenLiquidity;
    
    // Events
    event TokensSent(address indexed from, address indexed to, uint256 amount, string message);
    event TokensSwapped(address indexed user, uint256 ethAmount, uint256 tokenAmount, bool isEthToToken);
    event LiquidityAdded(address indexed provider, uint256 ethAmount, uint256 tokenAmount);
    event LiquidityRemoved(address indexed provider, uint256 ethAmount, uint256 tokenAmount);
    
    constructor() ERC20("IshiCoin", "ISHI") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_SUPPLY);
        // Initialize liquidity pool with some tokens
        tokenLiquidity = INITIAL_SUPPLY / 10; // 10% of supply for initial liquidity
        _transfer(msg.sender, address(this), tokenLiquidity);
    }
    
    // Send tokens with a message
    function sendTokens(address to, uint256 amount, string memory message) public {
        require(to != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        
        _transfer(msg.sender, to, amount);
        emit TokensSent(msg.sender, to, amount, message);
    }
    
    // Transfer tokens (standard ERC20 transfer)
    function transferTokens(address to, uint256 amount) public returns (bool) {
        return transfer(to, amount);
    }
    
    // Swap ETH for IshiCoin tokens
    function swapEthForTokens() public payable nonReentrant {
        require(msg.value > 0, "Must send ETH");
        require(ethLiquidity > 0 && tokenLiquidity > 0, "Insufficient liquidity");
        
        uint256 fee = (msg.value * LIQUIDITY_FEE) / FEE_DENOMINATOR;
        uint256 swapAmount = msg.value - fee;
        
        // Calculate tokens to receive using constant product formula
        uint256 tokensToReceive = (swapAmount * tokenLiquidity) / (ethLiquidity + swapAmount);
        
        require(tokensToReceive > 0, "Insufficient tokens for swap");
        require(tokensToReceive <= tokenLiquidity, "Insufficient token liquidity");
        
        // Update liquidity pool
        ethLiquidity += msg.value;
        tokenLiquidity -= tokensToReceive;
        
        // Transfer tokens to user
        _transfer(address(this), msg.sender, tokensToReceive);
        
        emit TokensSwapped(msg.sender, msg.value, tokensToReceive, true);
    }
    
    // Swap IshiCoin tokens for ETH
    function swapTokensForEth(uint256 tokenAmount) public nonReentrant {
        require(tokenAmount > 0, "Amount must be greater than 0");
        require(balanceOf(msg.sender) >= tokenAmount, "Insufficient token balance");
        require(ethLiquidity > 0 && tokenLiquidity > 0, "Insufficient liquidity");
        
        // Calculate ETH to receive using constant product formula
        uint256 ethToReceive = (tokenAmount * ethLiquidity) / (tokenLiquidity + tokenAmount);
        
        require(ethToReceive > 0, "Insufficient ETH for swap");
        require(ethToReceive <= ethLiquidity, "Insufficient ETH liquidity");
        
        // Calculate fee
        uint256 fee = (ethToReceive * LIQUIDITY_FEE) / FEE_DENOMINATOR;
        uint256 finalEthAmount = ethToReceive - fee;
        
        // Update liquidity pool
        tokenLiquidity += tokenAmount;
        ethLiquidity -= ethToReceive;
        
        // Transfer tokens from user to contract
        _transfer(msg.sender, address(this), tokenAmount);
        
        // Transfer ETH to user
        (bool success, ) = msg.sender.call{value: finalEthAmount}("");
        require(success, "ETH transfer failed");
        
        emit TokensSwapped(msg.sender, tokenAmount, finalEthAmount, false);
    }
    
    // Add liquidity to the pool
    function addLiquidity() public payable nonReentrant {
        require(msg.value > 0, "Must send ETH");
        require(ethLiquidity > 0, "Pool not initialized");
        
        // Calculate proportional token amount
        uint256 tokenAmount = (msg.value * tokenLiquidity) / ethLiquidity;
        require(balanceOf(msg.sender) >= tokenAmount, "Insufficient token balance");
        
        // Update liquidity pool
        ethLiquidity += msg.value;
        tokenLiquidity += tokenAmount;
        
        // Transfer tokens from user to contract
        _transfer(msg.sender, address(this), tokenAmount);
        
        emit LiquidityAdded(msg.sender, msg.value, tokenAmount);
    }
    
    // Remove liquidity from the pool (simplified version)
    function removeLiquidity(uint256 ethAmount) public nonReentrant onlyOwner {
        require(ethAmount > 0, "Amount must be greater than 0");
        require(ethAmount <= ethLiquidity, "Insufficient ETH liquidity");
        
        // Calculate proportional token amount
        uint256 tokenAmount = (ethAmount * tokenLiquidity) / ethLiquidity;
        
        // Update liquidity pool
        ethLiquidity -= ethAmount;
        tokenLiquidity -= tokenAmount;
        
        // Transfer ETH to owner
        (bool success, ) = owner().call{value: ethAmount}("");
        require(success, "ETH transfer failed");
        
        // Transfer tokens to owner
        _transfer(address(this), owner(), tokenAmount);
        
        emit LiquidityRemoved(owner(), ethAmount, tokenAmount);
    }
    
    // Get current exchange rate (tokens per ETH)
    function getExchangeRate() public view returns (uint256) {
        if (ethLiquidity == 0 || tokenLiquidity == 0) return 0;
        return (tokenLiquidity * 10**18) / ethLiquidity;
    }
    
    // Get pool information
    function getPoolInfo() public view returns (uint256 eth, uint256 tokens, uint256 rate) {
        eth = ethLiquidity;
        tokens = tokenLiquidity;
        rate = getExchangeRate();
    }
    
    // Emergency withdraw (owner only)
    function emergencyWithdraw() public onlyOwner {
        uint256 ethBalance = address(this).balance;
        uint256 tokenBalance = balanceOf(address(this));
        
        if (ethBalance > 0) {
            (bool success, ) = owner().call{value: ethBalance}("");
            require(success, "ETH transfer failed");
        }
        
        if (tokenBalance > 0) {
            _transfer(address(this), owner(), tokenBalance);
        }
    }
    
    // Receive ETH
    receive() external payable {}
    
    // Fallback function
    fallback() external payable {}
}
