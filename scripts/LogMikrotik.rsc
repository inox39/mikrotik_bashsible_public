/system scheduler
add comment="may/29/2021 23:36:11" interval=5m name=LogMikrotik on-event=\
    "/system script run LogMikrotik" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=nov/25/2019 start-time=10:06:52
/system script
add dont-require-permissions=no name=LogMikrotik owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="#\
    \_BEGIN SETUP\r\
    \n:local scheduleName \"LogMikrotik\"\r\
    \nlocal bot \"1333333319:AdgsgsdgsdgsdgG9H6p-brc_Ib_jr96_P8\"\r\
    \nlocal ChatID \"276263633\"\r\
    \n:local startBuf [:toarray [/log find message~\"logged in\" || message~\"\
    login failure\"]]\r\
    \n:local removeThese {\"telnet\";\"user134\";\"whatever string you want\"}\
    \r\
    \n# END SETUP\r\
    \n\r\
    \n# warn if schedule does not exist\r\
    \n:if ([:len [/system scheduler find name=\"\$scheduleName\"]] = 0) do={\r\
    \n  /log warning \"[LOGMON] ERROR: Schedule does not exist. Create schedul\
    e and edit script to match name\"\r\
    \n}\r\
    \n\r\
    \n# get last time\r\
    \n:local lastTime [/system scheduler get [find name=\"\$scheduleName\"] co\
    mment]\r\
    \n# for checking time of each log entry\r\
    \n:local currentTime\r\
    \n# log message\r\
    \n:local message\r\
    \n \r\
    \n# final output\r\
    \n:local output\r\
    \n\r\
    \n:local keepOutput false\r\
    \n# if lastTime is empty, set keepOutput to true\r\
    \n:if ([:len \$lastTime] = 0) do={\r\
    \n  :set keepOutput true\r\
    \n}\r\
    \n\r\
    \n:local counter 0\r\
    \n# loop through all log entries that have been found\r\
    \n:foreach i in=\$startBuf do={\r\
    \n \r\
    \n# loop through all removeThese array items\r\
    \n  :local keepLog true\r\
    \n  :foreach j in=\$removeThese do={\r\
    \n#   if this log entry contains any of them, it will be ignored\r\
    \n    :if ([/log get \$i message] ~ \"\$j\") do={\r\
    \n      :set keepLog false\r\
    \n    }\r\
    \n  }\r\
    \n  :if (\$keepLog = true) do={\r\
    \n   \r\
    \n   :set message [/log get \$i message]\r\
    \n\r\
    \n#   LOG DATE\r\
    \n#   depending on log date/time, the format may be different. 3 known for\
    mats\r\
    \n#   format of jan/01/2002 00:00:00 which shows up at unknown date/time. \
    Using as default\r\
    \n    :set currentTime [ /log get \$i time ]\r\
    \n#   format of 00:00:00 which shows up on current day's logs\r\
    \n   :if ([:len \$currentTime] = 8 ) do={\r\
    \n     :set currentTime ([:pick [/system clock get date] 0 11].\" \".\$cur\
    rentTime)\r\
    \n    } else={\r\
    \n#     format of jan/01 00:00:00 which shows up on previous day's logs\r\
    \n     :if ([:len \$currentTime] = 15 ) do={\r\
    \n        :set currentTime ([:pick \$currentTime 0 6].\"/\".[:pick [/syste\
    m clock get date] 7 11].\" \".[:pick \$currentTime 7 15])\r\
    \n      }\r\
    \n   }\r\
    \n    \r\
    \n#   if keepOutput is true, add this log entry to output\r\
    \n   :if (\$keepOutput = true) do={\r\
    \n     :set output (\$output.\$currentTime.\" \".\$message.\"\\r\\n\")\r\
    \n   }\r\
    \n\r\
    \n    :if (\$currentTime = \$lastTime) do={\r\
    \n     :set keepOutput true\r\
    \n     :set output \"\"\r\
    \n   }\r\
    \n  }\r\
    \n  :if (\$counter = ([:len \$startBuf]-1)) do={\r\
    \n   :if (\$keepOutput = false) do={    \r\
    \n     :if ([:len \$message] > 0) do={\r\
    \n        :set output (\$output.\$currentTime.\" \".\$message.\"\\r\\n\")\
    \r\
    \n      }\r\
    \n    }\r\
    \n  }\r\
    \n  :set counter (\$counter + 1)\r\
    \n}\r\
    \n\r\
    \nif ([:len \$output] > 0) do={\r\
    \n  /system scheduler set [find name=\"\$scheduleName\"] comment=\$current\
    Time\r\
    \n  /tool fetch url=\"https://api.telegram.org/bot\$bot/sendmessage\?chat_\
    id=\$ChatID&text=Home-HexS MikroTik alert \$currentTime : \$output\" keep-\
    result=no;\r\
    \n}"
