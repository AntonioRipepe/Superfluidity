// SPDX-License-Identifier: UNLICENSED

// This is a basic framework for the vault contract
// ~~~~~~~~~~~~~~ WORK IN PROGRESS ~~~~~~~~~~~~~~
// There is a lot more to be added and editted
// We need to iron out the complete data flow, in order to
// get this contract fully where it needs to be.
//        - Antonio Ripepe


/* 
    Required auxilary contracts: 
        - DSMath         ( Imported from DSToken )
        - DSToken        ( Imported from DSMultiVault )
        - DSAuth         ( Imported from DSToken & DSMultiVault )
        - ERC20          ( Imported from DSMultiVault )
        - DSMultiVault   ( Imported from this Contract )
        - Will eventually need ERC721 import

    * Need to make sure the import paths are correct, depending on how you move them around!
*/


pragma solidity >=0.4.23;

import "./Multivault.sol";

contract vaultFactory is DSMultiVault{

    // Not sure just yet if we need a user struct
    // struct users {
    //     mapping(address => uint) userBalances;
    //     mapping(address => uint) userOwnershipPercentage;
    // }

    // Used to create vaults for different token types
    struct vault {
        // Address of the owner of the vault
        address vaultOwner;
        // Token type for first token in pair
        ERC20 tokenType1;
        // Token type for first token in pair
        ERC20 tokenType2;
        // Unique identifier
        uint vaultID;
        // Total liquidity deposited -- sum of all liquidity of token 1 deposited
        uint totalLiquidityToken1;
        // Total inactive liquidity -- sum of all liquidity of token 1 currently in the vault
        uint totalInactiveLiquidityToken1;
        // Total active liquidity -- difference of (totalLiquidityToken1 - inactiveLiquidityToken1)
        uint totalActiveLiquidityToken1;
        // Total liquidity deposited -- sum of all liquidity of token 2 deposited
        uint totalLiquidityToken2;
        // Total inactive liquidity -- sum of all liquidity of token 2currently in the vault
        uint totalInactiveLiquidityToken2;
        // Total active liquidity -- difference of (totalLiquidityToken2 - inactiveLiquidityToken2)
        uint totalActiveLiquidityToken2;

        // May need to move these to a user struct to store user informatiuon?

        // Exit characteristics for users postion -- top end  *Unsure if user address / position address
        mapping(address => uint) positionExitMax;
        // Exit characteristics for users postion -- bottom end *Unsure if user address / position address
        mapping(address => uint) positionExitMin;
        // Mapping of user addresses to ERC721 token addresses *Not sure if needed
        mapping(address => address) erc721Tokens;
    }

    // Stores mapping of simple integer ids for each vault
    // Will be changed in future
    mapping(uint => vault) vaultList;
    
    // Will need to change to some unique identifier
    uint numVaults;

    // Can contain all acceptable token pairs, and be use to create all vaults upfront on deployment,
    // or be used to check if deposits are valid
    mapping(ERC20 => ERC20) tokenPairs;

    // Creates vault for specific token pair --
    // In the future need to add list of specific token pairs allowed
    // or (more likely) just create all the specific vaults upfront on deployment
    function CreateVault(ERC20 tokenType1, ERC20 tokenType2) public returns(uint) {
        vault storage NewVault = vaultList[numVaults];
        NewVault.vaultOwner = msg.sender;
        NewVault.tokenType1 = tokenType1;
        NewVault.tokenType2 = tokenType2;
        NewVault.vaultID = numVaults;
        numVaults ++;
        return(numVaults--);
    }


    // For now you have to specify which vault id you want to deposit to
    // Will be updated to deposit to correct vault depending on the tokens input
    function InitialDeposit(
        uint vaultID, 
        ERC20 token1, 
        uint amount1, 
        ERC20 token2, 
        uint amount2, 
        uint exitMax, 
        uint exitMin) 
        
        // Will need to return an ERC721 token to represent users ownership -- using boolean as a temporary placeholder
        public returns (bool) {
        vault storage Vault = vaultList[vaultID];
        
        // Perform transfer from user to vault
        // Need to add some logic to require both trasnfers to succeed,
        // This way they dont fail on depositing one and not the other. 
        super.push(token1, msg.sender, amount1);
        super.push(token2, msg.sender, amount2);

        // Need to add logic to only perform the next lines if the above transactions were successful
        Vault.totalLiquidityToken1 += amount1;
        Vault.totalLiquidityToken2 += amount2;
        Vault.positionExitMax[msg.sender] = exitMax;
        Vault.positionExitMin[msg.sender] = exitMin;

        // Need logic to mint ERC721 token
        // super.mint()

        // Will change to returning ERC721 token -- using boolean as a temporary placeholder
        // Need logic to NOT send ERC721 if transactions fail.
        return(true);
    }


    // For now you have to specify which vault id you want to deposit to
    // Will be updated to deposit to correct vault depending on the tokens input
    function AddLiquidity(
        uint vaultID, 
        ERC20 token1, 
        uint amount1, 
        ERC20 token2, 
        uint amount2) //, ERC721 token) --doesnt exist right now commenting out to remove error 
        public returns (bool) {
        vault storage Vault = vaultList[vaultID];

        // Perform transfer from user to vault
        // Need to add some logic to require both trasnfers to succeed,
        // This way they dont fail on depositing one and not the other. 
        super.push(token1, msg.sender, amount1);
        super.push(token2, msg.sender, amount2);

        // Need to add logic to only perform the next lines if the above transactions were successful
        Vault.totalLiquidityToken1 += amount1;
        Vault.totalLiquidityToken2 += amount2;

        // Need logic to burn old ERC721 token and mint a new one with liquidity from all deposits?
        // super.burn()
        // super.mint()

        // Will change to returning ERC721 token -- using boolean as a temporary placeholder
        // Need logic to NOT send ERC721 if transactions fail.
        return(true);
    }


    // For now you have to specify which vault id you want to deposit to
    // Will be updated to deposit to correct vault depending on the tokens input
    // Need logic to work with the ERC721 token 
    // Most likely wont need token1 or token2 inputs
    // Will need logic to pull out liquidity from active positions
    function RemoveLiquidity(
        uint vaultID, 
        ERC20 token1, 
        uint amount1, 
        ERC20 token2, 
        uint amount2)//, ERC721 token) --doesnt exist right now commenting out to remove error ERC721 token) 
        public returns (bool) {
        vault storage Vault = vaultList[vaultID];

        // Perform transfer from vault to user
        // Need to add some logic to require both trasnfers to succeed,
        // This way they dont fail on removing one and not the other. 
        // Need address of vault ? -- Maybe data needed is in ERC721 token ?
        // super.pull(token1, msg.sender, amount1);
        // super.pull(token2, msg.sender, amount2);

        // Need to add logic to only perform the next lines if the above transactions were successful
        Vault.totalLiquidityToken1 -= amount1;
        Vault.totalLiquidityToken2 -= amount2;

        // Need logic to burn old ERC721 token and mint a new one with new liquidity balance?
        // super.burn(token)
        
        // Will change to returning ERC721 token -- using boolean as a temporary placeholder
        // -- using boolean as a temporary placeholder
        return(true);
    }
   
   
    // For now you have to specify which vault id you want to deposit to
    // Will be updated to deposit to correct vault depending on the tokens input
    // Need logic to work with the ERC721 token 
    // Most likely wont need token1 or token2 inputs
    // Will need logic to pull out liquidity from active positions
    function RemoveAllLiquidity(
        uint vaultID, 
        ERC20 token1,
        ERC20 token2) //, ERC721 token) --doesnt exist right now commenting out to remove error ERC721 token) 
        public {

            // Logic Needed to get total liquidity in position
            // Most likely will be in ERC721 token
            // maxAmount1 = max amount from ERC721 in tokenType1
            // maxAmount2 = max amount from ERC721 in tokenType2
            // return (self.RemoveLiquidity(vaultID, token1, maxAmount1, token2, maxAmount2, token));
    }

    // Function will be used to transfer liquidity out of vault and in to SuperAPP
    function TransferLiquidity() internal{
        
    }


    // Function to add liquidity back in from superAPP
    function PushBackLiquidity() internal {

    }

    // Function to call back liquidity from active positions in the event of a user requesting
    // to remove liquidity
    function RetreiveLiquidity() internal {

    }


    // Function to display all vaults
    // Need logic to print this out -- 
    // its formatted in python right now for example purposes
    function getVaultList() internal {
        /*
        for (i in vaultList) {
            print(
            "Vault Owner: {vaultOwner}, \n
             Token Type 1: {tokenType1}, \n
             Token Type 2: {tokenType2}, \n
             Vault ID: {vaultID}, \n
             Token 1 Total Liquidity: {totalLiquidityToken1}, \n
             Token 1 Total Inactive Liquidity: {totalInactiveLiquidityToken1}, \n
             Token 1 Total Active Liquidity: {totalActiveLiquidityToken1}, \n
             Token 2 Total Liquidity: {totalLiquidityToken2}, \n
             Token 2 Total Inactive Liquidity: {totalInactiveLiquidityToken2}, \n
             Token 2 Total Active Liquidity: {totalActiveLiquidityToken2} ")  
        } */
    }

    // Funciton to display total liquidity in pool
    // Need logic to concatenate data into string
    function getTotalLiquidity(uint vaultID) private returns (string memory) {
        vault storage Vault = vaultList[vaultID];


        // f" {Vault.tokenType1}: {Vault.totalLiquidityToken1} \n
        // {Vault.tokenType2}: {Vault.totalLiquidityToken2}"

        return("String that will display the 4 values above");
    }


    // Funciton to display total liquidity in pool
    // Need logic to concatenate data into string
    function getTotalInactiveLiquidity(uint vaultID) private returns (string memory) {
        vault storage Vault = vaultList[vaultID];


        // f" {Vault.tokenType1}: {Vault.totalInactiveLiquidityToken1} \n
        // {Vault.tokenType2}: {Vault.totalInactiveLiquidityToken2}"

        return("String that will display the 4 values above");
    }


    // Funciton to display total liquidity in pool
    // Need logic to concatenate data into string
    function getTotalActiveLiquidity(uint vaultID) private returns (string memory) {
        vault storage Vault = vaultList[vaultID];


        // f" {Vault.tokenType1}: {Vault.totalActiveLiquidityToken1} \n
        // {Vault.tokenType2}: {Vault.totalActiveLiquidityToken2}"

        return("String that will display the 4 values above");
    }

    // Function to show vault owner -- its public right now for testing
    function getVaultOwner(uint vaultID) public returns(address) {
        vault storage Vault = vaultList[vaultID];
        return(Vault.vaultOwner);
    }

    function getTokenTypes(uint vaultID) public returns (string memory) {
        vault storage Vault = vaultList[vaultID];
        // result = "Token Type 1: {Vault.tokenType1} \n
        //           Token Type 2: {Vault.tokenType2} "
        return("result");
    }
}