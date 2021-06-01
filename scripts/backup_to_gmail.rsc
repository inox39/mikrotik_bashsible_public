/system script
add dont-require-permissions=no name=backup owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="{\
    \r\
    \n## Check for update and send email with configuration if any\r\
    \n:log info \"Starting Update check and backup script...\";\r\
    \n\r\
    \n## Notification e-mail\r\
    \n:local Eaccount \"somebackup@gmail.com\";\r\
    \n\r\
    \n## Changelog location\r\
    \n:local Changelog \"https://mikrotik.com/current.rss\";\r\
    \n:local ChangelogFilename \"changelog_current.html\";\r\
    \n\r\
    \n## Resolve SMTP name and prepare backup variable\r\
    \n:local sysname [/system identity get name];\r\
    \n:local sysver [/system package get system version];\r\
    \n:local localSubj \"Empty\"\r\
    \n:local localBody \"Empty\"\r\
    \n:log info \"Flushing DNS cache...\";\r\
    \n/ip dns cache flush;\r\
    \n:delay 2;\r\
    \n:local smtpserv [:resolve \"smtp.gmail.com\"];\r\
    \n\r\
    \n## Check for update\r\
    \n/system package update\r\
    \n## set channel doesn't work on the latest FW\r\
    \n## set channel=current\r\
    \ncheck-for-updates\r\
    \n\r\
    \n## Wait on slow connections\r\
    \n:delay 15s;\r\
    \n\r\
    \n## Important note: \"installed-version\" was \"current-version\" on olde\
    r Router OSes\r\
    \n:if ([get installed-version] != [get latest-version]) do={\r\
    \n\r\
    \n## New version of RouterOS available\r\
    \n:log info (\"Upgrade available for RouterOS on router \$sysname from \$[\
    /system package update get installed-version] to \$[/system package update\
    \_get latest-version] (channel:\$[/system package update get channel])\")\
    \r\
    \n\r\
    \n:set localSubj \"RouterOS need to be upgraded on router \$sysname\"\r\
    \n:set localBody \"Upgrade for RouterOS available on router \$sysname from\
    \_\$[/system package update get installed-version] to \$[/system package u\
    pdate get latest-version] (channel:\$[/system package update get channel])\
    \"\r\
    \n\r\
    \n} else={\r\
    \n\r\
    \n## RouterOS latest, let's check for updated firmware\r\
    \n:log info (\"No RouterOS upgrade found, checking for HW upgrade...\")\r\
    \n\r\
    \n/system routerboard\r\
    \n\r\
    \n:if ( [get current-firmware] != [get upgrade-firmware]) do={\r\
    \n\r\
    \n## New version of firmware available\r\
    \n:log info (\"Firmware upgrade available on router \$sysname from \$[/sys\
    tem routerboard get current-firmware] to \$[/system routerboard get upgrad\
    e-firmware]\")\r\
    \n\r\
    \n:set localSubj \"Firmware need to be updated on router \$sysname\"\r\
    \n:set localBody \"Firmware upgrade available on router \$sysname from \$[\
    /system routerboard get current-firmware] to \$[/system routerboard get up\
    grade-firmware]\"\r\
    \n\r\
    \n} else={\r\
    \n\r\
    \n:log info (\"No Router HW upgrade found\")\r\
    \n}\r\
    \n}\r\
    \n\r\
    \n:log info \"localSubj= \$localSubj \";\r\
    \n:if ( !(\$localSubj = \"Empty\")) do={\r\
    \n\r\
    \n:log info \"Deleting last Backups...\";\r\
    \n:foreach i in=[/file find] do={:if ([:typeof [:find [/file get \$i name]\
    \_\\\r\
    \n\"\$sysname-backup-\"]]!=\"nil\") do={/file remove \$i}};\r\
    \n:delay 2;\r\
    \n:do {/file remove \$ChangelogFilename} on-error={};\r\
    \n\r\
    \n## Downloading changelog file\r\
    \n/tool fetch mode=https url=(\"\$Changelog\") dst-path=(\"\$ChangelogFile\
    name\");\r\
    \n\r\
    \n## Backup configuration\r\
    \n:local backupfile (\"\$sysname-backup-\" . \\\r\
    \n[:pick [/system clock get date] 7 11] . [:pick [/system \\\r\
    \nclock get date] 0 3] . [:pick [/system clock get date] 4 6] . \".backup\
    \");\r\
    \n:log info \"Creating new Full Backup file...\";\r\
    \n/system backup save name=\$backupfile;\r\
    \n:delay 5;\r\
    \n\r\
    \n:local exportfile (\"\$sysname-backup-\" . \\\r\
    \n[:pick [/system clock get date] 7 11] . [:pick [/system \\\r\
    \nclock get date] 0 3] . [:pick [/system clock get date] 4 6] . \".rsc\");\
    \r\
    \n:log info \"Creating new Setup Script file...\";\r\
    \n/export verbose file=\$exportfile;\r\
    \n:delay 5;\r\
    \n\r\
    \n:log info \"Sending Full Backup file via E-mail...\";\r\
    \n/tool e-mail send to=\$Eaccount server=\$smtpserv \\\r\
    \nport=587 start-tls=yes file=(\$backupfile .\",\" . \$exportfile . \",\" \
    . \$ChangelogFilename) \\\r\
    \nsubject=(\"\$localSubj\") \\\r\
    \nbody=(\"\$localBody\");\r\
    \n:delay 10;\r\
    \n\r\
    \n}\r\
    \n}"
/tool e-mail
set address=smtp.gmail.com from=somebackup@gmail.com password=SomePass$123 port=\
    587 start-tls=yes user=somebackup
