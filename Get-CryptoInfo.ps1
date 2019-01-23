# Link: https://lazywinadmin.github.io/2017/11/CoinMarketCap.html

# Install the module from the PowerShell Gallery (admin rights, yes to all)
Install-Module -Name CoinMarketCap -Confirm:$False

function Get-Coin_Info {

    Get-Coin -CoinId bitcoin | select @{Name="RANK";Expression={$_."rank"}},
    @{Name="NAME";Expression={$_."name"}}, 
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD$";Expression={"$ " + $_."price_usd"}}, 
    @{Name="BTC";Expression={$_."price_btc"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 
    
    Get-Coin -CoinId ethereum | select @{Name="RANK";Expression={$_."rank"}},
    @{Name="NAME";Expression={$_."name"}}, 
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD$";Expression={"$ " + $_."price_usd"}}, 
    @{Name="BTC";Expression={$_."price_btc"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}}
    
    Get-Coin -CoinId ripple | select @{Name="RANK";Expression={$_."rank"}},
    @{Name="NAME";Expression={$_."name"}}, 
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD$";Expression={"$ " + $_."price_usd"}}, 
    @{Name="BTC";Expression={$_."price_btc"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}}
    
    Get-Coin -CoinId bitcoin-cash | select @{Name="RANK";Expression={$_."rank"}},
    @{Name="NAME";Expression={$_."name"}}, 
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD$";Expression={"$ " + $_."price_usd"}}, 
    @{Name="BTC";Expression={$_."price_btc"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}}
    
    Get-Coin -CoinId cardano | select @{Name="RANK";Expression={$_."rank"}},
    @{Name="NAME";Expression={$_."name"}}, 
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD$";Expression={"$ " + $_."price_usd"}}, 
    @{Name="BTC";Expression={$_."price_btc"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}}
    
    Get-Coin -CoinId litecoin | select @{Name="RANK";Expression={$_."rank"}},
    @{Name="NAME";Expression={$_."name"}}, 
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD$";Expression={"$ " + $_."price_usd"}}, 
    @{Name="BTC";Expression={$_."price_btc"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} 
    
    Get-Coin -CoinId stellar | select @{Name="RANK";Expression={$_."rank"}},
    @{Name="NAME";Expression={$_."name"}}, 
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD$";Expression={"$ " + $_."price_usd"}}, 
    @{Name="BTC";Expression={$_."price_btc"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}}

    Get-Coin -CoinId eos | select @{Name="RANK";Expression={$_."rank"}},
    @{Name="NAME";Expression={$_."name"}}, 
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD$";Expression={"$ " + $_."price_usd"}}, 
    @{Name="BTC";Expression={$_."price_btc"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}}
        
    Get-Coin -CoinId nem | select @{Name="RANK";Expression={$_."rank"}},
    @{Name="NAME";Expression={$_."name"}}, 
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD$";Expression={"$ " + $_."price_usd"}}, 
    @{Name="BTC";Expression={$_."price_btc"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}}

    Get-Coin -CoinId civic | select @{Name="RANK";Expression={$_."rank"}},
    @{Name="NAME";Expression={$_."name"}}, 
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="USD$";Expression={"$ " + $_."price_usd"}}, 
    @{Name="BTC";Expression={$_."price_btc"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}}


}

Get-Coin | sort-list 

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

<#
clear
#Get-Coin | Sort-Object percent_change_1h -Descending | select name, symbol, percent_change_1h -First 10

    Get-Coin | Sort-Object percent_change_1h -Descending | select @{Name="NAME";Expression={$_."name"}},
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="1 HOUR";Expression={$_."percent_change_1h" + "%" }} -First 10

    Get-Coin | Sort-Object percent_change_24h -Descending | select @{Name="NAME";Expression={$_."name"}},
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="1 DAY";Expression={$_."percent_change_24h" + "%"}} -First 10

    Get-Coin | Sort-Object percent_change_7d -Descending | select @{Name="NAME";Expression={$_."name"}},
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} -First 10



    Get-Coin  | select @{Name="NAME";Expression={$_."name"}},
    @{Name="SYMBOL";Expression={$_."symbol"}}, 
    @{Name="1 WEEK";Expression={$_."percent_change_7d" + "%"}} -First 100 | Sort-Object percent_change_7d -Descending


Get-Coin | sort percent_change_1h, i -Descending | select -First 10
Get-Coin | sort percent_change_24h -Descending | select -First 10
Get-Coin | sort percent_change_7d -Descending | select -First 10

Get-EventLog System -Newest 100 | sort Source -Unique | FT -AutoSize
#>