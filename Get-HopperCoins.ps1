# Link: https://lazywinadmin.github.io/2017/11/CoinMarketCap.html

# Install the module from the PowerShell Gallery (admin rights, yes to all if needed)
Install-Module -Name CoinMarketCap -Confirm:$False

function Get-Coin_Info {

    Get-Coin -CoinId bitcoin | select `
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD";Expression={"$ " + $_."price_usd"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 
    
    Get-Coin -CoinId ethereum | select `
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD";Expression={"$ " + $_."price_usd"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 
    
    Get-Coin -CoinId ripple | select `
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD";Expression={"$ " + $_."price_usd"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 
    
    Get-Coin -CoinId bitcoin-cash | select `
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD";Expression={"$ " + $_."price_usd"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 
    
    Get-Coin -CoinId cardano | select `
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD";Expression={"$ " + $_."price_usd"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 
    
    Get-Coin -CoinId litecoin | select `
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD";Expression={"$ " + $_."price_usd"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 
    
    Get-Coin -CoinId siacoin | select `
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD";Expression={"$ " + $_."price_usd"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 

    Get-Coin -CoinId eos | select `
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD";Expression={"$ " + $_."price_usd"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 
        
    Get-Coin -CoinId nem | select `
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD";Expression={"$ " + $_."price_usd"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 

    Get-Coin -CoinId civic | select `
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD";Expression={"$ " + $_."price_usd"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 

    Get-Coin -CoinId stratis | select `
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD";Expression={"$ " + $_."price_usd"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 

    Get-Coin -CoinId dogecoin | select `
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD";Expression={"$ " + $_."price_usd"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 

    Get-Coin -CoinId dash | select `
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD";Expression={"$ " + $_."price_usd"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 

    Get-Coin -CoinId bitshares | select `
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD";Expression={"$ " + $_."price_usd"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 


} 

# Retrieve Ripple coin information in new browser
# Get-Coin xrp -Online

# Retrieve EOS coin information in new browser
# Get-Coin eos -Online

# Retrieve all 100 coin information
# Get-CoinID

# Get coin history (not working)
# Get-CoinHistory -Begin '20171101' -End '20171105' -CoinId xrp

clear
Write-Output "##### CRYPTO COIN INFO FROM COINMARKETCAP $(Get-Date -Format g) #####"
Get-Coin_Info


