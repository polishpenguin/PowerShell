Install-Module -Name CoinMarketCap -Confirm:$False

# Yahoo ports 587 or 465
$PSEMailServer = 'smtp.mail.yahoo.com'
#$Username = "polishpenguin"
#$Password = ""
#$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $Password
Send-MailMessage -To "Pawel <polishpenguin@yahoo.com>" -From "Pawel <polishpenguin@yahoo.com>" -SMTPServer smtp.mail.yahoo.com -Port 587 -Subject "Daily Crypto Report" -Body "This is daily report of crypto" -UseSsl -Credentials (Get-Credential)

# Gmail
$From = "test@test.com"
$To = "pawel.pasternak23@gmail.com"
#$Cc = "AThirdUser@somewhere.com"
#$Attachment = "C:\users\Username\Documents\SomeTextFile.txt"
$Subject = "Crypto Test"
$Body = "Report"
$SMTPServer = "smtp.gmail.com"
$SMTPPort = "587"
Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential (Get-Credential) –DeliveryNotificationOption OnSuccess

{ 
$message = @" 
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
    
    Get-Coin -CoinId civic | select @{Name="RANK";Expression={$_."rank"}},
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

}                                

"@ 
}       
 

#SMTP server name
$smtpServer = "smtp.mail.yahoo.com"

#Creating a Mail object
$msg = new-object Net.Mail.MailMessage

#Creating SMTP server object
$smtp = new-object Net.Mail.SmtpClient($smtpServer)

#Email structure 
$msg.From = "pawel.pasternak@centurylink.com"
$msg.ReplyTo = "polishpenguin@yahoo.com"
$msg.To.Add("polishpenguin@yahoo.com")
$msg.subject = "CRYPTO"
$msg.body = "This is the email Body."

#Sending email 
$smtp.Send($msg)

Email_Report

